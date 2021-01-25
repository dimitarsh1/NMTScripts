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
    --type multi-s2s \
    --model $MODELDIR/model.npz \
    --train-sets $DATADIR/train.tok.bpe.src1 $DATADIR/train.tok.bpe.src2 $DATADIR/train.tok.bpe.src3 $DATADIR/train.tok.bpe.src4 $DATADIR/train.tok.bpe.src5 $DATADIR/train.tok.bpe.trg \
    --vocabs $DATADIR/train.tok.bpe.src1.json $DATADIR/train.tok.bpe.src2.json $DATADIR/train.tok.bpe.src3.json $DATADIR/train.tok.bpe.src4.json $DATADIR/train.tok.bpe.src5.json $DATADIR/train.tok.bpe.trg.json \
    --mini-batch-fit --workspace 9000 \
    --layer-normalization --dropout-rnn 0.2 --dropout-src 0.1 --dropout-trg 0.1 \
    --early-stopping 5 \
    --max-length 150 --max-length-crop \
    --valid-freq 2000 --save-freq 2000 --disp-freq 1000 \
    --valid-metrics cross-entropy translation \
    --valid-sets $DATADIR/dev.tok.bpe.src1 $DATADIR/dev.tok.bpe.src2 $DATADIR/dev.tok.bpe.src3 $DATADIR/dev.tok.bpe.src4 $DATADIR/dev.tok.bpe.src5 $DATADIR/dev.tok.bpe.trg \
    --valid-script-path $MTTools/validate_marian.sh \
    --log $MODELDIR/train.log --valid-log $MODELDIR/dev.log
