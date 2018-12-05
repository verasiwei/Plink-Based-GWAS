args=commandArgs(TRUE)
input=args[1]
resultdir=args[2]
datafam=read.table(paste(resultdir,"imput2/cleanchr_qc.fam",sep = ""),header = FALSE,sep = " ")
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
write.table(pheno,file = paste(resultdir,"imput2/cleanchr_qc.fam",sep = ""),row.names=FALSE,col.names=FALSE,quote = FALSE,sep = " ")