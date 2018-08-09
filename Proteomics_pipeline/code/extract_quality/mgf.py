import re
import numpy as np

#Module Usage:
#
# Available functions:
#
# (1) read - reads an mgf file and retrieves scan name, time peptide mass, charge, 
# revised by ZHI LI compatible with different mgf version
#       - arguments: mgf_table, (output, dictionary, keys are the scan name and values are a list of peak (m/z, intensity) (tuples) values read from the file)
#            mgf_pepmass, (output, dictionary, keys are the scan name, values are the pepmass (PEPMASS=...))
#            mgf_charge, (output, dictionary, keys are the scan name, values are the charge (CHARGE=...))
#            mgf_title, (output, dictionary, keys are the scan name, values are the entire title of the scan (TITLE=...))
#            mgf_scan, (output, list, all scan names (i.e. the part of scan title before the Time), if no scan name found, scan count is used),
#            mgf_time, (output, dictionary, keys are the scan name, values are the scan time, if no time, scan count is used)
#            file, (input, name of mgf file),
#            peak_num (input, number of peaks to retrieve from the scan)
#       - return value: none
#
# (2) write - writes back an mgf file, (optionally) breaking it into pieces
#         - arguments: file, (input, base file name)
#             mgf_table, (input, as above, in read function)
#             mgf_pepmass, (input, as above)
#             mgf_charge, (input, as above)
#             mgf_scan, (input, as above)
#             mgf_title, (input, as above)
#             pieces (input, the number of pieces to split up the file into, default 1)
#        - return value: none
#
# (3) write_table - writes a csv file
#        - arguments: file, (input, base file name, .csv preferred)
#             mgf_table, (input, as above, in read function)
#             mgf_pepmass, (input, as above)
#             mgf_charge, (input, as above)
#             mgf_scan, (input, as above)
#             peak_num (optional input, as above; default value of 20)
#        - return value: none
#
# (4) read_select_write
#
# (5) select_pepmass - outputs a list of scan names that are the scans where PEPMASS equals mz within the error range
#             - arguments: scans, (output, list, scan names that correspond to the given mz within the mz_error range)
#                  mgf_pepmass, (input, as above, in read function)
#                  mgf_charge, (input, as above, in read function)
#                  mz, (input, the mz we are looking for)
#                  mz_error (input, the allowed error, in ppm)
#             - return value: none
#
# (6) select_fragments - outputs a list of scan names that are the scans where PEPMASS equals mz within the error range, AND,
#             outputs the list of fragments for each of these scans that match to the fragments given in the input (within error range), AND,
#             outputs the 'num_intense' most intense fragments for each scan
#               - arguments: scans, (output, list, scan names that correspond to the given mz)
#                    mgf_pepmatch_match_ions, (output, dictionary, keys are scan name and values are a list of the matching fragment ions - (mz, intensity) tuples)
#                    mgf_pepmatch_intense_ions, (output, dictionary, keys are scan name and values are a list of the top most intense ions - (mz, intensity) tuples)
#                    mz, (input, the mz we are looking for)
#                    mz_error, (input, the allowed error, in ppm)
#                    fragments, (input, list, the fragment masses we are looking for)
#                    fragment_error, (input, the allowed fragment error, in ppm)
#                    num_intense, (input, the number of top most intense ions to output)
#                    mgf_pepmass, (input, as above, in read function)
#                    mgf_charge, (input, as above, in read function)
#                    mgf_table (input, as above, in read function)
#               - return value: none
#

