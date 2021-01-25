#!/bin/bash
# Cleansing and tokenising the data.
ENGINEDIR=$1
DATADIR=$ENGINEDIR/data
MODELDIR=$ENGINEDIR/model

MTTools=$( dirname $0 )
MTTools=$MTTools/"MTTools"

# train truecaser
echo "Truecasing..."
$MTTools/train-truecaser.perl -corpus $DATADIR/train.tok.clean.src -model $MODELDIR/truecase-model.src
$MTTools/train-truecaser.perl -corpus $DATADIR/train.tok.clean.trg -model $MODELDIR/truecase-model.trg

# apply truecaser on the cleaned train set
$MTTools/truecase.perl -model $MODELDIR/truecase-model.src < $DATADIR/train.tok.clean.src > $DATADIR/train.tc.src
$MTTools/truecase.perl -model $MODELDIR/truecase-model.trg < $DATADIR/train.tok.clean.trg > $DATADIR/train.tc.trg

# apply truecaser on the test and validation sets
for FILE in 'test' 'val'
do
    $MTTools/truecase.perl -model $MODELDIR/truecase-model.src < $DATADIR/${FILE}.tok.src > $DATADIR/${FILE}.tc.src
    $MTTools/truecase.perl -model $MODELDIR/truecase-model.trg < $DATADIR/${FILE}.tok.trg > $DATADIR/${FILE}.tc.trg
done
echo "Done"
