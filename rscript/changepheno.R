#read in phenotype data
#args=commandArgs(TRUE)
#input=args[1]
#resultdir=args[2]
#prepare the totaldataqc_extract.fam(add the outcome) 
#datafam=read.table(paste(input,"totaldataqc_extract.fam",sep = ""),header = FALSE,sep = " ")
#selectedPatientsTable<-read.csv(paste(input,"20180514_PatientsIntensityCutoff.csv",sep = ""),header=T,as.is=T,row.names = 1)
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
#pheno=pheno[,c(1:7,13)]
#pheno$V6=pheno[,8]
#pheno=pheno[,c(2:7)]
#pheno$V6=ifelse(pheno$V6==1,2,1)
#write.table(pheno,file = paste(input,"totaldataqc_extract.fam",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")

args=commandArgs(TRUE)
input=args[1]
rawdatadir=args[2]
datafam=read.table(paste(rawdatadir,"totaldata_extract.fam",sep = ""),header = FALSE,sep = " ")
selectedPatientsTable<-read.csv(paste(input,"20180514_PatientsIntensityCutoff.csv",sep = ""),header=T,as.is=T,row.names = 1)
load(paste(input,"GRID_DEMOGRAPHICS.Aug2017.RData",sep ="" ))
colnames(datafam)[1]="GRID_DEMOGRAPHICS"
selectedPatientsTable[,7]=row.names(selectedPatientsTable)
colnames(selectedPatientsTable)[7]="GRID_DEMOGRAPHICS"
pheno=merge(datafam,selectedPatientsTable,by="GRID_DEMOGRAPHICS",sort = FALSE)
pheno=merge(pheno,demographics,by="GRID_DEMOGRAPHICS",sort = FALSE)
pheno=pheno[,c(1:6,12)]
pheno$V6=pheno[,7]
pheno=pheno[,c(1:6)]
pheno$V6=ifelse(pheno$V6==1,2,1)
write.table(pheno,file = paste(rawdatadir,"totaldata_extract.fam",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")
