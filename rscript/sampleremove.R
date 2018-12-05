#get the list of samples to remove due to relatedness:removesamplelisthet.txt
#to be edited by user
args=commandArgs(TRUE)
input=args[1]
library(dplyr)
HET=read.table(paste(input,"qcgenomindmafhwe.het",sep = ""),header=T,as.is=T)
H = (HET$N.NM.-HET$O.HOM.)/HET$N.NM.
sortHET=HET[order(HET$F),]
outliers<-data.frame()
for(i in 1:length(sortHET$F)){
  if(sortHET[i,6] > (mean(sortHET$F)+3*sd(sortHET$F))){
    outliers=rbind(outliers,sortHET[i,])
  }
  if(sortHET[i,6] < (mean(sortHET$F)-3*sd(sortHET$F))){
    outliers=rbind(outliers,sortHET[i,])
  }
}
hetoutliers=select(outliers,FID,IID)
write.table(hetoutliers,file=paste(input,"removesamplelisthet.txt",sep=""),quote=F,col.names=F,row.names=F)