def read(mgf_table,mgf_pepmass,mgf_charge,mgf_title,mgf_scan,mgf_time,file,peak_num):
    mgf = open(file,'r')
    begin=False
    pepmass=''
    charge=''
    title=''
    scan=''
    time=''
    mz_intensity=[]
    count=0
    line_count = 0
    begin_p = re.compile('BEGIN IONS')
    title_p = re.compile('TITLE=(.*)')
    scan_time_p = re.compile('TITLE=Scan\s+([0-9]+),\s+Time=([0-9\.]+),\s+')
    pepmass_p = re.compile('PEPMASS=([0-9\.]+)')
    charge_p = re.compile('CHARGE=([0-9]+)')
    end_p = re.compile('END IONS')
    mz_int_p = re.compile('([0-9\.]+)\s([0-9\.]+)')
    for line in mgf:
        #if line_count % 100000 == 0 : print(line_count)
        line_count += 1
        line=line.rstrip('\n')
        line=line.rstrip('\n\r')
        if begin_p.match(line)!=None:
            begin=True
            pepmass=''
            charge=''
            title=''
            scan=''
            time=''
            mz_intensity=[]
        if begin:
            if title_p.match(line)!=None:
		title = line[6:];		
		##TITLE=Scan 3988, Time=822.75438, MS2, HCD
		##PEPMASS=352.962284330563
		##CHARGE=4		
		# TITLE=TCGA_114C_09-1664-01A-01_61-2094-01A-01_25-1312-01A-01_W_JHUZ_20130802_F1.2.2.2
		# RTINSECONDS=61.8615
		# PEPMASS=719.411865234375 48654.5078125
		# CHARGE=2+
		# revised by ZHI LI compatible with different mgf version
		if 'Scan' in title and scan_time_p.match(line)!=None:
		    scan,time = scan_time_p.findall(line)[0]
		else:
		    scan=title.split('.')[1]
		    time = next(mgf).split('=')[1]
            if pepmass_p.match(line)!=None:
                pepmass = pepmass_p.findall(line)[0]
            if charge_p.match(line)!=None:
                charge = charge_p.findall(line)[0]
            if mz_int_p.match(line)!=None:
                mz,intensity = mz_int_p.findall(line)[0]
                mz_intensity_t = float(mz),float(intensity)
                mz_intensity.append(mz_intensity_t)
            if end_p.match(line)!=None:
                begin=False
                if len(scan)==0:
                    scan=count
                if len(time)==0:
                    time=count
                if len(charge)==0:
                    charge=0
                if peak_num>0:
                    mz_intensity.sort(key=lambda tup: tup[1],reverse=True)
                    if peak_num<len(mz_intensity):
                        mgf_table[scan] = mz_intensity[:peak_num]
                    else:
                        mgf_table[scan] = mz_intensity[:]
                else:
                    mgf_table[scan] = mz_intensity[:]
                #if(mgf_pepmass.has_key(scan)):
                #    print scan
                mgf_pepmass[scan] = float(pepmass)
                mgf_charge[scan] = int(charge)
                mgf_title[scan] = title
                mgf_scan.append(scan)
                mgf_time[scan] = float(time)
                count+=1
    mgf.close
    return

def write(file,mgf_table,mgf_pepmass,mgf_charge,mgf_scan,mgf_title,pieces=1):
    count=0
    piece=0
    if pieces<1:
        pieces=1
    piece_len=len(mgf_scan)/pieces+1
    for scan in mgf_scan:
        if count%piece_len==0:
            if count>0:
                mgf.close()
            if pieces<=1:
                mgf = open(file,'w')
            else:
                mgf = open(file[:-4]+'.'+str(piece)+'.mgf','w')
                piece+=1
        mgf.write('BEGIN IONS\n')
        mgf.write('TITLE=%s\n' % mgf_title[scan])
        mgf.write('PEPMASS=%f\n' % mgf_pepmass[scan])
        mgf.write('CHARGE=%d\n' % mgf_charge[scan])
        for i in range(len(mgf_table[scan])):
            mz,intensity = mgf_table[scan][i]
            mgf.write('%f\t%f\n' % (mz,intensity) )
        mgf.write('END IONS\n\n')
        count+=1
    mgf.close()
    return
    

