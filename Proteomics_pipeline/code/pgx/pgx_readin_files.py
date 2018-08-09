#!/usr/bin/python 
import pandas as pd
import numpy as np
import os
import sys
import re
import csv
PATH=str(sys.argv[1])
filename=str(sys.argv[2])

csv.field_size_limit(sys.maxsize)

df = pd.read_table(open(PATH+'/'+filename, 'rU'), engine='python')
pepseq=df['seq'].unique()

print(pepseq)
print(PATH+'/'+filename)

os.chdir(PATH+'/'+'temp')

output_name=re.sub('.txt', '', filename)
print(output_name)
print(PATH+'/'+'temp')
np.savetxt(output_name+'.peptideList.csv', pepseq, delimiter=',', fmt="%s")


