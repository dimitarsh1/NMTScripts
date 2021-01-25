#!/bin/sh
ENGINEDIR=$1
DATADIR=$ENGINEDIR/data
MODELDIR=$ENGINEDIR/model

DEVICEID=$2
MTTools=$( dirname $0 )
SUBWORDTools=$MTTools/"subword-nmt"

MARIAN=$MTTools/marian

echo "Running MARIAN on " $DEVICEID

$MARIAN/build/marian \
    --devices $DEVICEID \
    --type multi-transformer \
    --model $MODELDIR/model.npz \
    --train-sets $DATADIR/train.tc.bpe.src1 $DATADIR/train.tc.bpe.src2 $DATADIR/train.tc.bpe.trg \
    --vocabs $DATADIR/train.tc.bpe.src1.json $DATADIR/train.tc.bpe.src2.json $DATADIR/train.tc.bpe.trg.json \
    --mini-batch-fit --workspace 10000 \
    --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
    --early-stopping 5 \
    --max-length 100 --max-length-crop \
    --valid-freq 2000 --save-freq 2000 --disp-freq 1000 \
    --valid-metrics cross-entropy translation \
    --valid-sets $DATADIR/val.tc.bpe.src1 $DATADIR/val.tc.bpe.src2 $DATADIR/val.tc.bpe.trg \
    --valid-script-path $MTTools/validate_marian.sh \
    --log $MODELDIR/train.log --valid-log $MODELDIR/val.log
