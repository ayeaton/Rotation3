import sys, os
import pandas as pd
import numpy as np
import mass
import mgf
import matplotlib
matplotlib.use('agg') 
import matplotlib.pyplot as plt

if len(sys.argv)>1:
	table = str(sys.argv[1])
if len(sys.argv)>2:
	mgf_file = sys.argv[2]
if len(sys.argv)>3:
	subdir=sys.argv[3]
if len(sys.argv)>4:
	MGFconvertor=sys.argv[4]
if len(sys.argv)>5:
	headerBoolean=sys.argv[5]

MGFconvertor=pd.read_table(MGFconvertor)
df = pd.read_table(table)
df.rename(columns={'# charge': 'charge'}, inplace=True)
df=df.drop(['mgf_file'], axis=1)
df=df.merge(MGFconvertor, left_on='filename', right_on='mgf_filename', how='inner')
df=df.drop(['mgf_filename'], axis=1)

mgf_prefix=mgf_file.split('/')[-1]
fh=open(subdir+mgf_prefix[:-4]+'.out','w')
if headerBoolean=='ITRAQ4pro':
	fh.write('filename\tscan\tpeptide\texpect\tstart_aa\tmodifications\tRI.114.1112\tRI.115.1083\tRI.116.1116\tRI.117.1150\tproteins\tcharge\tfragment\tfragment_type\tmgf_file\tmass\tmatched_intensity\tlargest_gap_per\tpep_length\n')
elif headerBoolean=='ITRAQ4phospho':
	fh.write('peptide\tmodifications\tcharge\texpect\tscan\tintensity\tfilename\tproteins\tstart_aa\tfragment\tfragment_type\tmgf_file\tmass\tmatched_intensity\tlargest_gap_per\tpep_length\n')


masses={}
mass.get_masses(masses)

max_peaks_per_scan = 10000
mgf_table={}
mgf_pepmass={}
mgf_charge={}
mgf_title={}
mgf_scan=[]
mgf_scan_selected=[]
mgf_time={}
print 'Reading mgf file ', mgf_file, '...'
mgf.read(mgf_table, mgf_pepmass, mgf_charge, mgf_title, mgf_scan, mgf_time, mgf_file, max_peaks_per_scan)
print 'Done reading mgf file ', mgf_file

