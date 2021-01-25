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

MODELDIR=${ENGINEDIR}/model
DATADIR=${ENGINEDIR}/data

SCRIPTPATH=$( cd $( dirname $( readlink -f $0 ) ) && pwd )

echo $SCRIPTPATH

MTTools=$SCRIPTPATH/"MTTools"
SUBWORDTools=$MTTools/"subword-nmt"

NUMSYM=50000

# train BPE
$SUBWORDTools/learn_bpe.py --input $DATADIR/train.tok.src --output $DATADIR/bpe.src --symbols $NUMSYM
$SUBWORDTools/learn_bpe.py --input $DATADIR/train.tok.trg --output $DATADIR/bpe.trg --symbols $NUMSYM

# apply BPE
for FILE in 'train' 'test' 'dev'
do
    $SUBWORDTools/apply_bpe.py -c $DATADIR/bpe.src < $DATADIR/$FILE.tok.src > $DATADIR/${FILE}.tc.bpe.src
    $SUBWORDTools/apply_bpe.py -c $DATADIR/bpe.trg < $DATADIR/$FILE.tok.trg > $DATADIR/${FILE}.tc.bpe.trg
done

# build network dictionary
python2 $MTTools/build_dictionary.py $DATADIR/train.tc.bpe.src
python2 $MTTools/build_dictionary.py $DATADIR/train.tc.bpe.trg
