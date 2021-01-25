#!/bin/bash
# validate.sh
REF=$1
TRGLANG=$2
HYP="${@:3}"

MTTools=$( dirname $0 )
MTTools=${MTTools}/MTTools

if [ ! -f $REF.eval.tok ]
then
	$MTTools/tokenizer.perl -l $TRGLANG < $REF > $REF.eval.tok
fi

RES_OUT=${REF}_multeval_results.out
echo "Reference: "$REF > ${RES_OUT}

HYPS=$( echo $HYP | tr " " "\n" )
echo $HYPS

for hyp in ${HYPS}
do
	echo $hyp
	if [ ! -f $hyp.eval.tok ]
	then
		$MTTools/tokenizer.perl -l $TRGLANG < $hyp > $hyp.eval.tok
	fi
done

HYPOTHESES=$( echo "$HYP" | sed 's/ /.eval.tok /g' ).eval.tok

#A=$( for a in {1..3}; do b=$(( $a - 1 )); echo "--hyps-sys"$b" "; echo $HYPOTHESES | cut -d " " -f ${a}; done )
A=$( for a in {1..3}; do echo "--hyps-sys"$a" "; echo $HYPOTHESES | cut -d " " -f ${a}; done )

HYPOTHESES_SYS=$( echo $A | tr -d '\n' ) #| sed -e 's/sys0/baseline/' )


echo "Hypotheses: "$HYPOTHESES_SYS >> ${RES_OUT}

HYP=$( echo ${HYPS} | cut -d " " -f 1 )
echo $HYP

MULTEVAL=$( cd ${MTTools}/multeval; ./multeval.sh eval --refs ${REF}.eval.tok --hyps-baseline ${REF}.eval.tok $HYPOTHESES --metrics bleu ter --boot-samples 1000 )
echo "Results (Ref): "$MULTEVAL >> ${RES_OUT}

for hyp in ${HYPS}
do
	for hyp2 in ${HYPS}
	do
		if [ ! $hyp = $hyp2 ]
		then
			MULTEVAL=$( cd ${MTTools}/multeval; ./multeval.sh eval --refs ${REF}.eval.tok --hyps-baseline ${hyp}.eval.tok --hyps-sys1 ${hyp2}.eval.tok --metrics bleu ter --boot-samples 1000 )
			#MULTEVAL=$( cd ${MTTools}/multeval; ./multeval.sh eval --refs ${REF}.eval.tok --hyps-baseline ${hyp}.eval.tok $HYPOTHESES --metrics bleu ter --boot-samples 1000 )
			NAME1=$( echo -n $hyp | rev | cut -d "/" -f 1 | rev )
			NAME2=$( echo -n $hyp2 | rev | cut -d "/" -f 1 | rev )
			echo "$NAME1 $NAME2 "$MULTEVAL >> ${RES_OUT}
		fi
	done
done

#MULTEVAL=$( cd ${MTTools}/multeval; ./multeval.sh eval --refs ${REF}.eval.tok --hyps-baseline ${HYP}.eval.tok --metrics bleu ter --boot-samples 1000 | grep baseline )
