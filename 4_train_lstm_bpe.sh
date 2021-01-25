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

MODELDIR=${ENGINEDIR}/model

SCRIPTPATH=$( cd $( dirname $( readlink -f $0 ) ) && pwd )

echo $SCRIPTPATH

OPENNMT=${SCRIPTPATH}'/OpenNMT-py'
# export CUDA_VISIBLE_DEVICES=0,1,2,3
export CUDA_VISIBLE_DEVICES=2,3

echo "4.1. Prepare the data..."
SRC=src
TRG=trg

SRC_VOC_SIZE=$(cat $ENGINEDIR/data/train.tc.bpe.${SRC}.dict.size)
TRG_VOC_SIZE=$(cat $ENGINEDIR/data/train.tc.bpe.${TRG}.dict.size)

echo $SRC_VOC_SIZE
echo $TRG_VOC_SIZE

if [ "$SKIPPREPROCESS" -eq "0" ] || [ ! -f $ENGINEDIR/data/ready_to_train.train.0.pt ];
then
    rm $ENGINEDIR/data/ready_to_train*

    python3 $OPENNMT/preprocess.py \
        -train_src $ENGINEDIR/data/train.tc.bpe.${SRC} \
        -train_tgt $ENGINEDIR/data/train.tc.bpe.${TRG} \
        -valid_src $ENGINEDIR/data/dev.tc.bpe.${SRC} \
        -valid_tgt $ENGINEDIR/data/dev.tc.bpe.${TRG} \
        -src_vocab_size $SRC_VOC_SIZE -tgt_vocab_size $TRG_VOC_SIZE \
        -filter_valid \
        -save_data $ENGINEDIR/data/ready_to_train
else
    echo "Skipping preprocessing"
fi

echo "Launching GPU monitoring"
GPUMONPID=$( nvidia-smi dmon -i 2,3 -s mpucv -d 5 -o TD > $MODELDIR/gpu.log & )

echo "4.2. Train LSTM..."
echo "Options derived from: https://arxiv.org/abs/1703.03906 thanks to Gideon"
python3 $OPENNMT/train.py \
    -data $ENGINEDIR/data/ready_to_train --save_model ${MODELDIR}/model \
    -rnn_size 512 -rnn_type LSTM \
    -enc_layers 4 -dec_layers 4 \
    -encoder_type brnn -decoder_type rnn \
    -global_attention mlp -dropout 0.2 \
    -train_steps 302000 -batch_size 128 \
    -optim adam -warmup_steps 2000 -learning_rate 0.0001 \
    -valid_steps 5000 -save_checkpoint_steps 5000 \
    -report_every 100 \
    -early_stopping 5 -early_stopping_criteria ppl accuracy \
    -world_size 2 -gpu_ranks 0 1 \
    -log_file $MODELDIR/train.log

A=$( grep 'Best' $MODELDIR/train.log | rev | cut -d ' ' -f 1 | rev );
B=$( grep -B4 ${A}'.pt' $MODELDIR/train.log | head -2 | rev | cut -d ' ' -f 1 | rev | tr '\n' '_' );

MODELNAME='model_step_'${A}'.pt'

echo 'Saving best model: ' $MODELNAME

cp $MODELDIR/${MODELNAME} $MODELDIR/best_model_${A}_${B}.pl

kill -s 9 $GPUMONPID

echo "Done."
