#!/bin/bash
SRCFNAME=$1
TRGFNAME=$2

PATTERN='^$'

if [ ! -z $3 ]
then
    PATTERN=$3
fi

LINES=$( grep -n $PATTERN $SRCFNAME | cut -d ':' -f 1 )
LINES=$( echo $LINES | sed -e 's/ /d\;/g' )

LINESTODEL=$( echo $LINES'd'  )
echo $LINESTODEL

sed -i.bak -e $LINESTODEL $SRCFNAME
wc -l $SRCFNAME
sed -i.bak -e $LINESTODEL $TRGFNAME
wc -l $TRGFNAME