def write_table(outfile,mgf_table,mgf_pepmass,mgf_charge,mgf_scan,peak_num=20):
    """Transforms spectrum data for each peptide into a table, showing only top
    peaks by intensity, and writes the table into a comma-separated file for
    easy export and formatting in Excel. Tables extend horizontally for each 
    different peptide in the original file.
    Arguments:
        - outfile: the full filepath and extension for the file to be written
        - mgf_table: dictionary, keys are the scan name and values are a list 
            of peak (m/z, intensity) (tuples) values read from the .mgf file
        - mgf_pepmass: dictionary, keys are the scan name, values are the 
            pepmass (PEPMASS=...)
        - mgf_charge: dictionary, keys are the scan name, values are the charge 
            (CHARGE=...)
        - mgf_scan: list, all scan names (i.e. the part of scan title before 
            the Time), if no scan name found, scan count is used)
        - peak_num: number of peaks to show for each scan, default 20
    """
    count=-1 # keeps count consistent with indices starting at [0] 
    for scan in mgf_scan:
        count+=1     
    if(count == -1):
        return # no scans
        
    table = open(outfile, 'w')
    for scan in mgf_scan:
        table.write("," + scan + "-" + str(mgf_pepmass[scan]) + "-" + str(mgf_charge[scan]) + "-" + "m/z")
        table.write("," + scan + "-" + str(mgf_pepmass[scan]) + "-" + str(mgf_charge[scan]) + "-" + "int")
        mgf_table[scan].sort(key=lambda tup: tup[1],reverse=True) # sorts each scan by intensity
        mgf_table[scan] = mgf_table[scan][:peak_num]
    table.write("\n")

    for line_count in range(peak_num):
        table.write(str(line_count + 1))
        for scan in mgf_scan:
            if (len(mgf_table[scan]) > line_count): 
                table.write("," + str(mgf_table[scan][line_count][0]) + "," + str(mgf_table[scan][line_count][1]))
            else:
                table.write(",,")
        table.write("\n")

    #max horizontal tables?

    table.close()
    return

def read_select_write(file,mz_list,mz_error):
    mgf = open(file,'r')
    begin=False
    pepmass=''
    charge=''
    title=''
    scan=''
    time=''
    mz_intensity=[]
    count=0
    count_=0
    begin_p = re.compile('BEGIN IONS')
    title_p = re.compile('TITLE=(.*)')
    scan_time_p = re.compile('TITLE=Scan\s+([0-9]+),\s+Time=([0-9\.]+),\s+')
    pepmass_p = re.compile('PEPMASS=([0-9\.]+)')
    charge_p = re.compile('CHARGE=([0-9]+)')
    end_p = re.compile('END IONS')
    mz_int_p = re.compile('([0-9\.]+)\s([0-9\.]+)')
    for mz in mz_list:
        mgf_out = open(file[:-3]+str(mz)+'.mgf','w')
        mgf_out.close()
    for line in mgf:
        line=line.rstrip('\n')
        line=line.rstrip('\n\r')
        if begin_p.match(line)!=None:
            begin=True
            pepmass=''
            charge=''
            title=''
            scan=''
            time=''
            mz_intensity=[]
        if begin:
            if title_p.match(line)!=None:
                title = line[6:];
                if scan_time_p.match(line)!=None:
                    scan,time = scan_time_p.findall(line)[0]
            if pepmass_p.match(line)!=None:
                pepmass = pepmass_p.findall(line)[0]
            if charge_p.match(line)!=None:
                charge = charge_p.findall(line)[0]
            if mz_int_p.match(line)!=None:
                mz,intensity = mz_int_p.findall(line)[0]
                mz_intensity_t = float(mz),float(intensity)
                mz_intensity.append(mz_intensity_t)
            if end_p.match(line)!=None:
                begin=False
                if len(scan)==0:
                    scan=count
                if len(time)==0:
                    time=count
                if len(charge)==0:
                    charge=0
                for mz in mz_list:
                    if abs(float(pepmass)-float(mz))<float(mz_error)*float(mz)/1e+6:
                        mgf_out = open(file[:-3]+str(mz)+'.mgf','a')
                        mgf_out.write('BEGIN IONS\n')
                        mgf_out.write('TITLE=%s\n' % title)
                        mgf_out.write('PEPMASS=%s\n' % pepmass)
                        mgf_out.write('CHARGE=%s\n' % charge)
                        for i in range(len(mz_intensity)):
                            mz,intensity = mz_intensity[i]
                            mgf_out.write('%f\t%f\n' % (mz,intensity) )
                        mgf_out.write('END IONS\n\n')
                        mgf_out.close();
                        count_+=1
                count+=1
    mgf.close
    return (count_,count)

