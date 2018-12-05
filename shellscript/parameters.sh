#!/bin/bash
#==========================to be edited by user
#directory
rawdatadir=""
resultdir=""
plink=""
input=""
output=""
rscript=""
reference=""
shapeit=""
refdir=""
shellscript=""
impute2=""
#
#parameters
SNPcallrate=
maf=
hwe=
mind=
LDprune1=   #LDprune1 is the window size in SNPs
LDprune2=   #LDprune2 is the number of SNPs to shift the window at each step
LDprune3=    #LDprune3 is the multiple correlation coefficient 
IBD= #IBD is the identity by descent, IBD greater than a threshold suggest relatedness, duplicate or sample mixture; here to reduce the file size, create the remove list only based on the files after removing the pairs with IBD<0.1
pca=  #number of parameters to output
#
chmod u+x ${shapeit}
chmod u+x ${plink}
chmod u+x ${impute2}
