#!/bin/bash
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

if [ ! -z $SKIPBPE ]
then
    SKIPBPE=1
else
    SKIPBPE=0
fi

if [ -z $SUFFIX ]
then
    SUFFIX=''
else
    SUFFIX=${SUFFIX}'.'
fi


if [ -z $GPUID ]
then
    GPUID=0
fi

DATADIR=$ENGINEDIR/data
MODELDIR=$ENGINEDIR/model

SCRIPTPATH=$( cd $( dirname $( readlink -f $0 ) ) && pwd )
OPENNMT=${SCRIPTPATH}'/OpenNMT-py'
SUBWORDTools=${SCRIPTPATH}/"MTTools"/"subword-nmt"

INPUT=$1

CUDA_VISIBLE_DEVICES=0,1,2,3


echo $SKIPBPE
if [ "$SKIPBPE" -eq "0" ];
then
    $SUBWORDTools/apply_bpe.py -c $DATADIR/bpe.src < $INPUT > ${INPUT}.sw
    INPUT=${INPUT}.sw
fi

echo $INPUT
OUTPUT=${INPUT}.${SUFFIX}out

echo "Launching GPU monitoring"
GPUMONPID=$( nvidia-smi dmon -i 0,1,2,3 -s mpucv -d 5 -o TD > $MODELDIR/gpu_trans.log & )

A=$( grep 'Best' $MODELDIR/train.log | rev | cut -d ' ' -f 1 | rev )
B=$( grep -B4 ${A}'.pt' $MODELDIR/train.log | head -2 | rev | cut -d ' ' -f 1 | rev | tr '\n' '_' | sed -e 's/_$//g')

MODELNAME='model_step_'${A}'.pt'

echo 'Saving best model: ' $MODELNAME

BESTMODEL=best_model_${A}_${B}.pt
cp $MODELDIR/${MODELNAME} $MODELDIR/${BESTMODEL}

echo 'Launching translation on GPU ' $GPUID
python3 $OPENNMT/translate.py \
    --model $MODELDIR/${BESTMODEL} \
    --gpu ${GPUID} \
    --src ${INPUT} \
    --output ${OUTPUT}

kill -s 9 $GPUMONPID

echo "Done."

