#get the list of samples to remove due to relatedness:removelist.txt
#check IBD
#to be edited by user
library(dplyr)
args=commandArgs(TRUE)
input=args[1]
ibd=read.table(paste(input,"qcgenomindmafhwehetIBD.genome",sep=""),header=T)
dups=dplyr::filter(ibd,PI_HAT==1)
##expected duplicates
expdups=dplyr::filter(dups,as.character(IID1) == as.character(IID2))
#exclude expected dups 
toExclude=c(as.character(expdups$IID1))
excludeid=as.character(ibd$IID1) %in% toExclude
nodupdata=ibd[excludeid==FALSE,]
#rerun --genome without duplicates
dupslist=dplyr::select(expdups,FID1,IID1) 
colnames(dupslist)=c("FID","IID")
mixup=dplyr::filter(nodupdata,PI_HAT>=0.9)
mixup1=dplyr::select(mixup,FID1,IID1)
mixup2=dplyr::select(mixup,FID2,IID2)
colnames(mixup1)=c("FID","IID")
colnames(mixup2)=c("FID","IID")
mixuplist=unique(rbind(mixup1,mixup2)) 
#remove one of pair with PI_HAT>0.2
pithresh=dplyr::filter(nodupdata,PI_HAT>0.2)
pilist=dplyr::select(pithresh,FID1,IID1) 
colnames(pilist)=c("FID","IID")
dup=unique(rbind(dupslist,mixuplist,pilist))
write.table(dup,file=paste(input,"removesamplelist2.txt",sep=""),quote=F,col.names=F,row.names=F)
