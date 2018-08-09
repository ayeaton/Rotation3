import sys, os
from os import listdir
import pandas as pd
import numpy as np
print 'module loaded'

if len(sys.argv)>1:
	dir = str(sys.argv[1]) #directory with python codes, like mass.py mgf.py
if len(sys.argv)>2:
	MGFdir=str(sys.argv[2]) 

outputdir=MGFdir+'pipeline_ident_quant_combined/'
if len(sys.argv)>3:
	outputdir=MGFdir+str(sys.argv[3])
if len(sys.argv)>4:
	HeaderBoolean=str(sys.argv[4])


subdir=outputdir+'quality_table/'

if not os.path.exists(subdir):
    os.makedirs(subdir)

MGFconvertor=pd.read_table(MGFdir+'MGF_filename.txt')
for filename in listdir(outputdir):
    if filename.endswith('.reassignProtein.txt'):
        with open(outputdir + filename) as table:
	    print 'found reassignProtein file'
            df = pd.read_table(table)
	    df=df.drop(['mgf_file'], axis=1)
            print(df['filename'][1])
	    df=df.merge(MGFconvertor, left_on='filename', right_on='mgf_filename', how='inner')
            print(df)
	    df=df.drop(['mgf_filename'], axis=1)
	    uniqMGF=list(set(df['mgf_file']))
            print(uniqMGF)
	    for i in uniqMGF:
		MGFfilename=i.split('/')[-1]
		f=open(subdir+MGFfilename+'.sh','w')
            	f.write('#! /bin/bash\n')
                f.write('#$ -cwd -S /bin/bash\n\n')
                f.write('module load python/2.7.3\n\n') ##module load, remember remove previous *pyc files
                f.write('##pythondir=/ifs/home/wangx13/miniconda2/bin\n\n')
		f.write('python '+str(dir)+'extract_quality_psm_draw.py '+str(outputdir+filename)+' '+str(i)+' '+ str(subdir)+' '+str(MGFdir)+'MGF_filename.txt '+HeaderBoolean +'\n')
                f.close()
                os.chdir(subdir)
                os.system('qsub -q all.q -hard -l mem_free=3G '+subdir+MGFfilename+'.sh')
                
            
            
