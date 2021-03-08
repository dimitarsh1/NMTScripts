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
    SFX = ''
else
    SFX=_$SUFFIX
    SUFFIX=${SUFFIX}'.'
fi


if [ -z $GPUID ]
then
    export GPUID=0
fi

DATADIR=$ENGINEDIR/data
MODELDIR=$ENGINEDIR/model

SCRIPTPATH=$( cd $( dirname $( readlink -f $0 ) ) && pwd )
OPENNMT=${SCRIPTPATH}'/OpenNMT-py'
SUBWORDTools=${SCRIPTPATH}/"MTTools"/"subword-nmt"

INPUT=$1

CUDA_VISIBLE_DEVICES=0,1,2


echo $SKIPBPE
if [ "$SKIPBPE" -eq "0" ];
then
    echo "BPEing"
    echo $DATADIR
    echo $INPUT
    $SUBWORDTools/apply_bpe.py -c $DATADIR/bpe.src < $INPUT > ${INPUT}.sw
    INPUT=${INPUT}.sw
fi

echo $INPUT
OUTPUT=${INPUT}.server.${SUFFIX}out

echo "Launching GPU monitoring"
GPUMONPID=$( nvidia-smi dmon -i ${GPUID} -s mpucv -d 1 -o TD > $MODELDIR/gpu_trans_server${SUFFIX}log & )
python power_monitor.py $MODELDIR/power_log_trans_server${SFX} &
POWERMONPID=$!

cat ${INPUT} | parallel -k -j 10 'curl --fail --silent -X POST -H "Content-Type: application/json" -d "[{\"src\":\"{}\", \"id\":${GPUID}}]" http://0.0.0.0:5000/translator/translate | jq '.[0]."tgt"'' > ${OUTPUT}

echo $GPUMONPID
echo $POWERMONPID

kill $GPUMONPID
kill $POWERMONPID

echo "Done."

