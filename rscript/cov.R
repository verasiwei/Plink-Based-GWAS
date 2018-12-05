#read in phenotype data
#to be edited by user
args=commandArgs(TRUE)
input=args[1]
resultdir=args[2]
#pca=args[3]     #number of principle components output in plink
#pca=args[4]     #number of principle components you chose to use in the association analysis
load(paste(input,"GRID_DEMOGRAPHICS.Aug2017.RData",sep ="" ))
selectedPatientsTable<-read.csv(paste(input,"20180514_PatientsIntensityCutoff.csv",sep = ""),header=T,as.is=T,row.names=1)
#sum(selectedPatientsTable[,6]==0)#78 trts, 7052 controls
datafam=read.table(paste(input,"totaldata_extractqc.fam",sep = ""),header = FALSE,sep = " ")
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
#prepare mycov.txt
#pheno=merge(datafam,selectedPatientsTable,by="GRID_DEMOGRAPHICS")
#pheno=merge(pheno,demographics,by="GRID_DEMOGRAPHICS")
#pheno=pheno[,c(1:3,17:19)]
#colnames(pheno)=c("FID","IID","OUTCOME","AGE","SEX","RACE")
##2 covariates
#mycov=pheno[,c(-3,-6)]
#mycov$SEX=as.character(mycov$SEX)
#mycov$SEX[which(mycov$SEX=="F")]=2
#mycov$SEX[which(mycov$SEX=="M")]=1
#write.table(mycov,paste(input,"mycov.txt",sep = "") ,row.names=FALSE,col.names=FALSE,quote = FALSE,sep = "\t")
##2 covariates plus principal components
#allpca=read.table(paste(input,"totaldataqc_extractpca.eigenvec",sep = ""),sep=" ",header = TRUE)
#allpca[,2]=as.character(allpca[,2])
#allpca[,23]=substrRight(allpca[,2], 10)
#colnames(allpca)[23]="GRID_DEMOGRAPHICS"
#pheno=merge(pheno,allpca,by="GRID_DEMOGRAPHICS")
#pheno=pheno[,c(2:5,9:10)]
#pheno$SEX=as.character(pheno$SEX)
#pheno$SEX[which(pheno$SEX=="F")]=2
#pheno$SEX[which(pheno$SEX=="M")]=1
#write.table(pheno,paste(input,"mycovpca.txt",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")

#load(paste(input,"GRID_DEMOGRAPHICS.Aug2017.RData",sep ="" ))
#selectedPatientsTable<-read.csv(paste(input,"20180514_PatientsIntensityCutoff.csv",sep = ""),header=T,as.is=T,row.names=1)
#sum(selectedPatientsTable[,6]==0)#78 trts, 7052 controls
#datafam=read.table(paste(input,"totaldata_extractqc.fam",sep = ""),header = FALSE,sep = " ")
selectedPatientsTable[,7]=row.names(selectedPatientsTable)
colnames(selectedPatientsTable)[7]="GRID_DEMOGRAPHICS"
colnames(datafam)[1]="GRID_DEMOGRAPHICS"
pheno=merge(datafam,selectedPatientsTable,by="GRID_DEMOGRAPHICS",sort = FALSE)
pheno=merge(pheno,demographics,by="GRID_DEMOGRAPHICS")
pheno=pheno[,c(1:2,16:17)]
pheno$SEX=as.character(pheno$SEX)
pheno$SEX[which(pheno$SEX=="F")]=2
pheno$SEX[which(pheno$SEX=="M")]=1
#pheno$SEX[which(pheno$SEX=="UNK")]=0
#pheno$RACE=ifelse(pheno$RACE=="W",1,2)
#write.table(pheno,"mycov.txt",row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")

allpca=read.table(paste(input,"totaldata_extractqcpca.eigenvec",sep = ""),sep=" ",header = TRUE)
allpca[,13]=allpca[,2]
colnames(allpca)[13]="GRID_DEMOGRAPHICS"
pheno=merge(pheno,allpca,by="GRID_DEMOGRAPHICS",sort = FALSE)
pheno=pheno[,c(1:4,7:8)]
write.table(pheno,file=paste(input,"mycovpca.txt",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")
