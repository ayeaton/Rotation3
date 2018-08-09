rm(list=ls())
args<-commandArgs(T)
TCGAMGFPath<-args[1]
outpath<-args[2]
platform<-args[3]
taxon_label<-args[4]

print(TCGAMGFPath)
print(taxon_label)

subdirs<-list.dirs(path=TCGAMGFPath)
print(subdirs)
ensembldir<-subdirs[grep(taxon_label, subdirs)]
print(ensembldir)
ensembldir<-ensembldir[1]
files<-list.files(pattern='.txt', path=ensembldir)
print(files)

quantdir<-subdirs[grep('merged-d20-iTRAQ4', subdirs)]
#quantdir <- paste(TCGAMGFPath[1],'/merged-d20-iTRAQ-1000-2', sep = '')
merged.quant<-read.csv(paste(quantdir,'/','merged_selected.txt', sep=''),sep='\t', header=T)
merged.quant$filename<-sapply(merged.quant$filename, function(x) strsplit(as.character(x), '[.]')[[1]][1])

#print(merged.quant$filename[1:10])

for (i in 1:length(files)){
	ident<-read.csv(paste(ensembldir,files[i], sep='/'),sep='\t',header=T)
	if (nrow(ident)!=0){
  		ident$filename<-strsplit(files[i], '[.]')[[1]][1]
		final<-merge(ident, merged.quant, by=c('filename', 'scan'))
		print(final[1:2,])
		if (nrow(final)>0){
			final$start_aa<-NA #placeholder to have same header as breast cancer file, need to do this after PGX assign protein step
			SampleName<-strsplit(files[i], '[.]')[[1]][1]	
			if (platform=='iTRAQ4'){
				print(final[1:3,])
				print(final$iTRAQ4.114)
				#print(as.numeric(final$iTRAQ4.114)*as.numeric(final$iTRAQ4.sum))
				final$'RI@114.1112'<-round(final$iTRAQ4.114*final$iTRAQ4.sum,3)
				final$'RI@115.1083'<-round(final$iTRAQ4.115*final$iTRAQ4.sum,3)
				final$'RI@116.1116'<-round(final$iTRAQ4.116*final$iTRAQ4.sum,3)
				final$'RI@117.1150'<-round(final$iTRAQ4.117*final$iTRAQ4.sum,3)
				final<-final[, c('charge','scan', 'filename', 'expect', 'start_aa', 'peptide','modifications','proteins', 'RI@114.1112','RI@115.1083','RI@116.1116','RI@117.1150')]
				colnames(final)<-c('charge','scan','filename','e_value','start_aa','seq','mods','protein','RI@114.1112','RI@115.1083','RI@116.1116','RI@117.1150')}
			write.table(final, paste(outpath, '/', SampleName,'.ident.quant.txt', sep=''), sep='\t', quote=F, row.names=F)
		}
	}
}





