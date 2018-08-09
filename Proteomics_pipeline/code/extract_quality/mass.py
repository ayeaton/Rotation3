import re
from string import ascii_letters

#Module Usage: Calculates mass of or m/z (given charge) of a peptide, also calculates the fragment masses given ion type
#	       Also contains a limited function to calculate the mass of a given chemical formula
#
# *First* call get_masses function to set up the 'masses' list
#
# Available functions:
# (1) calc_mass - calculates mass of a chemical formula (*note: only H, O, N, C, S, P are recognized)
#		- arguments: composition (the formula), masses (list set up by get_masses function call)
#		- return value: mass (mass of the formula)
#		
# (2) calc_peptide_mass - calculates a peptide mass
#			- arguments: peptide (the peptide sequence),
#				     modifications (comma separated list of mods, e.g.,  +100@5 or -H2O@A),
#				     masses (list set up by get_masses function call)
# 			- return value: mass (of peptide, including modifications)
#
# (3) calc_peptide_mz - calculates the peptide m/z
#		      - arguments: peptide, modifications, charge, masses
#		      - return value: mz
#
# (4) calc_peptide_fragments - calculates the fragment masses of a peptide
#			     - arguments: fragments (output parameter, the list of (fragment masses, ion type) (tuples)),
#					  peptide (the peptide seq),
#					  modifications (mod list, same as above),
#					  ion_types (b, c, y, z),
#					  masses
#			     - return value: none
#

def calc_mass(composition,masses):
	mass=0.0;
	formula_p = re.compile('([A-Z][a-z]?)([0-9]*)')
	comp=formula_p.findall(composition)
	for i in range(len(comp)):
		atom,number = comp[i]
		if len(number)==0:
			number=1
		mass += int(number)*masses[atom]
	return mass
	
def get_masses(masses):	
	masses['Proton']=float(1.007276)
	masses['H']=float(1.007825035)
	masses['O']=float(15.99491463)
	masses['N']=float(14.003074)
	masses['C']=float(12.0)
	masses['C13']=float(13.00335483778)
	masses['S']=float(31.9720707)
	masses['P']=float(30.973762)
	masses['H2O']=2*masses['H'] + masses['O']
	masses['NH3'] = masses['N'] + 3*masses['H']
	masses['HPO3'] = masses['H'] + masses['P'] + 3*masses['O']
	masses['H3PO4'] = 3*masses['H'] + masses['P'] + 4*masses['O']
	masses['b'] = masses['Proton']
	masses['c'] = masses['N'] + 3*masses['H'] + masses['Proton']
	masses['y'] = masses['O'] + 2*masses['H'] + masses['Proton']
	masses['z'] = 2*masses['H'] + masses['O'] - 2*masses['H'] - masses['N'] + masses['Proton']
	masses['aa:A'] = calc_mass('C3H5ON',masses)
	masses['aa:B'] = calc_mass('C4H6O2N2',masses)	# Same as N
	masses['aa:C'] = calc_mass('C3H5ONS',masses)
	masses['aa:D'] = calc_mass('C4H5O3N',masses)
	masses['aa:E'] = calc_mass('C5H7O3N',masses)
	masses['aa:F'] = calc_mass('C9H9ON',masses)
	masses['aa:G'] = calc_mass('C2H3ON',masses)
	masses['aa:H'] = calc_mass('C6H7ON3',masses)
	masses['aa:I'] = calc_mass('C6H11ON',masses)
	masses['aa:J'] = 0.0
	masses['aa:K'] = calc_mass('C6H12ON2',masses)
	masses['aa:L'] = calc_mass('C6H11ON',masses)
	masses['aa:M'] = calc_mass('C5H9ONS',masses)
	masses['aa:N'] = calc_mass('C4H6O2N2',masses)
	masses['aa:O'] = 0.0
	masses['aa:P'] = calc_mass('C5H7ON',masses)
	masses['aa:Q'] = calc_mass('C5H8O2N2',masses)
	masses['aa:R'] = calc_mass('C6H12ON4',masses)
	masses['aa:S'] = calc_mass('C3H5O2N',masses)
	masses['aa:T'] = calc_mass('C4H7O2N',masses)
	masses['aa:U'] = 0.0
	masses['aa:V'] = calc_mass('C5H9ON',masses)
	masses['aa:W'] = calc_mass('C11H10ON2',masses)
	masses['aa:X'] = 0.0
	masses['aa:Y'] = calc_mass('C9H9O2N',masses)
	masses['aa:Z'] = calc_mass('C5H8O2N2',masses)	# Same as Q
	return

def calc_peptide_mass(peptide,modifications,masses):
	mass=0.0;
	mod_dict={}
	if len(modifications)>0:
		mods=modifications.split(',')
		for j in range(len(mods)):
			if '@' in mods[j]:
				mod,aa = mods[j].split('@')
				if mod[0] in ascii_letters:	#fix this! - to account for possible +/- before the formula
					mod=calc_mass(mod,masses)
				if len(aa)>1:
					if aa[0] in ascii_letters and aa[1] in ['0','1','2','3','4','5','6','7','8','9']:
						aa=aa[1:]
				mod_dict[aa]=float(mod);
	for i in range(len(peptide)):
		mass+=masses['aa:'+peptide[i]]
		if str(i+1) in mod_dict:
			mass+=mod_dict[str(i+1)]
		if peptide[i] in mod_dict:
			mass+=mod_dict[peptide[i]]
	mass+=masses['H2O'];
	return mass
	
