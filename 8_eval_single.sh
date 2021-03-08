#!/bin/bash
# validate.sh
REF=$1
TRGLANG=$2
HYP=$3

MTTools=$( dirname $0 )
MTTools=${MTTools}/MTTools

if [ ! -e $REF.eval.tok ]
then
	$MTTools/detokenizer.perl -l $TRGLANG < $REF > $REF.detok
	$MTTools/tokenizer.perl -l $TRGLANG < $REF.detok > $REF.eval.tok
fi

if [ ! -e $HYP.eval.tok ]
then
	$MTTools/tokenizer.perl -l $TRGLANG < $HYP > $HYP.eval.tok
fi

echo $REF
echo $HYP

BLEU=$( $MTTools/multi-bleu-detok.perl $REF < $HYP 2> /dev/null \
    | sed -r 's/BLEU = ([0-9.]+),.*/\1/' )
MULTEVAL=$( cd ${MTTools}/multeval; ./multeval.sh eval --refs ${REF}.eval.tok --hyps-baseline ${HYP}.eval.tok --metrics bleu ter --boot-samples 1000 )
echo $BLEU $MULTEVAL
