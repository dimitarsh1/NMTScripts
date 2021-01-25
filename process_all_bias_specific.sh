#!/bin/bash
src=en
for trg in es fr
do
    for MOD in LSTM TRANS
    do
        ./7_postprocess.sh /media/barracuda4tb/dimitarsh1/Projects/BiasNMT/data/TRANSLATIONS-BPE-NEW/test-${src}-${trg}-${MOD}-BPE.out ${trg} 
        ./7_postprocess.sh /media/barracuda4tb/dimitarsh1/Projects/BiasNMT/data/TRANSLATIONS-BPE-NEW/test-${src}-${trg}-${MOD}-BPE.back.out ${trg} 
    done
done

trg=en
for src in es fr
do
    for MOD in LSTM TRANS
    do
        ./7_postprocess.sh /media/barracuda4tb/dimitarsh1/Projects/BiasNMT/data/TRANSLATIONS-BPE-NEW/test-${src}-${trg}-${MOD}-BPE.out ${trg} 
        ./7_postprocess.sh /media/barracuda4tb/dimitarsh1/Projects/BiasNMT/data/TRANSLATIONS-BPE-NEW/test-${src}-${trg}-${MOD}-BPE.back.out ${trg} 
    done
done


