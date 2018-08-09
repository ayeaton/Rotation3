import sys, os
from pandas import Series, DataFrame
import pandas as pd
import numpy as np
import re
import fnmatch
import glob
from os import listdir
import os
print 'module loaded'

if len(sys.argv)>1:
	mgf_dir = str(sys.argv[1])

sub_dir=mgf_dir+'pipeline_ident_quant_combined/quality_table/'
files = glob.glob(sub_dir+"*.out") 

print(files)

header_saved = False
prefix=os.path.basename(mgf_dir[:-1])
prefix='allfraction.'+prefix+'.reassignProtein'
outputfolder='/'.join(sub_dir.split('/')[:-2])
with open(outputfolder+'/'+prefix+'.qualFeature'+'.txt','wb') as fout:
    for filename in files:
        with open(filename) as fin:
            header = next(fin)
            if not header_saved:
                fout.write(header)
                header_saved = True
            for line in fin:
                fout.write(line)
