#!/home/dimitarsh1/anaconda3/envs/OpenNMT/bin/python3
# -*- coding: utf-8 -*-

''' reads a text file and exports unique tokens separated by space and their frequencies.
'''
import argparse
import codecs
import os
import itertools
import numpy as np
from lexical_diversity import lex_div as ld
from itertools import combinations
from scipy.stats import ttest_ind
import sacrebleu
from joblib import Parallel, delayed
from mosestokenizer import *
import subprocess

def compute_ter_multeval(sysname, sys, ref, l):
    ''' Getting the ter score of the sample; using external call to multeval)

        :param sysname: the name of the system; to create a directory for sentence-level scores
        :param sys: the sampled sentences from the translation
        :param ref: the reference sentences
        :param l: the langauge for detokenization
        
        :returns: a socre (float)
    '''
    
    rand = str(np.random.randint(100000000))
    tmp_sys_file = 'sys' + rand
    tmp_ref_file = 'ref' + rand
    
    with open(tmp_sys_file, 'w') as of1:
        of1.write('\n'.join(sys))
        
    with open(tmp_ref_file, 'w') as of2:
        of2.write('\n'.join(ref))

    sysname = os.path.join(os.getcwd(), sysname)

    multeval_cmd = ["multeval", "eval", "--refs", os.path.realpath(tmp_ref_file), "--hyps-baseline", os.path.realpath(tmp_sys_file), "--metrics", "ter", "--boot-samples", "1", "--sentLevelDir", sysname, "-t", "0", "2>", "/dev/null"]
    stdout =  subprocess.run(' '.join(multeval_cmd), stdout=subprocess.PIPE, shell=True, encoding='utf-8').stdout
    ter_line = stdout.split("\n")[1]
    ter = ter_line.split()[-2]

    os.remove(tmp_sys_file)
    os.remove(tmp_ref_file)    

    return float(ter)
    

def get_ter(sents, ter, lang):
    ''' Getting the ter score of the sample based on per-sentence ter scores, sentences and overall length)

        :param sents: the sampled sentences (to compute their length)
        :param ter: a ter-score list
        :returns: a socre (float)
    '''
    tot_tokens = 0.0
    tot_errors = 0.0
    for (s, t) in zip(sents, ter):
        ltmp = len(s.split())
        tot_tokens += ltmp
        tot_errors += t*ltmp

    return tot_errors/tot_tokens


def get_bleu(sys, ref, lang):
    ''' Computing BLEU using sacrebleu

        :param sysname: the name of the system
        :param sys: the sampled sentences from the translation
        :param ref: the reference sentences
        :param lang: the langauge for detokenization
        :returns: a socre (float)
    '''
    detokenize = MosesDetokenizer(lang)
    tmp_sys = [detokenize(s.split()) for s in sys]
    tmp_ref = [detokenize(r.split()) for r in ref]
    bleu = sacrebleu.corpus_bleu(tmp_sys, [tmp_ref])
    return bleu.score

def compute_yules_i(sentences):
    ''' Computing Yules I measure

        :param sentences: dictionary with all words and their frequencies
        :returns: Yules I (the inverse of yule's K measure) (float) - the higher the better
    '''
    _total, vocabulary = get_vocabulary(sentences)
    M1 = float(len(vocabulary))
    M2 = sum([len(list(g))*(freq**2) for freq,g in itertools.groupby(sorted(vocabulary.values()))])

    try:
        return (M1*M1)/(M2-M1)
    except ZeroDivisionError:
        return 0

def compute_ttr(sentences):
    ''' Computes the type token ratio
    
        :param sentences: the sentences
    
        :returns: The type token ratio (float)
    '''      

    total, vocabulary = get_vocabulary(sentences)    
    return len(vocabulary)/total
    
def compute_mtld(sentences):
    ''' Computes the MTLD
    
        :param sentences: sentences
    
        :returns: The MTLD (float)
    '''      
    
    ll = ' '.join(sentences)
    return ld.mtld(ll)
    
def get_vocabulary(sentence_array):
    ''' Compute vocabulary

        :param sentence_array: a list of sentences
        :returns: a list of tokens
    '''
    data_vocabulary = {}
    total = 0
    
    for sentence in sentence_array:
        for token in sentence.strip().split():
            if token not in data_vocabulary:
                data_vocabulary[token] = 1 #/len(line.strip().split())
            else:
                data_vocabulary[token] += 1 #/len(line.strip().split())
            total += 1
            
    return total, data_vocabulary

def compute_metric(metric_func, sentences, sample_idxs, iters):
    ''' Computing metric

        :param metric_func: get_bleu or get_ter_multeval
        :param sys: the sampled sentences from the translation
        :param sample_idxs: indexes for the sample (list)
        :param iters: number of iterations
        :returns: a socre (float)
    '''
    # 5. let's get the measurements for each sample
    scores = {}
    scores = Parallel(n_jobs=-1)(delayed(eval(metric_func))([sentences[j] for j in sample_idxs[i]]) for i in range(iters))
             
    return scores

def main():
    ''' main function '''
    # read argument - file with data
    parser = argparse.ArgumentParser(description='Extracts words to a dictionary with their frequencies.')
    parser.add_argument('-f', '--files', required=True, help='the files to read.', nargs='+')

    args = parser.parse_args()

    sentences = {}
    metrics = {'TTR':'compute_ttr', 'Yules': 'compute_yules_i', 'MTLD':'compute_mtld'}
    metrics_bs = {}
    
    length = 0
    
    # 1. read all the file
    for textfile in args.files:
        system = os.path.splitext(os.path.basename(textfile))[0]
        sentences[system] = []
        
        with codecs.open(textfile, 'r', 'utf8') as ifh:
            sentences[system] = [s.strip() for s in ifh.readlines()]
        
        if length == 0:
            length = len(sentences[system])
        
    # 2. Compute overall metrics
    for metric in metrics:
        for sys in sentences:
            print(" ".join([metric, sys, str(eval(metrics[metric])(sentences[sys]))]))

if __name__ == "__main__":
    main()
