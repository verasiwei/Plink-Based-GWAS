# This is used to generate the log of odds ratio of each SNP
args=commandArgs(TRUE)
resultdir=args[1]
sigresults=read.table(paste(resultdir,"unilog_covs.csv",sep = ""),header = TRUE,sep=",")
sigresults$OR=log(sigresults$OR)
colnames(sigresults)[7]="logOR"

write.table(sigresults[,c(2,4,7)],file=paste(resultdir,"snpprs_logOR.raw",sep=""),
row.names=FALSE,col.names=FALSE,sep="\t",quote=FALSE)