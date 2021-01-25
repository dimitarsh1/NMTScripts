#!/bin/sh
ENGINEDIR=$1
DATADIR=$ENGINEDIR/data
MODELDIR=$ENGINEDIR/model

INPUTONE=$2
INPUTTWO=$3

DEVICEID=$4

MTTools=$( dirname $0 )
SUBWORDTools=$MTTools/"subword-nmt"

MARIAN=$MTTools/marian

echo "Translating with MARIAN on " $DEVICEID

$MARIAN/build/marian-decoder \
    --type multi-transformer \
    --devices $DEVICEID \
    --model $MODELDIR/model.npz \
    --workspace 9000 \
    --max-length 130 --max-length-crop \
    --vocabs $DATADIR/train.tc.bpe.src1.json $DATADIR/train.tc.bpe.src2.json $DATADIR/train.tc.bpe.trg.json \
    --input $INPUTONE $INPUTTWO > $INPUTONE.out
