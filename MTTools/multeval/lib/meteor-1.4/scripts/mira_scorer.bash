#!/usr/bin/env bash

# Workaround for calling Java with VM args from C/C++ 

METEOR=$(dirname $0)/../meteor-*.jar

if [[ $# != 1 ]] ; then
  echo "Runs java -Xmx1536M -jar $METEOR - - -mira -lower -t tune -l lang"
  echo "Usage: $0 lang"
  exit 1
fi

java -Xmx1536M -jar $METEOR - - -mira -lower -t tune -l $1
