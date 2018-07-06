list_files<- read.table("sorted_bed.txt")

#for each sample, save alu that have greater than 20 transcripts, and greater than 15 
for(i in 1:nrow(list_files)){
  current_bed <- read.csv(as.character(list_files[i,]), header = F, sep="\t")
  colnames(current_bed) <- c("chr1", "start1", "end1", "name1", "type1", "strand1", "comb1", "sum1",
                             "chr2", "start2", "end2", "name2", "type2", "strand2", "comb2", "sum2","chr3",
                             "start3", "end3", "name3", "type3", "strand3", "comb3", "sum3","percent")
  greater_than10 <- which(current_bed$sum2 > 20)
  current_bed_10 <- current_bed[greater_than10,]
  greater_than_10p <- which(current_bed_10$percent > 15)
  final_bed <- current_bed_10[greater_than_10p,]
  write.csv(final_bed, paste(as.character(list_files[i,]), "SORTED2", sep = ""))
}
