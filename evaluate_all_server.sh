#!/bin/bash

function eval {
	export SRCLANG=en;
	export TRGLANG=fr;

	TESTOUT1=/home/shterion/EcoNMT/engines/EN-FR-LSTM-BPE/data/test.tc.bpe.src.server.parallel_normal.out
	TESTOUT2=/home/shterion/EcoNMT/engines/EN-FR-TRANS-BPE/data/test.tc.bpe.src.server.parallel_normal.out

	TESTFIN1=$TESTOUT1.final
	TESTFIN2=$TESTOUT2.final

	echo "postprocessing..."
	sh 7_postprocess.sh $TESTOUT1 $TRGLANG
	sh 7_postprocess.sh $TESTOUT2 $TRGLANG
	echo "done."

	REF=/home/shterion/EcoNMT/engines/REF/en-fr-test.tok.ref.tok
	HYP1=$TESTFIN1
	HYP2=$TESTFIN2
	echo "evaluating..."
	echo "LSTM" >> $1
	sh 8_eval_single.sh $REF $TRGLANG $HYP1 >> $1
	echo "TRANS" >> $1
	sh 8_eval_single.sh $REF $TRGLANG $HYP2 >> $1
	echo "done."

}

OUTFILE=p100_metrics_server.txt;
echo "BLEU TER" > $OUTFILE;

eval $OUTFILE; 
