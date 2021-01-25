#!/bin/bash
# Cleansing and tokenising the data.
if [ -z $ENGINEDIR ]
then
    echo 'Export ENGINEDIR'
    exit 1
fi

if [ -z $SRCLANG ]
then
    echo 'Export SRCLANG'
    exit 1
fi

if [ -z $TRGLANG ]
then
    echo 'Export TRGLANG'
    exit 1
fi

DATADIR=$ENGINEDIR/data

MTTools=$( dirname $0 )
MTTools=$MTTools/"MTTools"

echo 'Tokenising...'
# tokenize
for FILE in 'train' 'test' 'dev'
do
    if [ $SRCLANG == "bn" ]
    then
        echo "Tokenizing BN"
        python3 $MTTools/BNLP_tokenizer.py -i ${DATADIR}/${FILE}.src > ${DATADIR}/${FILE}.tok.src
    else
        cat ${DATADIR}/${FILE}.src | \
        $MTTools/normalize-punctuation.perl -l ${SRCLANG} | \
        $MTTools/tokenizer.perl -a -no-escape -l $SRCLANG > ${DATADIR}/${FILE}.tok.src
    fi

    if [ $TRGLANG == "bn" ]
    then
        echo "Tokenizing BN"
        python3 $MTTools/BNLP_tokenizer.py -i ${DATADIR}/${FILE}.trg > ${DATADIR}/${FILE}.tok.trg
    else
        cat ${DATADIR}/${FILE}.trg | \
        $MTTools/normalize-punctuation.perl -l ${TRGLANG} | \
        $MTTools/tokenizer.perl -a -no-escape -l $TRGLANG > ${DATADIR}/${FILE}.tok.trg
    fi
done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$MTTools/clean-corpus-n.perl $DATADIR/train.tok src trg $DATADIR/train.clean 2 200


echo 'Done.'
