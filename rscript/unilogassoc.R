#univariate logistic regression
#to be edited by the user
args=commandArgs(TRUE)
resultdir=args[1]
mutation=args[2] #typed or imputed SNPs
unilog=read.table(paste(resultdir,"unilog_4covs_jak2",sep = ""),header = TRUE)
unilog=unilog[order(unilog$P),]
write.table(unilog,paste(resultdir,"unilog_4covs_jak2.csv",sep=""),row.names=FALSE,quote = FALSE,sep = ",")

#to make the manhattan plot
##using the qqman package in r
library(qqman)
rainbow(22)
#unilog=read.table("unilogassoc.assoc.logistic",header = TRUE)
unilog=read.table(paste(resultdir,"unilogassoc_",mutation,".assoc.logistic",sep = ""),header = TRUE)
unilogadd=unilog[which(!is.na(unilog$P)),]
manhattandata=unilogadd[,c("CHR","BP","P","SNP")]
png(paste(resultdir,"manhattan_",mutation,"_4covs.png",sep=""),type="cairo",width = 1000,height = 700)
manhattan(manhattandata,col=c("#FF0000FF","#FF4600FF", "#FF8B00FF" ,"#FFD100FF" ,"#E8FF00FF",
                              "#A2FF00FF", "#5DFF00FF" ,"#17FF00FF" ,"#00FF2EFF" ,"#00FF74FF",
                              "#00FFB9FF", "#00FFFFFF" ,"#00B9FFFF" ,"#0074FFFF" ,"#002EFFFF",
                              "#1700FFFF" ,"#5D00FFFF" ,"#A200FFFF" ,"#E800FFFF" ,"#FF00D1FF",
                              "#FF008BFF", "#FF0046FF"),suggestiveline=TRUE,chrlabs = as.character(1:22))
dev.off()

#extract significant snps from the typed snps data and imputed snps data
#typed snps
#typedsnps=read.csv("unilog_typed_4covs.csv",header = TRUE)
#typedsnps=read.csv(paste(resultdir,"unilog_typed_4covs.csv",sep = ""),header = TRUE)
#extract_typedsnps=typedsnps$SNP
#write.table(extract_typedsnps,"typedsnps.txt",row.names=FALSE,quote = FALSE,col.names = FALSE)
#write.table(extract_typedsnps,paste(resultdir,"typedsnps.txt",sep=""),row.names=FALSE,quote = FALSE,col.names = FALSE)
#imputedsnps=read.csv("unilog_imputed_4covs.csv",header = TRUE)
#imputedsnps=read.csv(paste(resultdir,"unilog_imputed_4covs.csv",sep = ""),header = TRUE)
#extract_imputedsnps=imputedsnps$SNP
#write.table(extract_imputedsnps,"imputedsnps.txt",row.names=FALSE,quote = FALSE,col.names = FALSE)
#write.table(extract_imputedsnps,paste(resultdir,"imputedsnps.txt",sep=""),row.names=FALSE,quote = FALSE,col.names = FALSE)














