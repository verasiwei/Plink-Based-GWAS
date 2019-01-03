#!/usr/bin/env Rscript
#===GWAS Pipeline=======
#TBILab: Siwei Zhang
#December, 2018

args=commandArgs(trailingOnly=TRUE)
dir=args[1]
files=args[2]
chrs=args[3]

#Do the annotation
source("https://bioconductor.org/biocLite.R")
#biocLite("GenomicRanges")
biocLite("BSgenome")
biocLite("BSgenome.Hsapiens.UCSC.hg19")
library(BSgenome.Hsapiens.UCSC.hg19)
#BSgenome.Hsapiens.UCSC.hg19
#overview
genome <- BSgenome.Hsapiens.UCSC.hg19
seqlengths(genome)
seqnames(genome)
#Hsapiens$chr2

#read in significant snp information file
#library(pegas)
#vcf=read.vcf("sigsnpsvcf.vcf")
snpinfo=read.table(paste(dir,files,sep=""),header = FALSE,sep="\t")
colnames(snpinfo)=c("CHR","SNP","Unknown","BP","Minor","Major")

#to get the reference allele
chrs=strsplit(chrs,",")
chrs=chrs[[1]]
chrs = seqnames(Hsapiens)[c(chrs)]
sigsnpref=c()
k=1
m=1
for (i in c(chrs)) {
  for (j in k:(k+nrow(snpinfo[which(snpinfo$CHR==i),])-1) ) {
    sigsnpref = c(sigsnpref,as.character(getSeq(Hsapiens, names=chrs[m], start=snpinfo[j,"BP"], end=snpinfo[j,"BP"])))
  }
  k=k+nrow(snpinfo[which(snpinfo$CHR==i),])
  m=m+1
}
sigsnpref.dat=data.frame(sigsnpref)
snpinfo$ref=sigsnpref.dat$sigsnpref
snpinfo$Minor=as.character(snpinfo$Minor)
snpinfo$Major=as.character(snpinfo$Major)
snpinfo$ref=as.character(snpinfo$ref)


#check unmatch
snpinfo[which((snpinfo$Major)!=(snpinfo$ref)),"Minor"]=snpinfo[which((snpinfo$Major)!=(snpinfo$ref)),"Major"]
snpinfo$Major=snpinfo$ref
snpinfo=snpinfo[,c(1:6)]
write.table(snpinfo,paste(dir,"sigsnps.bim",sep=""),row.names = FALSE,col.names=FALSE,sep = "\t",quote = FALSE)

#prepare the .avinput file 
snpinfo$SNP=snpinfo$BP
snpinfo$Unknown=snpinfo$BP
snpinfo$Alt=snpinfo$Minor
snpinfo=snpinfo[,c(1,2,3,6,7)]
colnames(snpinfo)=c("CHR","Start","End","Ref","Alt")
write.table(snpinfo,paste(dir,"sigsnps.avinput",sep=""),row.names = FALSE,col.names=FALSE,sep = "\t",quote = FALSE)

