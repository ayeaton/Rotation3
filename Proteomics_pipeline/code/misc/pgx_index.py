#!/usr/bin/python
__author__ = 'manor'

import time

start = time.time()

import cPickle
import sys
import os

def index(proteome,q=4):
    proteins = {}
    peptides = {}
    acc = ""
    code = 0
    f = open(proteome + "/proteome.fasta")
    for l in f:
        if l.startswith(">"):
            vals = l.split(" ")
            acc = vals[0][1:]
        else:
            code += 1
            seq = l.strip()
            proteins[code] = (acc,seq)
            for i in range(len(seq)-q+1):
                pep = seq[i:i+q].replace('L','I')
                if not peptides.has_key(pep):
                    peptides[pep] = set()
                peptides[pep].add(code)
    db_name = proteome + "/proteome.pickle"
    f = open(db_name,'wb')
    cPickle.dump(q,f)
    cPickle.dump(proteins,f)
    cPickle.dump(peptides,f)
    f.close()
	
if len(sys.argv)>0:
    default_path='/ifs/data/proteomics/tcga/databases'
    f = open(os.path.abspath(os.path.dirname(sys.argv[0]))+'/settings.txt')
    for l in f:
        (key,value) = l.strip().split('=')
        if key=='default_path':
            default_path=value
    f.close()
    proteome = sys.argv[1]
    if not '/' in proteome:
        proteome = default_path + '/' + proteome
    if not os.path.isdir(proteome):
        print "%s not found" % (proteome)
        sys.exit(-1)
    if not os.path.isfile(proteome+'/proteome.fasta'):
        print "%s/proteome.fasta not found" % (proteome)
        sys.exit(-1)
    index(proteome)
else:
    print "usage: pgx_index.py proteome"

stop = time.time()

print "Indexing finished in %.2f seconds" % (stop-start)
