#!/bin/bash

ENGINEDIR=$1
INPUT=$2
TRGLANG=$3
NMT=$4
DEVICE=$5

# First let's translate it.
./6_translate.sh $ENGINEDIR $INPUT $NMT $DEVICE

# Now let's postprocess the output
./7_postprocess.sh $INPUT.bpe.out $TRGLANG