def select_pepmass(scans,mgf_pepmass,mgf_charge,mz,mz_error):
    for scan in mgf_pepmass:
        if abs(mgf_pepmass[scan]-mz)<mz_error*mz/1e+6:
            scans.append(scan)
    return
	
def select_pepmass_range(scans,mgf_pepmass,mgf_charge,mz_low,mz_high):
    for scan in mgf_pepmass:
		if mz_low<=mgf_pepmass[scan]:
			if mgf_pepmass[scan]<=mz_high:
				scans.append(scan)
    return

def select_pepmass_range_charge(scans,mgf_pepmass,mgf_charge,mz_low,mz_high,charge):
    for scan in mgf_pepmass:
		if mz_low<=mgf_pepmass[scan]:
			if mgf_pepmass[scan]<=mz_high:
				if mgf_charge[scan]==charge:
					scans.append(scan)
    return

def select_fragments(scans, mgf_pepmatch_ions, mz, mz_error, fragments, fragment_error, num_intense, mgf_pepmass, mgf_charge, mgf_time, mgf_table):
    for scan in mgf_pepmass:
        if abs(mgf_pepmass[scan]-mz) < mz_error*mz/1e+6:
            scans.append(scan)

            ions = mgf_table[scan]
            charge = mgf_charge[scan]
            
            #sort ions for getting most intense
            if num_intense > 0:
                ions.sort(key=lambda tup: tup[1], reverse=True) #sorts descending, by intensity
                
            intense_ions = ions[:num_intense]
            
            #sort ions for quicker compare
            ions.sort(key=lambda tup: tup[0]) #sorts ascending, by mz
            
            match_ions = []
            for frag_mz in fragments:
                for ion in ions:
                    if abs(ion[0]-frag_mz) < fragment_error*frag_mz/1e+6:
                        match_ions.append(ion)
                    elif frag_mz < ion[0]: break
                    
            mgf_pepmatch_ions.append([scan, mgf_time[scan], match_ions, intense_ions])
    return