for idx in df.index:
    if df['mgf_file'].ix[idx]==mgf_file:
        scan_str=str(df['scan'].ix[idx])
        #mgf_charge[scan_str]=int(df['charge'].ix[idx])
        
	if scan_str in mgf_pepmass:
            #print 'find scan'
	    fragments=[]
            pep=df['peptide'].ix[idx]
            mod=''
            if not(str(df['modifications'].ix[idx])=='nan' or str(df['modifications'].ix[idx])==''):
                mod=df['modifications'].ix[idx]
            charge=int(df['charge'].ix[idx])
            check_gaps_at=[]
            mass.calc_peptide_fragments(fragments, pep, mod,charge, 'by', masses)
            for c in range(charge,0,-1):
                mass_ion_t=(mass.calc_peptide_mass(pep, mod, masses)+c*masses['Proton'])/(1.0*c),'[M+H]+'+str(c)
                fragments.append(mass_ion_t)
                if '144.102' in mod:
                    mass_ion_t=(mass.calc_peptide_mass(pep, mod, masses)-144.10207+c*masses['Proton'])/(1.0*c),'[M+H-iTRAQ]+'+str(c)
                    fragments.append(mass_ion_t)
                for l in range(1,3,1): #deamination and dehydration (1-2)
                    l_text=''
                    if l>1:
                        l_text=str(l)+'*'
                    mass_ion_t=(mass.calc_peptide_mass(pep, mod, masses)-l*masses['H2O']+c*masses['Proton'])/(1.0*c),'[M+H-'+l_text+'H2O]+'+str(c)
                    fragments.append(mass_ion_t)
                    mass_ion_t=(mass.calc_peptide_mass(pep, mod, masses)-l*masses['NH3']+c*masses['Proton'])/(1.0*c),'[M+H-'+l_text+'NH3]+'+str(c)
                    fragments.append(mass_ion_t)
            mgf_pepmatch_ions = []
            sequence_evidence_b = np.zeros(len(pep))
            sequence_evidence_y = np.zeros(len(pep))
            mz_error_fragment=float(df['fragment'].ix[idx])
            mz_error_fragment_type=df['fragment_type'].ix[idx]
            mz_error_precursor=300.0
            mz_error_precursor_type='ppm'
            if mz_error_fragment_type=='ppm':
                if mz_error_fragment==60:
                    mz_error_fragment=100.0
                    mz_error_precursor=600.0
                else:
                    mz_error_fragment=20.0
            else:
                mz_error_fragment=0.8
                mz_error_precursor=mz_error_fragment
                mz_error_precursor_type=mz_error_fragment_type
        
        	#calculate percent of matched intensity#
            frag_mz_min=200
            frag_mz_max=0
            frag_int_max=0
            frag_int_sum=0            
            matched_intensity,matched_intensity_parent,matched_intensity_not_parent=mgf.select_fragments_scan(scan_str, frag_mz_min, mgf_pepmatch_ions, sequence_evidence_b,sequence_evidence_y, fragments, mz_error_precursor, mz_error_precursor_type, mz_error_fragment, mz_error_fragment_type, max_peaks_per_scan, mgf_table)    
            for (frag_mz_exp,frag_int) in mgf_table[scan_str]:
                if frag_mz_exp>frag_mz_min:
                    frag_int_sum+=frag_int
        	#calculate percent of matched intensity#
        				
            largest_gap=0
            gap=0
        		
            for k in range(len(pep)-1):
                if sequence_evidence_b[k]>0 or sequence_evidence_y[len(pep)-2-k]>0:
                    gap=0
                else:
                    gap+=1
                    if largest_gap<gap:
                        largest_gap=gap
            gaps_at=[]
            for check_gap_at in check_gaps_at:
                gap_at=0
                done=0
                for k in range(check_gap_at-1,len(pep)-1,1):
                    if done==0:
                        if sequence_evidence_b[k]>0 or sequence_evidence_y[len(pep)-2-k]>0:
                            done=1
                        else:
                            gap_at+=1
                done=0
                for k in range(check_gap_at-1-1,-1,-1):
                    if done==0:
                        if sequence_evidence_b[k]>0 or sequence_evidence_y[len(pep)-2-k]>0:
                            done=1
                        else:
                            gap_at+=1
                gaps_at.append(gap_at)
        	
	    ## writing quality table ##
	    #print 'writing quality table..'
	    if headerBoolean=='ITRAQ4pro':
	        fh.write(str(df['filename'].ix[idx])+'\t'+scan_str+'\t'+pep+'\t'+str(df['expect'].ix[idx])+'\t'+str(df['start_aa'].ix[idx])+'\t'+mod+'\t'+str(df['RI@114.1112'].ix[idx])+'\t'+str(df['RI@115.1083'].ix[idx])+'\t'+str(df['RI@116.1116'].ix[idx])+'\t'+str(df['RI@117.1150'].ix[idx])+'\t'+str(df['proteins'].ix[idx])+'\t'+str(charge)+'\t'+str(df['fragment'].ix[idx])+'\t'+str(df['fragment_type'].ix[idx])+'\t'+str(df['mgf_file'].ix[idx])+'\t'+str(mass.calc_peptide_mass(pep, mod, masses))+'\t'+str(matched_intensity/(1.0*frag_int_sum))+'\t'+str(largest_gap*1.0/(len(pep)-1))+'\t'+str(len(pep))+'\n')
	    elif headerBoolean=='ITRAQ4phospho':
		fh.write(pep+'\t'+mod+'\t'+str(charge)+'\t'+str(df['expect'].ix[idx])+'\t'+scan_str+'\t'+str(df['intensity'].ix[idx])+'\t'+str(df['filename'].ix[idx])+'\t'+str(df['proteins'].ix[idx])+'\t'+str(df['start_aa'].ix[idx])+'\t'+str(df['fragment'].ix[idx])+'\t'+str(df['fragment_type'].ix[idx])+'\t'+str(df['mgf_file'].ix[idx])+'\t'+str(mass.calc_peptide_mass(pep, mod, masses))+'\t'+str(matched_intensity/(1.0*frag_int_sum))+'\t'+str(largest_gap*1.0/(len(pep)-1))+'\t'+str(len(pep))+'\n')

fh.close()
