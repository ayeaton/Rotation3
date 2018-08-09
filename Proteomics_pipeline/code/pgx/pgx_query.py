#!/usr/bin/python

__author__ = 'manor'

import cPickle
import sys
import os
import time

#This is evil. Will object-orient it later...
q = 0
proteins = None
peptides = None

def load_db(proteome):
    global proteins
    global peptides
    global q
    import cPickle
    f = open(proteome + '/proteome.pickle','rb')
    q = cPickle.load(f)
    proteins = cPickle.load(f)
    peptides = cPickle.load(f)
    f.close()

import re
def lookup(aPeptide):
    global q
    global peptides
    global proteins

    target = aPeptide.replace("L","I")
    output = []

    if peptides.has_key(target[0:q]):
        candidates = peptides[target[0:q]]
        for i in range(1,len(target)-q+1):
            if peptides.has_key(target[i:i+q]):
                candidates = candidates.intersection(peptides[target[i:i+q]])
            else:
                candidates = set()
                break
    else:
        candidates = set()

    for code in candidates:
        #Obviously, the proteins should be pre-I/L transformed...
        transeq = proteins[code][1].replace("L","I")
        for m in re.finditer(target,transeq):
            output.append( (proteins[code][0],m.start()+1) )
    return output

def main(pep_file,proteome):
    start = time.time()
    load_db(proteome)
    f = open(pep_file)
    for l in f:
        pep = l.strip().split()[0].upper()
        matches = lookup(pep)
        for match in matches:
            print "%s\t%s\t%d" % (pep,match[0].rstrip(),match[1])
    f.close()
    stop = time.time()
    print >> sys.stderr, "Query processed in %.2f seconds." % (stop-start)

if __name__ == '__main__':
    if len(sys.argv) < 2 :
        print "usage: pgx_query.py peptides proteome"
        sys.exit(-1)
    default_path='/ifs/data/proteomics/tcga/databases/'
    f = open(os.path.abspath(os.path.dirname(sys.argv[0]))+'/settings.txt')
    for l in f:
        (key,value) = l.strip().split('=')
        if key=='default_path':
            default_path=value
    f.close()
    pep_file = sys.argv[1]
    proteome = sys.argv[2]
    if not '/' in proteome:
        proteome = default_path + '/' + proteome
    if not os.path.isdir(proteome):
        print "%s not found" % (proteome)
        sys.exit(-1)
    if not os.path.isfile(proteome+'/proteome.pickle'):
        print "%s/proteome.pickle not found" % (proteome)
        sys.exit(-1)
    if not os.path.isfile(pep_file):
        print "%s not found" % (pep_file)
        sys.exit(-1)
    if os.path.getsize(pep_file)==0:
        print "%s is empty" % (pep_file)
        sys.exit(-1)
    main(pep_file,proteome)