def calc_peptide_mz(peptide,modifications,charge,masses):	
	mz=(calc_peptide_mass(peptide,modifications,masses) + charge*masses['Proton'])/charge
	return mz

def calc_peptide_fragments(fragments,peptide,modifications,charge,ion_types,masses):
	mass=0.0;
	mod_dict={}
	if len(modifications)>0:
		mods=modifications.split(',')
		for j in range(len(mods)):
			if '@' in mods[j]:
				mod,aa = mods[j].split('@')
				if mod[0] in ascii_letters:	#fix this! - to account for possible +/- before the formula
					mod=calc_mass(mod,masses)
				if len(aa)>1:
					if aa[0] in ascii_letters and aa[1] in ['0','1','2','3','4','5','6','7','8','9']:
						aa=aa[1:]
				mod_dict[aa]=float(mod);
	for ion_type in ion_types:
		mass=masses[ion_type]
		if ion_type in 'bc':
			for i in range(len(peptide)):
				mass+=masses['aa:'+peptide[i]]
				if str(i+1) in mod_dict:
					mass+=mod_dict[str(i+1)]
				if peptide[i] in mod_dict:
					mass+=mod_dict[peptide[i]]
				if 0<=i and i<len(peptide)-1:
					for k in range(1): #(3):
						prefix=''
						if k>0:
							prefix='-'
						mass_=mass+k*(masses['C13']-masses['C'])
						mass_ion_t = mass_,prefix+ion_type+str(i+1)
						fragments.append(mass_ion_t)
						if '1' in mod_dict:
							if abs(mod_dict['1']-144.10207)<0.01:
								mass_ion_t = mass_-144.10207,prefix+ion_type+str(i+1)+'i'
								fragments.append(mass_ion_t)
						for l in range(1,2,1):
							mass_ion_t = mass_-l*masses['H2O'],prefix+ion_type+str(i+1)+'o'*l
							fragments.append(mass_ion_t)
							mass_ion_t = mass_-l*masses['NH3'],prefix+ion_type+str(i+1)+'*'*l
							fragments.append(mass_ion_t)
						if int(charge)>2:
							mass_ion_t = (mass_+masses['Proton'])/2.0,prefix+ion_type+str(i+1)+'+2'
							fragments.append(mass_ion_t)
							for l in range(1,2,1):
								mass_ion_t = (mass_-l*masses['H2O']+masses['Proton'])/2.0,prefix+ion_type+str(i+1)+'o'*l+'+2'
								fragments.append(mass_ion_t)
								mass_ion_t = (mass_-l*masses['NH3']+masses['Proton'])/2.0,prefix+ion_type+str(i+1)+'*'*l+'+2'
								fragments.append(mass_ion_t)
		else:
			for i in xrange(len(peptide)-1,-1,-1):
				mass+=masses['aa:'+peptide[i]]
				if str(i+1) in mod_dict:
					mass+=mod_dict[str(i+1)]
				if peptide[i] in mod_dict:
					mass+=mod_dict[peptide[i]]
				if 0<i and i<len(peptide):
					for k in range(1): #(3):
						prefix=''
						if k>0:
							prefix='-'
						mass_=mass+k*(masses['C13']-masses['C'])
						mass_ion_t = mass_,prefix+ion_type+str(len(peptide)-i)
						fragments.append(mass_ion_t)
						if str(len(peptide)) in mod_dict:
							if abs(mod_dict[str(len(peptide))]-144.10207)<0.01:
								mass_ion_t = mass_-144.10207,prefix+ion_type+str(len(peptide)-i)+'i'
								fragments.append(mass_ion_t)
						for l in range(1,2,1):
							mass_ion_t = mass_-l*masses['H2O'],prefix+ion_type+str(len(peptide)-i)+'o'*l
							fragments.append(mass_ion_t)
							mass_ion_t = mass_-l*masses['NH3'],prefix+ion_type+str(len(peptide)-i)+'*'*l
							fragments.append(mass_ion_t)
						if int(charge)>2:
							mass_ion_t = (mass_+masses['Proton'])/2.0,prefix+ion_type+str(len(peptide)-i)+'+2'
							fragments.append(mass_ion_t)
							for l in range(1,2,1):
								mass_ion_t = (mass_-l*masses['H2O']+masses['Proton'])/2.0,prefix+ion_type+str(len(peptide)-i)+'o'*l+'+2'
								fragments.append(mass_ion_t)
								mass_ion_t = (mass_-l*masses['NH3']+masses['Proton'])/2.0,prefix+ion_type+str(len(peptide)-i)+'*'*l+'+2'
								fragments.append(mass_ion_t)
	return
