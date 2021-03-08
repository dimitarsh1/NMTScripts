#!/bin/bash

function eval {
	export SRCLANG=en;
	export TRGLANG=fr;

	export ENGINEDIR=/home/shterion/EcoNMT/engines/EN-FR-TRANS-BPE

	TESTOUT1=$ENGINEDIR/data/test.tc.bpe.src.ct2.out
	TESTOUT2=$ENGINEDIR/data/test.tc.bpe.src.ct2_int8.out
	TESTOUT3=$ENGINEDIR/data/test.tc.bpe.src.ct2_int16.out
	TESTFIN1=$TESTOUT1.final
	TESTFIN2=$TESTOUT2.final
	TESTFIN3=$TESTOUT3.final

	echo "postprocessing..."
	sh 7_postprocess.sh $TESTOUT1 $TRGLANG
	sh 7_postprocess.sh $TESTOUT2 $TRGLANG
	sh 7_postprocess.sh $TESTOUT3 $TRGLANG
	echo "done."

	REF=/home/shterion/EcoNMT/engines/REF/en-fr-test.tok.ref.tok
	HYP1=$TESTFIN1
	HYP2=$TESTFIN2
	HYP3=$TESTFIN3
	echo "evaluating..."
	echo "CT2" >> $1
	sh 8_eval_single.sh $REF $TRGLANG $HYP1 >> $1
	echo "CT2_INT8" >> $1
	sh 8_eval_single.sh $REF $TRGLANG $HYP2 >> $1
	echo "CT2_INT16" >> $1
	sh 8_eval_single.sh $REF $TRGLANG $HYP3 >> $1
	echo "done."

}

OUTFILE=p100_metrics_ct2.txt;
echo "BLEU TER" > $OUTFILE;

eval $OUTFILE; 
