#!/bin/sh
if [ -z $ENGINEDIR ]
then
    if [ ! -z "$1" ]
    then
        ENGINEDIR=$1
    else
        echo 'Specify or export ENGINEDIR'
        exit 1
    fi
fi

if [ ! -z $SKIPPREPROCESS ]
then
    SKIPPREPROCESS=1
else
    SKIPPREPROCESS=0
fi

MODELDIR=$ENGINEDIR/model

SCRIPTPATH=$( cd $( dirname $( readlink -f $0 ) ) && pwd )

#SCRIPTPATH=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo $SCRIPTPATH

OPENNMT=${SCRIPTPATH}'/OpenNMT-py'
export CUDA_VISIBLE_DEVICES=0,1,2,3

echo "4.1. Prepare the data..."

SRC=src
TRG=trg

SRC_VOC_SIZE=$(cat $ENGINEDIR/data/train.tc.${SRC}.dict.size)
TRG_VOC_SIZE=$(cat $ENGINEDIR/data/train.tc.${TRG}.dict.size)

echo $SRC_VOC_SIZE
echo $TRG_VOC_SIZE

if [ "$SKIPPREPROCESS" -eq "0" ] || [ ! -f $ENGINEDIR/data/ready_to_train.train.0.pt ];
then
    rm $ENGINEDIR/data/ready_to_train*

    python3 $OPENNMT/preprocess.py \
        -train_src $ENGINEDIR/data/train.tc.${SRC} \
        -train_tgt $ENGINEDIR/data/train.tc.${TRG} \
        -valid_src $ENGINEDIR/data/dev.tc.${SRC} \
        -valid_tgt $ENGINEDIR/data/dev.tc.${TRG} \
        -src_vocab_size $SRC_VOC_SIZE -tgt_vocab_size $TRG_VOC_SIZE \
        -filter_valid \
        -save_data $ENGINEDIR/data/ready_to_train
else
    echo "Skipping preprocessing"
fi

echo "Launching GPU monitoring"
GPUMONPID=$( nvidia-smi dmon -i 0,1,2,3 -s mpucv -d 5 -o TD > $MODELDIR/gpu.log & )

echo "4.2. Train..."
echo "Options derived from: http://opennmt.net/OpenNMT-py/FAQ.html "
python $OPENNMT/train.py \
    -data $ENGINEDIR/data/ready_to_train -save_model $MODELDIR/model \
    -layers 6 -rnn_size 512 -word_vec_size 512 -transformer_ff 2048 -heads 8 \
    -encoder_type transformer -decoder_type transformer -position_encoding \
    -train_steps 202000 -max_generator_batches 2 -dropout 0.1 \
    -batch_size 4096 -batch_type tokens -normalization tokens -accum_count 2 \
    -optim adam -adam_beta2 0.998 -decay_method noam -warmup_steps 2000 -learning_rate 2 \
    -max_grad_norm 0 -param_init 0 -param_init_glorot \
    -label_smoothing 0.1 -valid_steps 500 -save_checkpoint_steps 500 \
    -report_every 100 \
    -early_stopping 5 -early_stopping_criteria ppl accuracy \
    -world_size 4 -gpu_ranks 0 1 2 3 \
    -log_file $MODELDIR/train.log

# batch_size originally at 4096
A=$( grep 'Best' $MODELDIR/train.log | rev | cut -d ' ' -f 1 | rev )
B=$( grep -B4 ${A}'.pt' $MODELDIR/train.log | head -2 | rev | cut -d ' ' -f 1 | rev | tr '\n' '_' )

MODELNAME='model_step_'${A}'.pt'

echo 'Saving best model: ' $MODELNAME

cp $MODELDIR/${MODELNAME} $MODELDIR/best_model_${A}_${B}.pl

kill -s 9 $GPUMONPID

echo "Done."