def select_fragments_scan(scan, frag_mz_min, mgf_pepmatch_ions,sequence_evidence_b,sequence_evidence_y, fragments, precursor_error,precursor_error_type, fragment_error,fragment_error_type, num_intense, mgf_table):
	matched_intensity=0.0
	matched_intensity_not_parent=0.0
	matched_intensity_parent=0.0
	ions = mgf_table[scan]
	#sort ions for getting most intense
	if num_intense > 0:
		ions.sort(key=lambda tup: tup[1], reverse=True) #sorts descending, by intensity
	intense_ions = ions[:num_intense]
	#sort ions for quicker compare
	ions.sort(key=lambda tup: tup[0]) #sorts ascending, by mz
	used_ions = np.zeros(len(ions))
	for frag_mz in fragments:
		error=fragment_error
		error_type=fragment_error_type
		if frag_mz[1].lstrip('-').startswith('[M+H'):
			error=precursor_error
			error_type=precursor_error_type
		count=0
		for ion in ions:
			if error_type=='ppm':
				if abs(ion[0]-frag_mz[0]) < error*frag_mz[0]/1e+6:
					mgf_pepmatch_ions.append([frag_mz[1],frag_mz[0],ion[0],ion[1]])
					if frag_mz[1].lstrip('-').startswith('b'):
						sequence_evidence_b[int(frag_mz[1].split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
					if frag_mz[1].lstrip('-').startswith('y'):
						sequence_evidence_y[int(frag_mz[1].split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
					if used_ions[count]==0 and frag_mz_min<ion[0]:
						matched_intensity+=ion[1]
						if frag_mz[1].lstrip('-').startswith('['):
							matched_intensity_parent+=ion[1]
						else:
							matched_intensity_not_parent+=ion[1]
					used_ions[count]=1
				elif frag_mz[0] < ion[0]: break	
			else:
				if abs(ion[0]-frag_mz[0]) < error:
					mgf_pepmatch_ions.append([frag_mz[1],frag_mz[0],ion[0],ion[1]])
					if frag_mz[1].lstrip('-').startswith('b'):
						sequence_evidence_b[int(frag_mz[1].split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
					if frag_mz[1].lstrip('-').startswith('y'):
						sequence_evidence_y[int(frag_mz[1].split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
					if used_ions[count]==0 and frag_mz_min<ion[0]:
						matched_intensity+=ion[1]
						if frag_mz[1].lstrip('-').startswith('['):
							matched_intensity_parent+=ion[1]
						else:
							matched_intensity_not_parent+=ion[1]
					used_ions[count]=1
				elif frag_mz[0] < ion[0]: break	
			count+=1
	if 1==1: #fragment_error_type=='ppm':
		mgf_pepmatch_ions_isotope1=[]
		for ion_type,mz_calc,mz_exp,intensity in mgf_pepmatch_ions:
			error=fragment_error
			error_type=fragment_error_type
			if ion_type.lstrip('-').startswith('[M+H'):
				error=precursor_error
				error_type=precursor_error_type
			charge=1.0
			if ion_type.endswith('+2'):
				charge=2.0
			if ion_type.endswith('+3'):
				charge=3.0
			mz_=mz_calc+(13.00335483778-12)/charge
			count=0
			for ion in ions:
				if used_ions[count]==0:
					if error_type=='ppm':
						if abs(ion[0]-mz_) < error*mz_/1e+6:
							mgf_pepmatch_ions_isotope1.append(['-'+ion_type,mz_,ion[0],ion[1]])
							if ion_type.lstrip('-').startswith('b'):
								sequence_evidence_b[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
							if ion_type.lstrip('-').startswith('y'):
								sequence_evidence_y[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
							if used_ions[count]==0 and frag_mz_min<ion[0]:
								matched_intensity+=ion[1]
								if ion_type.lstrip('-').startswith('['):
									matched_intensity_parent+=ion[1]
								else:
									matched_intensity_not_parent+=ion[1]
							used_ions[count]=1
						elif mz_ < ion[0]: break	
					else:
						if abs(ion[0]-mz_) < error:
							mgf_pepmatch_ions_isotope1.append(['-'+ion_type,mz_,ion[0],ion[1]])
							if ion_type.lstrip('-').startswith('b'):
								sequence_evidence_b[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
							if ion_type.lstrip('-').startswith('y'):
								sequence_evidence_y[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
							if used_ions[count]==0 and frag_mz_min<ion[0]:
								matched_intensity+=ion[1]
								if ion_type.lstrip('-').startswith('['):
									matched_intensity_parent+=ion[1]
								else:
									matched_intensity_not_parent+=ion[1]
							used_ions[count]=1
						elif mz_ < ion[0]: break	
				count+=1
		mgf_pepmatch_ions_isotope2=[]
		for ion_type,mz_calc,mz_exp,intensity in mgf_pepmatch_ions_isotope1:
			error=fragment_error
			error_type=fragment_error_type
			if ion_type.lstrip('-').startswith('[M+H'):
				error=precursor_error
				error_type=precursor_error_type
			charge=1.0
			if ion_type.endswith('+2'):
				charge=2.0
			if ion_type.endswith('+3'):
				charge=3.0
			mz_=mz_calc+(13.00335483778-12)/charge
			count=0
			for ion in ions:
				if used_ions[count]==0:
					if error_type=='ppm':
						if abs(ion[0]-mz_) < error*mz_/1e+6:
							mgf_pepmatch_ions_isotope2.append(['-'+ion_type,mz_,ion[0],ion[1]])
							if ion_type.lstrip('-').startswith('b'):
								sequence_evidence_b[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
							if ion_type.lstrip('-').startswith('y'):
								sequence_evidence_y[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
							if used_ions[count]==0 and frag_mz_min<ion[0]:
								matched_intensity+=ion[1]
								if ion_type.lstrip('-').startswith('['):
									matched_intensity_parent+=ion[1]
								else:
									matched_intensity_not_parent+=ion[1]
							used_ions[count]=1
						elif mz_ < ion[0]: break	
					else:
						if abs(ion[0]-mz_) < error:
							mgf_pepmatch_ions_isotope2.append(['-'+ion_type,mz_,ion[0],ion[1]])
							if ion_type.lstrip('-').startswith('b'):
								sequence_evidence_b[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
							if ion_type.lstrip('-').startswith('y'):
								sequence_evidence_y[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
							if used_ions[count]==0 and frag_mz_min<ion[0]:
								matched_intensity+=ion[1]
								if ion_type.lstrip('-').startswith('['):
									matched_intensity_parent+=ion[1]
								else:
									matched_intensity_not_parent+=ion[1]
							used_ions[count]=1
						elif mz_ < ion[0]: break	
				count+=1
		mgf_pepmatch_ions_isotope3=[]
		for ion_type,mz_calc,mz_exp,intensity in mgf_pepmatch_ions_isotope2:
			error=fragment_error
			error_type=fragment_error_type
			if ion_type.lstrip('-').startswith('[M+H'):
				error=precursor_error
				error_type=precursor_error_type
			charge=1.0
			if ion_type.endswith('+2'):
				charge=2.0
			if ion_type.endswith('+3'):
				charge=3.0
			mz_=mz_calc+(13.00335483778-12)/charge
			count=0
			for ion in ions:
				if used_ions[count]==0:
					if error_type=='ppm':
						if abs(ion[0]-mz_) < error*mz_/1e+6:
							mgf_pepmatch_ions_isotope3.append(['-'+ion_type,mz_,ion[0],ion[1]])
							if ion_type.lstrip('-').startswith('b'):
								sequence_evidence_b[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
							if ion_type.lstrip('-').startswith('y'):
								sequence_evidence_y[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
							if used_ions[count]==0 and frag_mz_min<ion[0]:
								matched_intensity+=ion[1]
								if ion_type.lstrip('-').startswith('['):
									matched_intensity_parent+=ion[1]
								else:
									matched_intensity_not_parent+=ion[1]
							used_ions[count]=1
						elif mz_ < ion[0]: break	
					else:
						if abs(ion[0]-mz_) < error:
							mgf_pepmatch_ions_isotope3.append(['-'+ion_type,mz_,ion[0],ion[1]])
							if ion_type.lstrip('-').startswith('b'):
								sequence_evidence_b[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('b'))-1]+=ion[1]
							if ion_type.lstrip('-').startswith('y'):
								sequence_evidence_y[int(ion_type.split('+')[0].split('o')[0].split('i')[0].split('*')[0].lstrip('-').lstrip('y'))-1]+=ion[1]
							if used_ions[count]==0 and frag_mz_min<ion[0]:
								matched_intensity+=ion[1]
								if ion_type.lstrip('-').startswith('['):
									matched_intensity_parent+=ion[1]
								else:
									matched_intensity_not_parent+=ion[1]
							used_ions[count]=1
						elif mz_ < ion[0]: break	
				count+=1
		for value in mgf_pepmatch_ions_isotope1:
			mgf_pepmatch_ions.append(value)
		for value in mgf_pepmatch_ions_isotope2:
			mgf_pepmatch_ions.append(value)
		for value in mgf_pepmatch_ions_isotope3:
			mgf_pepmatch_ions.append(value)
	return matched_intensity,matched_intensity_parent,matched_intensity_not_parent

