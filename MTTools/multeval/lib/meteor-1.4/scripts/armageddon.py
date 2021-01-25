#!/usr/bin/env python

# Tune Meteor parameters quickly using Sun Grid Engine
# Script submits 21 job array, 1 cpu / 3gb each

import os, subprocess, sys

SGE_SCRIPT = '''
### Job name: m.xx
#$ -N "m.{0}"

### Log files go in the log dir
#$ -e {2}/m.err
#$ -o {2}/m.out

### Just one slot
#$ -pe smp 1

### 2g for Java heap, 1g extra for JVM
#$ -l h_vmem=3g

### 24h should be enough for very large data sets (WMT09/10 English combined).
#$ -l h_rt=24:00:00

### Job array: 21 tasks
#$ -t 1-21

### Call the script for this job
echo "start: `date`"
bash {1}/script.$SGE_TASK_ID.sh
echo "finish: `date`"
'''

SORT_SCRIPT ='''
#!/usr/bin/env bash
cat {0}/output.* | sort -g > {0}/output.sort
'''

def main(argv):
    
    if len(argv[1:]) < 7:
        print 'usage: {0} <meteor.jar> <lang> <n_mods> <paraphrase.gz> <task> <data_dir> <work_dir> [b_min b_max d_min d_max] [other args like -ch]'.format(argv[0])
        sys.exit(1)
    
    # Args
    meteor_jar = os.path.abspath(argv[1])
    lang = argv[2]
    n_mods = int(argv[3])
    paraphrase_gz = os.path.abspath(argv[4])
    task = argv[5]
    data_dir = os.path.abspath(argv[6])
    work_dir = os.path.abspath(argv[7])
    log_dir = os.path.join(work_dir, 'log')
    script_dir = os.path.join(work_dir, 'script')
    sb_dir = os.path.join(work_dir, 'sandbox')
    b_min = argv[8] if len(argv[1:]) > 7 else '0'
    b_max = argv[9] if len(argv[1:]) > 8 else '2.0'
    d_min = argv[10] if len(argv[1:]) > 9 else '0.4'
    d_max = argv[11] if len(argv[1:]) > 10 else '0.9'
    other_args = argv[12:]

    # Working dir
    if os.path.exists(work_dir):
        print 'Work dir {0} exists, exiting'.format(work_dir)
        sys.exit(1)
    os.mkdir(work_dir)
    os.mkdir(log_dir)
    os.mkdir(script_dir)
    os.mkdir(sb_dir)

    # Weight ranges for jobs based on mod count
    w_start_list = [1, 0, 0, 0]
    w_end_list = [1, 0, 0, 0]
    for i in range(n_mods):
        w_end_list[i] = 1
    w_start = ''
    w_end = ''
    for i in range(4):
        w_start += str(w_start_list[i]) + ' '
        w_end += str(w_end_list[i]) + ' '
    w_start = w_start.strip()
    w_end = w_end.strip()
    
    # Step is always the same
    step = '0.05 0.10 0.05 0.05 1.0 0.2 0.2 0.2'
    
    # Write out Trainer job scripts
    for i in range(21):
        script_file = os.path.join(script_dir, 'script.{0}.sh'.format(i + 1))
        sb_sub_dir = os.path.join(sb_dir, '{0}'.format(i + 1))
        os.mkdir(sb_sub_dir)
        out_file = os.path.join(work_dir, 'output.{0}'.format(i + 1))
        a = 0.05 * i
        # If optimal parameters include b=2.0 or d={0.4,0.9}, pass b/d args
        # to script to explore additional area in those directions (one
        # direction per run)
        start = '{0} {1} 0 {2} {3}'.format(a, b_min, d_min, w_start)
        end = '{0} {1} 1 {2} {3}'.format(a, b_max, d_max, w_end)
        trainer_cmd = 'java -XX:+UseCompressedOops -Xmx2G -cp {0} Trainer {1} {2} -l {3} -a {4} -i \'{5}\' -f \'{6}\' -s \'{7}\' {args} > {8}'.format(meteor_jar, task, data_dir, lang, paraphrase_gz, start, end, step, out_file, args=' '.join(other_args))
        o = open(script_file, 'w')
        print >> o, '#!/usr/bin/env bash'
        print >> o, 'if [[ -e {0} ]] ; then exit ; fi'.format(out_file)
        print >> o, 'cd {0}'.format(sb_sub_dir)
        print >> o, trainer_cmd
        o.close()

    # Sort script
    sort_script_file = os.path.join(work_dir, 'sort_output.sh')
    o = open(sort_script_file, 'w')
    print >> o, SORT_SCRIPT.format(work_dir).strip()
    o.close()
    os.chmod(sort_script_file, 0755)

    # SGE Script
    sge_script_file = os.path.join(script_dir, 'sge-script.sh')
    o = open(sge_script_file, 'w')
    print >> o, SGE_SCRIPT.format(lang, script_dir, log_dir)
    o.close()
    subprocess.call(['qsub', sge_script_file])

    # Report
    print ''
    print 'Trainer jobs submitted, output written to:'
    print work_dir
    print ''
    print 'After all jobs finish, sort results:'
    print sort_script_file
    print ''

if __name__ == '__main__' : main(sys.argv)
