rm(list=ls())
args<-commandArgs(T)
path=args[1]
filepattern=args[2]
filenames=list.files(pattern=filepattern, path=path)
info = file.info(paste(path, '/',filenames, sep=""))
errors = rownames(info[info$size != 0, ])
print(errors)

######for i in /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/MGF/breast/*TCGA*; do Rscript find_failed_jobs.R $i/ensembl_human_37_70_orf0_orf1_orf2_pipeline* .sh.e; done
######for i in /ifs/data/proteomics/projects/Xuya/CPTAC_GlobalProteome/MGF/ovarian/*TCGA*; do Rscript find_failed_jobs.R $i/ensembl_human_37_70_orf0_orf1_orf2_pipeline* .sh.e; done




