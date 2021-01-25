#!/bin/bash
# validate.sh
DATADIR=$ENGINEDIR/data
REF=$DATADIR/dev.trg
REFTC=$DATADIR/dev.tc.trg

MTTools=$( dirname $0 )

cat $1 > $DATADIR/raw.out

cat $DATADIR/raw.out | sed -r 's/\@\@ //g' > $DATADIR/raw.tc.out

$MTTools/postprocess.sh < $DATADIR/raw.out > $DATADIR/postprocessed.out
BLEU=$( $MTTools/multi-bleu-detok.perl $REF < $DATADIR/postprocessed.out 2> /dev/null \
    | sed -r 's/BLEU = ([0-9.]+),.*/\1/' )
MULTEVAL=$( cd ${MTTools}/multeval; ./multedev.sh eval --refs ${REFTC} --hyps-baseline ${DATADIR}/raw.tc.out --metrics bleu ter --boot-samples 1000 2> /dev/null | grep baseline )
echo $BLEU $MULTEVAL
