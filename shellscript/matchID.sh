#This procedure is specific for this project since some IDs do not match between genetic data and clinical data, could be a reference, but not in the pipeline
#and add the phenotype column to the .fam data
#directory
chmod u+x parameters.sh
source parameters.sh
#
#since in the imputation procedure, shapeit does not allow the duplicate SNPs of the same positions, so remove duplicate SNPs of same position
${plink} --bfile ${rawdatadir}totaldata --noweb --list-duplicate-vars ids-only suppress-first --out ${input}duplicatesnps
${plink} --bfile ${rawdatadir}totaldata --noweb --exclude ${input}duplicatesnps.dupvar --make-bed --out ${rawdatadir}totaldatanodup

chmod u+x ${rscript}mylist.r
module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R
Rscript ${rscript}mylist.r ${input} ${rawdatadir}
${plink} --bfile ${rawdatadir}totaldatanodup --keep ${input}mylist.txt --noweb --chr 1-22 --make-bed --out ${rawdatadir}totaldata_extract
#add the phenotype in totaldataqc_extract.fam
Rscript ${rscript}changepheno.R ${input} ${rawdatadir}