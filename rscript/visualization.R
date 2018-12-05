#make QQ plot
args=commandArgs(TRUE)
resultdir=args[1]
data=read.table(paste(resultdir,"unilogassoc_typed.assoc.logistic",sep = ""),header = TRUE)
library(qqman)
png(paste(resultdir,"qqplot_adjusted.png",sep=""),type="cairo",width = 1000,height = 700)
qq(data$P,main="QQ plot of adjusted GWAS p-values", col="blue4",cex=1.5)
dev.off()