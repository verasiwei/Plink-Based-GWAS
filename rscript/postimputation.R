#post_imputation
args=commandArgs(TRUE)
input=args[1]
resultdir=args[2]
impute2=args[3]
reference=args[4]
refdir=args[5]
options(scipen = 999)
for (chr in 1:22){
  maxposition=c()
  phasedfile=paste("cleantotaldata_extractqc.chr",chr,".phased",sep = "")
  system(paste("gawk '{print $3}' ",resultdir,"shapeit/",phasedfile,".haps > ",input,"positions",sep = ""))
  positions=read.table(paste(input,"positions",sep = ""),header = FALSE)
  maxposition=as.integer(positions[nrow(positions),]/5000000)+1
  system(paste("echo ",maxposition," >> ",input,"maxposition",sep = ""))
}
