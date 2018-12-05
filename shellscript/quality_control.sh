#!/bin/bash
#need download plink:!!!download the latest 1.9 version, otherwise it will take more time
#reference: each step follows the procedures in the Eric Reed's R_based gwas pipeline paper
chmod u+x parameters.sh
source parameters.sh
#
#prepare the bed/bim/fam plink format data, name your plink format data as totaldata_extract
#this part not in the pipeline,I only used it to merge the separate plink format data together for a specific project, you should prepare the bed/bim/fam plink format data to be run in the pipeline by yourself
#==========================merge the datasets
#sorry you cannot see these since privacy
#
#
#
#
#
#
#
#
#
#==========================quality control
#input is the path of your input files during the procedure of quality control
#output is the path of your diretory to save the output files
#=========individual and snp missing rate
#control the snp call rate
${plink} --bfile ${rawdatadir}totaldata_extract --noweb --geno ${SNPcallrate} --make-bed --out ${input}qcgeno
#control the individual call rate
${plink} --bfile ${input}qcgeno --noweb --mind ${mind} --make-bed --out ${input}qcgenomind
#control the snp maf
${plink} --bfile ${input}qcgenomind --noweb --maf ${maf} --make-bed --out ${input}qcgenomindmaf
#control the hwe
${plink} --bfile ${input}qcgenomindmaf --noweb --hwe ${hwe} --make-bed --out ${input}qcgenomindmafhwe
#=========sample-level
#=====================
#HETEROZYGOSITY
${plink} --bfile ${input}qcgenomindmafhwe --noweb --het --out ${input}qcgenomindmafhwe
#whether you want to remove samples because of heterozygosity, please answer yes/no
valid="yes"
echo "do you want to remove samples: "
read answer
if [ "$answer" == "$valid" ]; then
#remove subjects,you need to set how many sd outlier, I set removing one of pair with +-3sd here, you can change the threshold
chmod u+x ${rscript}sampleremove.R 
Rscript ${rscript}sampleremove.R ${input}
#remove people since HETEROZYGOSITY
${plink} --bfile ${input}qcgenomindmafhwe --noweb --remove ${input}removesamplelisthet.txt --make-bed --out ${input}qcgenomindmafhwehet
else
${plink} --bfile ${input}qcgenomindmafhwe --noweb --make-bed --out ${rawdatadir}qcgenomindmafhwehet
fi
#LD prune and create a pruned list of SNP IDs for PCA: qcgenomindmafhwehetLD.prune.in
${plink} --bfile ${input}qcgenomindmafhwehet --noweb --indep-pairwise ${LDprune1} ${LDprune2} ${LDprune3} --out ${input}qcgenomindmafhwehetLD
#check IBD and create a list of subjects to remove due to relatedness
${plink} --bfile ${input}qcgenomindmafhwehet --noweb --extract ${input}qcgenomindmafhwehetLD.prune.in --genome --min ${MINIBD} --out ${input}qcgenomindmafhwehetIBD
#
#whether you want to remove samples because of relatedness, please answer yes/no
valid="yes"
echo "do you want to remove samples: "
read answer
if [ "$answer" == "$valid" ]; then
#remove subjects, I set removing one of pair with PI_HAT>0.2 here, you can change the threshold
chmod u+x ${rscript}sampleremove2.R 
Rscript ${rscript}sampleremove2.R ${input}
${plink} --bfile ${input}qcgenomindmafhwehet --noweb --remove ${input}removesamplelist2.txt --make-bed --out ${input}totaldata_extractqc
#
else
{plink} --bfile ${input}qcgenomindmafhwehet --noweb --make-bed --out ${input}totaldata_extractqc
fi




