#!/bin/bash
if [ ! -z $SKIPBPE ]
then
    SKIPBPE=1
else
    SKIPBPE=0
fi

if [ -z $GPUID ]
then
    GPUID=0
fi

if [ -z $SUBWORDTools ]
then
    SUBWORDTools="/media/barracuda4tb/dimitarsh1/Projects/BiasNMT_II/external/NMT/MTTools/subword-nmt"
fi
INPUT=$1
MODEL=$2
SUFFIX=$3

CUDA_VISIBLE_DEVICES=0,1,2,3

OUTPUT=${INPUT}.${SUFFIX}.out

DATADIR=$ENGINEDIR/data

echo "SKIP BPE: " $SKIPBPE
if [ "$SKIPBPE" -eq "0" ];
then
    $SUBWORDTools/apply_bpe.py -c $DATADIR/bpe.src < $INPUT > ${INPUT}.sw
    INPUT=${INPUT}.sw
fi

echo $INPUT
echo "MODEL: " ${MODEL}
echo 'Launching translation on GPU ' $GPUID
python3 $OPENNMT/translate.py \
    --model ${MODEL} \
    --gpu ${GPUID} \
    --src ${INPUT} \
    --output ${OUTPUT}

# This command fixes BPE tokens.
sed -i 's/@@ //g' ${OUTPUT}

echo "Done."

