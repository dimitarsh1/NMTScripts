#!/usr/bin/env python

import codecs, os, shutil, subprocess, sys, tempfile

mteval_pl = os.path.join(os.path.dirname(os.path.dirname(__file__)),
  'mt-diff', 'files', 'mteval-v13m.pl')

def main(argv):
    
    if len(argv[1:]) < 2:
        print 'Score with NIST BLEU'
        print ''
        print 'usage: {0} <hyp> <ref> [opts]'.format(argv[0])
        print ''
        print '-------------------'
        print 'Options for scoring'
        print '-------------------'
        print ''
        subprocess.call(['perl', mteval_pl, '-h'])
        sys.exit(1)
    
    hyp = argv[1]
    ref = argv[2]
    opts = argv[3:]
    
    src_sgm = tempfile.mktemp(suffix='.sgm')
    tst_sgm = tempfile.mktemp(suffix='.sgm')
    ref_sgm = tempfile.mktemp(suffix='.sgm')
    
    sgm(ref, src_sgm, 'srcset')
    sgm(hyp, tst_sgm, 'tstset')
    sgm(ref, ref_sgm, 'refset')

    cmd = ['perl', mteval_pl, '-s', src_sgm, '-t', tst_sgm, '-r', ref_sgm]
    for opt in opts:
        cmd.append(opt)
    subprocess.call(cmd)
    
    os.remove(src_sgm)
    os.remove(tst_sgm)
    os.remove(ref_sgm)

def sgm(f_in, f_out, f_type):
    i = open(f_in)
    o = open(f_out, 'w')
    s = 0
    print >> o, '<{0} trglang="trg" setid="set" srclang="src">'.format(f_type)
    print >> o, '<doc docid="doc" sysid="sys">'
    for line in i:
        s += 1
        print >> o, '<seg id="{0}"> {1} </seg>'.format(s, line.strip())
    print >> o, '</doc>'
    print >> o, '</{0}>'.format(f_type)
    i.close()
    o.close()

if __name__ == '__main__' : main(sys.argv)
