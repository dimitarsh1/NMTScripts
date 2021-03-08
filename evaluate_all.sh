#!/bin/bash

function eval {
	echo $1 $2 $3;

	src=$( echo "$1" | tr '[:upper:]' '[:lower:]' )
	trg=$( echo "$2" | tr '[:upper:]' '[:lower:]' )
	export SRCLANG=$src;
	export TRGLANG=$trg;

	export ENGINEDIR=/home/shterion/EcoNMT/engines/$1-$2-$3-BPE

	TESTOUT=$ENGINEDIR/data/test.tc.bpe.src.sw.out
	TESTFIN=$TESTOUT.final

	echo "postprocessing..."
	sh 7_postprocess.sh $TESTOUT $TRGLANG
	echo "done."

	REF=/home/shterion/EcoNMT/engines/REF/${src}-${trg}-test.tok.ref.tok
	HYP=$TESTFIN
	echo "evaluating..."
	sh 8_eval_single.sh $REF $TRGLANG $HYP >> $4
	echo "done."

}

OUTFILE=$1;
echo "BLEU TER" > $OUTFILE;

for i in EN FR ES; 
do 
	for j in FR ES EN; 
	do 
		if [ ! $i = $j ] && ( [ $j = EN ] || [ $i = EN ] ); 
		then
			for k in LSTM TRANS;
			do
				eval $i $j $k $OUTFILE; 
			done;
		fi; 
	done; 
done;
