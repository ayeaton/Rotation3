list_sorted <- read.table("SORTED2_bed.txt")

final_sorted <- matrix(data = NA, nrow = 1, ncol=2 )
colnames(final_sorted) <- c("name", "val")

#merge all of the alus that passed the threshold 
for(i in 1:nrow(list_sorted)){
  current_bed <- read.csv(as.character(list_sorted[i,]), header = T, sep=",")
  name <- paste(current_bed$chr2, current_bed$start2, current_bed$name2, sep = "_")
  tomerge <- cbind(name, current_bed$sum2)
  colnames(tomerge) <- c("name", as.character(list_sorted[i,]))
  final_sorted <- merge(final_sorted, tomerge, c("name"), all=TRUE)
}
write.csv(final_sorted, "finalsorted_names.csv")
