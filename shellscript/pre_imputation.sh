#!/bin/bash
#imputation
#sed -i 's/\r$//' pipeline.sh
#==========================to be edited by user
#directory
chmod u+x parameters.sh
source parameters.sh
#
#download the reference dataset of 1000 Genome
wget https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz
tar xzvf ALL_1000G_phase1integrated_v3_impute.tgz --directory ${reference}
wget https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_annotated_legends.tgz
tar xzvf ALL_1000G_phase1integrated_v3_annotated_legends.tgz --directory ${reference}
#
#create a file with all the SNP names that are in the reference set
for i in `seq 1 22`; do 
gunzip -c ${reference}ALL_1000G_phase1integrated_v3_annotated_legends/ALL_1000G_phase1integrated_v3_chr${i}_impute.legend.gz | 
gawk -v chr=${i} '$5=="SNP" {print chr" "$2}' >> ${input}snpsreference.txt;
done
#get a list of positions of SNPs that are in the target set
gawk '{print $1" "$4}' ${input}totaldata_extractqc.bim > ${input}snpsraw.txt
#get SNPs that are in both the target set and reference set, to make the format corresponding to the --extract range option in plink
Rscript ${rscript}snpref_raw.R ${input}
#since some SNPs in target set but not in reference set,SNPs that are in both the target set and reference set need to be extracted from the target set, according to the physical position, not the SNP name
${plink} --noweb --bfile ${input}totaldata_extractqc --extract range ${input}duplicatesnp --make-bed --out ${input}cleantotaldata_extractqc
#







