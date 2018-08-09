#!/usr/bin/python 
import pandas as pd
import numpy as np
import os
import sys
import csv
csv.field_size_limit(sys.maxsize)


tempPath=str(sys.argv[1])
assignProFilename=str(sys.argv[2])
originalFile=str(sys.argv[3]) #with path included  #this is the combined result from quant+indentification

Header=str("charge\tscan\tfilename\texpect\tpeptide\tmodifications\tRI@114.1112\tRI@115.1083\tRI@116.1116\tRI@117.1150\tproteins\tstart_aa\tfragment\tfragment_type\tmgf_file")
if len(sys.argv)>4:
	HeaderBoolean=sys.argv[4]


filePrefix=os.path.basename(originalFile)[:-4]

df=pd.read_table(open(tempPath+'/'+assignProFilename, 'rU'), engine='python', header=None)
df.columns=['pep', 'protein', 'infor']

df['wraped_protein'] = df[['pep','protein']].groupby(['pep'])['protein'].transform(lambda x: ','.join(x))
df['infor']=np.array(map(str, df['infor']))
df['wrapped_start_aa'] =df[['pep','infor']].groupby(['pep'])['infor'].transform(lambda x: ','.join(x))

df_final=df[['pep','wraped_protein','wrapped_start_aa']].drop_duplicates()

original=pd.read_table(open(originalFile, 'rU'), engine='python')

original_protein=original.merge(df_final, left_on='seq', right_on='pep', how='inner')
#original_protein=original.merge(df_final, left_on='seq', right_on='pep', how='left')
original_protein=original_protein.drop('protein', 1)
original_protein=original_protein.drop('pep', 1)

if 'start_aa' in original_protein.columns:
	original_protein=original_protein.drop('start_aa', 1)

Path=os.path.dirname(tempPath)

original_protein['fragment']=20
original_protein['fragment_type']='ppm'
original_protein['mgf_file']=os.path.dirname(Path)

if HeaderBoolean=='F':
	np.savetxt(Path+'/'+filePrefix+'.reassignProtein.txt', original_protein, delimiter='\t', fmt="%s")
else:
	np.savetxt(Path+'/'+filePrefix+'.reassignProtein.txt', original_protein, delimiter='\t', fmt="%s", header=Header)





