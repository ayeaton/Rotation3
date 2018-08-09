#!/usr/bin/Rscript

args = commandArgs(trailingOnly=TRUE)

sample_path <- args[1]

MGF_file <- paste(sample_path, "/MGF_filename.txt", sep = "")
MGF <- read.table(MGF_file)
names <- apply(MGF, 1, function(x) strsplit(x, "/")[[1]][11])
names2 <- apply(as.data.frame(names), 1, function(x) strsplit(x, "[.]")[[1]][1])
new_MGF <- cbind(MGF, names2)
colnames(new_MGF) <- c("mgf_file","mgf_filename")
write.table(new_MGF,paste(sample_path,"/MGF_filename.txt",sep=""),row.names=FALSE,sep="\t", quote = FALSE)
