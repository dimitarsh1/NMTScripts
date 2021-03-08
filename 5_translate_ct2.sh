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
MODELDIR=$2

SCRIPTPATH=$( cd $( dirname $( readlink -f $0 ) ) && pwd )
OPENNMT=${SCRIPTPATH}'/OpenNMT-py'
SUBWORDTools=${SCRIPTPATH}/"MTTools"/"subword-nmt"

INPUT=$1

CUDA_VISIBLE_DEVICES=0,1,2


echo $SKIPBPE
if [ "$SKIPBPE" -eq "0" ];
then
    $SUBWORDTools/apply_bpe.py -c $DATADIR/bpe.src < $INPUT > ${INPUT}.sw
    INPUT=${INPUT}.sw
fi

echo $INPUT
OUTPUT=${INPUT}.${SUFFIX}out

echo "Launching GPU monitoring"
GPUMONPID=$( nvidia-smi dmon -i ${GPUID} -s mpucv -d 5 -o TD > $ENGINEDIR/model/gpu_trans_ct2${SUFFIX}.log & )
rm $ENGINEDIR/model/power_log_trans_ct2${SUFFIX} -rf
mkdir $ENGINEDIR/model/power_log_trans_ct2${SUFFIX}
python power_monitor.py $ENGINEDIR/model/power_log_trans_ct2${SUFFIX} &
POWERMONPID=$!


echo 'Launching translation on GPU ' $GPUID
python3 5_translate_ct2.py \
    --model-dir $MODELDIR \
    --gpuid ${GPUID} \
    --input ${INPUT} \
    --output ${OUTPUT}

kill -s 9 $GPUMONPID
kill $POWERMONPID

echo "Done."

