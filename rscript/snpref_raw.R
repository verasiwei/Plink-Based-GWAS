#
args=commandArgs(TRUE)
options(scipen=999)
input=args[1]
snpsreference=read.table(paste(input,"snpsreference.txt",sep = ""),header=F,as.is=T)
snpsraw=read.table(paste(input,"snpsraw.txt",sep = ""),header=F,as.is=T)
snpsraw=snpsraw[order(snpsraw[,1],snpsraw[,2]),]
snpsreference=snpsreference[order(snpsreference[,1],snpsreference[,2]),]
duplicate=merge(snpsraw,snpsreference,by=c("V1","V2"),sort = FALSE)
duplicatesnp=data.frame(matrix(NA,nrow(duplicate),4))
duplicatesnp$X1=duplicate$V1
duplicatesnp$X2=duplicate$V2
duplicatesnp$X3=duplicatesnp$X2+1
duplicatesnp$X4=1:nrow(duplicate)
#write.table(duplicatesnp,file = "duplicatesnp",row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")
write.table(duplicatesnp,file = paste(input,"duplicatesnp",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")


