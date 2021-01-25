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

for i in test dev
do
    cp $DATADIR/${i}.tok.src $DATADIR/${i}.tc.src
    cp $DATADIR/${i}.tok.trg $DATADIR/${i}.tc.trg
done

cp $DATADIR/train.clean.src $DATADIR/train.tc.src
cp $DATADIR/train.clean.trg $DATADIR/train.tc.trg

python2 $MTTools/build_dictionary.py $DATADIR/train.tc.src
python2 $MTTools/build_dictionary.py $DATADIR/train.tc.trg

