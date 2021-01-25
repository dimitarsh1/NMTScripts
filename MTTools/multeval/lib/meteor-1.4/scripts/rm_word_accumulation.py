#!/usr/bin/env python

import gzip, sys

if len(sys.argv[1:]) < 2:
    print 'Remove paraphrases with word accumulation:'
    print 'Paraphrases where p1 is a substring of p2 or vice versa will be removed'
    print ''
    print 'usage', sys.argv[0], 'original.gz', 'clean.gz'
    sys.exit(1)

f_in = gzip.open(sys.argv[1])
f_out = gzip.open(sys.argv[2], 'wb')

while True:
    prob = f_in.readline()
    if not prob:
        break
    p1 = f_in.readline()
    p2 = f_in.readline()
    p1s = ' ' + p1.strip() + ' '
    p2s = ' ' + p2.strip() + ' '
    if p1s in p2s or p2s in p1s:
        continue
    f_out.write(prob)
    f_out.write(p1)
    f_out.write(p2)

f_in.close()
f_out.close()
