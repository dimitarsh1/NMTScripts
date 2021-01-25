#!/bin/bash
INPUT=$1
TRGLANG=$2

export TRGLANG=$TRGLANG

MTTools=$( dirname $0 )
MTTools=$MTTools/"MTTools"

$MTTools/postprocess.sh < $INPUT > $INPUT.final
