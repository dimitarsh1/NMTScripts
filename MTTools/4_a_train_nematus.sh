#!/bin/sh
ENGINEDIR=$1
DATADIR=$ENGINEDIR/data
MODELDIR=$ENGINEDIR/model

DEVICEID=$2
MTTools=$( dirname $0 )
SUBWORDTools=$MTTools/"subword-nmt"

NEMATUS=$MTTools/nematus/nematus
# for new Tensorflow backend, use a command like this:
# CUDA_VISIBLE_DEVICES=$device python $nematus_home/nematus/nmt.py \

export CUDA_VISIBLE_DEVICES="${DEVICEID}"
export PATH=/usr/local/cuda-9.0/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda-9.0/lib:$LD_LIBRARY_PATH

echo "Running NEMATUS on " $DEVICEID


CUDA_VISIBLE_DEVICES=$DEVICEID python2 $NEMATUS/nmt.py \
    --model $MODELDIR/model.npz \
    --datasets $DATADIR/train.tc.bpe.src $DATADIR/train.tc.bpe.trg \
    --valid_datasets $DATADIR/val.tc.bpe.src $DATADIR/val.tc.bpe.trg \
    --dictionaries $DATADIR/train.tc.bpe.src.json $DATADIR/train.tc.bpe.trg.json \
    --dim_word 512 \
    --dim 1024 \
    --lrate 0.0005 \
    --optimizer adam \
    --maxlen 50 \
    --batch_size 80 \
    --valid_batch_size 40 \
    --validFreq 10000 \
    --dispFreq 1000 \
    --saveFreq 30000 \
    --sampleFreq 10000 \
    --tie_decoder_embeddings \
    --layer_normalisation \
    --dec_base_recurrence_transition_depth 8 \
    --enc_recurrence_transition_depth 4

