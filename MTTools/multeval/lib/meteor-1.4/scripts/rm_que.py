#!/usr/bin/env python

import gzip, sys

if len(sys.argv[1:]) < 2:
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
    if 'que' in (p1.strip(), p2.strip()):
        print 'bad:'
        print p1,
        print p2,
        continue
    f_out.write(prob)
    f_out.write(p1)
    f_out.write(p2)

f_in.close()
f_out.close()
