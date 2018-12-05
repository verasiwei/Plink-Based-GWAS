#!/bin/bash
#=============================================pca
#LD pruning at first
${plink} --bfile ${input}totaldata_extractqc --noweb --indep-pairwise ${LDprune1} ${LDprune2} ${LDprune3} --out ${input}totaldata_extractqcLD
${plink} --bfile ${input}totaldata_extractqc --extract ${input}totaldata_extractqcLD.prune.in --pca ${pca} header --noweb --out ${input}totaldata_extractqcpca
#covariates
module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R
#pca #number of principle components output in plink
Rscript ${rscript}cov.R ${input} ${resultdir}

