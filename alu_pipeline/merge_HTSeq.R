list_HTseq <- read.csv("HTSEQ_files.txt", header=F)

#merge HTSeq together
merge_HTSEQ <- matrix(data = NA, nrow = 1, ncol=2 )
colnames(merge_HTSEQ) <- c("name", "val")

for(i in 1:nrow(list_HTseq)){
  current_HTSeq <- read.csv(as.character(list_HTseq[i,]), header = T, sep="\t")
  colnames(current_HTSeq) <- c("name", as.character(list_HTseq[i,]))
  merge_HTSEQ <- merge(merge_HTSEQ, current_HTSeq, c("name"), all=TRUE)
}
write.csv(merge_HTSEQ, "merged_HTSeq.csv")
