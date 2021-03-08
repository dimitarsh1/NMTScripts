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
    SFX=$SUFFIX
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

echo 'Launching translation server on GPU ' $GPUID
python3 $OPENNMT/server.py \
    --config=$MODELDIR/server_config.json \
    --ip="0.0.0.${GPUID}" \
    --port="5000" &

rm ${OUTPUT}
while read -r line
do 
	#echo $line;
	curl --fail --silent -X POST -H "Content-Type: application/json" -d "[{\"src\":\"${line}\", \"id\":0}]" http://0.0.0.${GPUID}:5000/translator/translate | jq '.[0]."tgt"' >> ${OUTPUT};
done < ${INPUT}

echo $GPUMONPID
echo $POWERMONPID

kill -s 9 $GPUMONPID
kill -s 9 $POWERMONPID

echo "Done."

