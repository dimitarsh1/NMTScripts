#!/usr/bin/env python

import os, subprocess, sys

# Output line:
# P R f1 frag

# Unigrams, surface forms only
# Params set so frag = (chunks/matches)

def main(argv):
    
    if len(argv) < 2:
        print 'usage: {0} hyps refs > f1.out'.format(argv[0])
        sys.exit(1)
    
    hyp = argv[1]
    ref = argv[2]
    
    rc = wc(ref) / wc(hyp)
    
    cmd = ['java', '-Xmx2G', '-jar',
      os.path.dirname(__file__) + '/../meteor-1.2.jar', hyp, ref, '-r', str(rc),
      '-normalize', '-m', 'exact', '-p', '0.5 1 1 0.5']
    
    p = subprocess.Popen(cmd, stderr=subprocess.PIPE, stdout=subprocess.PIPE)
    
    while True:
        line = p.stdout.readline()
        if line.startswith('Precision'):
            P = float(line.split()[-1]) * 100
        if line.startswith('Recall'):
            R = float(line.split()[-1]) * 100
        if line.startswith('f1'):
            f1 = float(line.split()[-1]) * 100
        if line.startswith('Fragmentation'):
            frag = float(line.split()[-1]) * 100
        if not line:
            break
    
    print '{0:5.2f} {1:5.2f} {2:5.2f} {3:5.2f}'.format(P, R, f1, frag)

def wc(f):
    i = 0
    f_in = open(f, 'r')
    while True:
        line = f_in.readline()
        if not line:
            break
        i += 1
    f_in.close()
    return i

if __name__ == '__main__' : main(sys.argv)
