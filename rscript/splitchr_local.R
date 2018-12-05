#if do it on local
args=commandArgs(TRUE)
input=args[1]
resultdir=args[2]
impute2=args[3]
reference=args[4]
refdir=args[5]
options(scipen = 999)
for (chr in 1:22) {
  phasedfile=paste("cleantotaldataqc_extract.chr",chr,".phased",sep = "")
  system(paste("gawk '{print $3}' ",resultdir,"shapeit/",phasedfile,".haps > ",input,"positions",sep = ""))
  positions=read.table(paste(input,"positions",sep = ""),header = FALSE)
  maxposition=as.integer(positions[nrow(positions),]/5000000)+1
  start=0
  for (chunk in 1:maxposition) {
    endchr=start+5000000
    startchr=start+1
    system(paste("echo ",impute2," -use_prephased_g -known_haps_g ",resultdir,"shapeit2/",phasedfile,".haps -m ",reference,refdir,"genetic_map_chr",chr,"_combined_b37.txt -h ",reference,refdir,"ALL_1000G_phase1integrated_v3_chr",chr,"_impute.hap.gz -l ",reference,refdir,"ALL_1000G_phase1integrated_v3_chr",chr,"_impute.legend.gz -int ",startchr," ",endchr," -Ne 20000 -buffer 400 -o ",resultdir,"impute2/chr",chr,"/",phasedfile,".chunk",chunk,".impute2 >> ",input,"impute2_parallel_task.sh",sep=""))
    start=endchr
  }
}