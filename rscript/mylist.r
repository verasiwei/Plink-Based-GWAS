#read in phenotype data
#args=commandArgs(TRUE)
#input=args[1]
#load(paste(input,"GRID_DEMOGRAPHICS.Aug2017.RData",sep ="" ))
#selectedPatientsTable<-read.csv(paste(input,"20180514_PatientsIntensityCutoff.csv",sep = ""),header=T,as.is=T,row.names=1)
#sum(selectedPatientsTable[,6]==0)#78 trts, 7052 controls
#datafam=read.table(paste(input,"totaldataqc.fam",sep = ""),header = FALSE,sep = " ")
#phenotype data
#extract ids from datafam
#install.packages("stringr", dependencies = TRUE)
#library(stringr)
#substrRight <- function(x, n){
#  substr(x, nchar(x)-n+1, nchar(x))
#}
#datafam[,2]=as.character(datafam[,2])
#datafam[,7]=substrRight(datafam[,2], 10)
#colnames(datafam)[7]="GRID_DEMOGRAPHICS"
#selectedPatientsTable[,7]=row.names(selectedPatientsTable)
#colnames(selectedPatientsTable)[7]="GRID_DEMOGRAPHICS"
#pheno=merge(datafam,selectedPatientsTable,by="GRID_DEMOGRAPHICS")
#pheno=merge(pheno,demographics,by="GRID_DEMOGRAPHICS")
#pheno=pheno[,c(2:3,13,17:19)]
#colnames(pheno)=c("FID","IID","OUTCOME","AGE","SEX","RACE")
#prepare the extract ids mylist.txt
#mylist=data.frame(matrix(NA,nrow(pheno),2))
#colnames(mylist)=c("FID","IID")
#mylist$FID=pheno$FID
#mylist$IID=pheno$IID
#write.table(mylist,file = paste(input,"mylist.txt",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")
#read in phenotype file
args=commandArgs(TRUE)
input=args[1]
rawdatadir=args[2]
load(paste(input,"GRID_DEMOGRAPHICS.Aug2017.RData",sep ="" ))
selectedPatientsTable<-read.csv(paste(input,"20180514_PatientsIntensityCutoff.csv",sep = ""),header=T,as.is=T,row.names=1)
datafam=read.table(paste(rawdatadir,"totaldatanodup.fam",sep = ""),header = FALSE,sep = " ")
selectedPatientsTable[,7]=row.names(selectedPatientsTable)
colnames(selectedPatientsTable)[7]="GRID_DEMOGRAPHICS"
colnames(datafam)[1]="GRID_DEMOGRAPHICS"
pheno=merge(datafam,selectedPatientsTable,by="GRID_DEMOGRAPHICS",sort = FALSE)
pheno=merge(pheno,demographics,by="GRID_DEMOGRAPHICS")
pheno=pheno[which(pheno$SEX!="UNK"),]
#prepare the extract ids mylist.txt
mylist=data.frame(matrix(NA,nrow(pheno),2))
colnames(mylist)=c("FID","IID")
mylist$FID=pheno[,1]
mylist$IID=pheno[,2]
write.table(mylist,file = paste(input,"mylist.txt",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")
