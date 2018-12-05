#!/bin/bash
#after imputation, arrange the chunks for each chromosome and association analysis in plink
chmod u+x parameters.sh
source parameters.sh
#
#combine all chunks in each chromosome
module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R
Rscript ${rscript}postimputation.R ${input} ${resultdir} ${impute2} ${reference} ${refdir}
#choose to do on accre or local
echo "do you want to do it on local or cluster: "
read answer

if [ "$answer" == "local" ]; then
for chr in `seq 1 22`; do
phasedfile="cleantotaldata_extractqc.chr${chr}.phased"
chmod u+x ${input}maxposition
echo "maxposition=$(gawk -v chr=${chr} 'FNR==chr {print}' ${input}maxposition);
for chunk in \`seq 1 \${maxposition}\`; do
cat ${resultdir}impute2/chr${chr}/${phasedfile}.chunk\${chunk}.impute2 >> ${resultdir}impute2/chr${chr}_chunkall.gen;
done" > ${input}IMPUTE2_ALL_${chr};
done 
#to do it parallel on 22 chromosomes together 
for chr in `seq 1 22`; do
chmod u+x ${input}IMPUTE2_ALL_${chr};
echo "${input}IMPUTE2_ALL_${chr}" >> ${input}IMPUTE2_ALL;
done
cat ${input}IMPUTE2_ALL | parallel 

else
#do on accre
for chr in `seq 1 22`; do
phasedfile="cleantotaldata_extractqc.chr${chr}.phased"
echo '#!/bin/bash' > ${input}chr_impute${chr}.slurm;
echo "#SBATCH --account=h_vangard_1
#SBATCH --mail-user=siwei.zhang@vumc.org
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --ntasks=1 
#SBATCH --cpus-per-task=12
#SBATCH --time=200:00:00
#SBATCH --mem=200G
#SBATCH --output=chr_impute${chr}.out
chmod u+x /scratch/h_vangard_1/zhans23/myelofibrosis/shellscript/parameters.sh
source /scratch/h_vangard_1/zhans23/myelofibrosis/shellscript/parameters.sh
maxposition=$(gawk -v chr=${chr} 'FNR==chr {print}' ${input}maxposition);
for chunk in \`seq 1 \${maxposition}\`; do
cat ${resultdir}impute2/chr${chr}/${phasedfile}.chunk\${chunk}.impute2 >> ${resultdir}impute2/chr${chr}_chunkall.gen;
done" >> ${input}chr_impute${chr}.slurm
done
for chr in `seq 16 22`; do
sbatch ${input}chr_impute${chr}.slurm
done

fi
#
#
#after combining all chunks together for each chromosome, convert them to the plink format data files, SNPs with uncertainty greater than 0.2 are treated as missing
echo "do you want to do it on local or cluster: "
read answer

if [ "$answer" == "local" ]; then

for chr in `seq 1 22`; do 
echo "${plink} --data --gen ${resultdir}impute2/chr${chr}_chunkall.gen --sample ${resultdir}shapeit/cleantotaldata_extractqc.chr${chr}.phased.sample \
--hard-call-threshold 0.2 --oxford-single-chr ${chr} \
--make-bed --out ${resultdir}impute2/chr${chr}_chunkall" >> ${input}convert_plink.sh
done
cat ${input}convert_plink.sh | parallel
#
#
else
#do it on accre
for chr in `seq 1 22`; do
echo '#!/bin/bash' > ${input}plink${chr}.slurm;
echo "#SBATCH --account=h_vangard_1
#SBATCH --mail-user=siwei.zhang@vumc.org
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=100:00:00
#SBATCH --mem=200G
#SBATCH --output=plink${chr}.out
#directory
chmod u+x /scratch/h_vangard_1/zhans23/myelofibrosis/shellscript/parameters.sh
source /scratch/h_vangard_1/zhans23/myelofibrosis/shellscript/parameters.sh
${plink} --data --gen ${resultdir}impute2/chr${chr}_chunkall.gen --sample ${resultdir}shapeit/cleantotaldata_extractqc.chr${chr}.phased.sample \
--hard-call-threshold 0.2 --oxford-single-chr ${chr} \
--make-bed --out ${resultdir}impute2/chr${chr}_chunkall" >> ${input}plink${chr}.slurm
done
for chr in `seq 7 22`; do
sbatch ${input}plink${chr}.slurm;
done

fi
#
#
#after converting into plink format, merge all chromosomes together
for chr in `seq 2 22`; do
echo "${resultdir}impute2/chr${chr}_chunkall.bed ${resultdir}impute2/chr${chr}_chunkall.bim ${resultdir}impute2/chr${chr}_chunkall.fam" >> ${input}all_chromosomes.txt;
done
${plink} --bfile ${resultdir}impute2/chr1_chunkall --merge-list ${input}all_chromosomes.txt --make-bed --out ${resultdir}impute2/allchr
#remove SNPs with 3+ alleles, detect which chromosome these SNPs on
${plink} --bfile ${resultdir}impute2/chr17_chunkall --exclude ${resultdir}impute2/allchr-merge.missnp --make-bed --out ${resultdir}impute2/chr17_chunkall
${plink} --bfile ${resultdir}impute2/chr1_chunkall --merge-list ${input}all_chromosomes.txt --make-bed --out ${resultdir}impute2/allchr
#
#after getting one plink format file, exclude snps with certainty for best guess <0.9
#firstly get a list of excluded snps for chromosome
for chr in `seq 1 22`;do
maxposition=(50 49 40 39 37 35 32 30 29 28 27 27 24 22 21 19 17 16 12 13 10 11);
for chunk in `seq 1 ${maxposition[${chr}-1]}`;do
gawk '$8 < 0.9 {print $2}' ${resultdir}impute2/chr${chr}/cleantotaldata_extractqc.chr${chr}.phased.chunk${chunk}.impute2_info >> ${input}excludesnps.txt
done
done
#after getting one plink format data file, change the phenotype column in the .fam file
#Rscript ${rscript}changepheno2.R ${input} ${resultdir}
#
#remove SNPs with duplicate positions   
${plink} --bfile ${resultdir}impute2/allchr --noweb --list-duplicate-vars ids-only suppress-first --out ${input}duplicatesnps_allchr
${plink} --bfile ${resultdir}impute2/allchr --noweb --exclude ${input}duplicatesnps_allchr.dupvar --make-bed --out ${resultdir}impute2/allchr2
#exclude snps with certainty for best guess < 0.9
${plink} --bfile ${resultdir}impute2/allchr2 --exclude ${input}excludesnps.txt --make-bed --out ${resultdir}impute2/cleanchr
#extract imputed SNPs which in the final cleanchr plink file but not in the input cleantotaldataqc_extract
##create a file with all the SNPs in the totaldataqc_extract.bim according to the physical position
#gawk '{print $1"_"$4}' ${input}totaldataqc_extractqc.bim > ${input}snpstyped
##create a file with all the SNPs in the cleanchr.bim according to the physical position
#gawk '{print $1"_"$4}' ${resultdir}impute2/cleanchr.bim > ${input}snpsall
##create a file with all the SNPs in the cleanchr.bim but not in the totaldataqc_extract.bim >> imputed SNPs
#comm -13 <(sort ${input}snpstyped) <(sort ${input}snpsall) > ${input}imputedsnps | sort ${input}imputedsnps 
#gawk -F "_" '{$3=$2+1; print $1,$2,$3,"R"NR}' ${input}imputedsnps > ${input}imputedsnpslist 
#extract the imputed snps from cleanchr
#${plink} --noweb --bfile ${resultdir}impute2/cleanchr --extract range ${input}imputedsnpslist --make-bed --out ${resultdir}impute2/cleanchr_imputed
#
#do the post imputation quality control
${plink} --bfile ${resultdir}impute2/cleanchr --noweb --geno ${SNPcallrate} --maf ${maf} --hwe ${hwe} --make-bed --out ${resultdir}impute2/cleanchr_qc
#then do the logistic regression separately on imputed snps and typed snps and plot the manhattan plot
#imputed data
#${plink} --bfile ${resultdir}impute2/cleanchr_imputedqc --noweb --logistic hide-covar --ci 0.95 --covar ${input}mycovpca2_qc.txt --out ${resultdir}unilogassoc_imputed_jak2
#gawk '$12!="NA" && $12<=0.00000005 || NR==1 {print}' ${resultdir}unilogassoc_imputed.assoc.logistic > ${resultdir}unilog_imputed_4covs_jak2
#Rscript ${rscript}unilogassoc.R ${resultdir} imputed
#typed data
#${plink} --bfile ${input}totaldataqc_extractqc --noweb --logistic hide-covar --ci 0.95 --covar ${input}mycovpca.txt --out ${resultdir}unilogassoc_typed_jak2
#gawk '$12!="NA" && $12<=0.00000005 || NR==1 {print}' ${resultdir}unilogassoc_typed_jak2.assoc.logistic > ${resultdir}unilog_typed_4covs_jak2
#run rscript unilogassoc.R
#Rscript ${rscript}unilogassoc.R ${resultdir} typed
#
#combine all the results together and make one manhattan plot
#sed '1d' ${resultdir}unilogassoc_typed_jak2.assoc.logistic > ${resultdir}unilogassoc_typed_jak2.assoc.logistic_noheader 
#cat ${resultdir}unilogassoc_imputed_jak2.assoc.logistic >> ${resultdir}unilogassoc_combined_jak2.assoc.logistic
#cat ${resultdir}unilogassoc_typed_jak2.assoc.logistic_noheader >> ${resultdir}unilogassoc_combined_jak2.assoc.logistic
#gawk '$12!="NA" && $12<=0.00000005 || NR==1 {print}' ${resultdir}unilogassoc_combined_jak2.assoc.logistic > ${resultdir}unilog_combined_4covs_jak2
#Rscript ${rscript}unilogassoc.R ${resultdir} combined

#QQ plot
#Rscript ${rscript}visualization.R ${resultdir}


#extract significant snps
#${plink} --bfile ${input}totaldataqc_extract --extract --extract ${resultdir}typedsnps.txt --recodeA --out ${resultdir}extract_typedsnps
#${plink} --bfile ${resultdir}impute2/cleanchr_imputedqc --extract ${resultdir}imputedsnps.txt --recodeA --out ${resultdir}extract_imputedsnps


#jak2
Rscript ${rscript}changepheno2.R ${input} ${resultdir}
${plink} --bfile ${resultdir}impute2/cleanchr_qc --noweb --logistic hide-covar --ci 0.95 --covar ${input}mycovpca.txt --out ${resultdir}unilogassoc_jak2
gawk '$12!="NA" && $12<=0.0000005 || NR==1 {print}' ${resultdir}unilogassoc_jak2.assoc.logistic > ${resultdir}unilog_4covs_jak2
Rscript ${rscript}unilogassoc.R ${resultdir} jak2


#dnmt3a
Rscript ${rscript}changepheno3.R ${input} ${resultdir}
${plink} --bfile ${resultdir}impute2/cleanchr_qc --noweb --logistic hide-covar --ci 0.95 --covar ${input}mycovpca.txt --out ${resultdir}unilogassoc_dnmt3a
gawk '$12!="NA" && $12<=0.0000005 || NR==1 {print}' ${resultdir}unilogassoc_dnmt3a.assoc.logistic > ${resultdir}unilog_4covs_dnmt3a
Rscript ${rscript}unilogassoc.R ${resultdir} dnmt3a
#extract significant snps
gawk '$2!="SNP"{print $2}' ${resultdir}unilog_4covs_jak2 > ${input}jak2sig.txt
gawk '$2!="SNP"{print $2}' ${resultdir}unilog_4covs_dnmt3a > ${input}dnmt3asig.txt
${plink} --bfile ${resultdir}impute2/cleanchr_qc --extract ${input}jak2sig.txt --recode A --out ${resultdir}extract_sigsnpsjak2
${plink} --bfile ${resultdir}impute2/cleanchr_qc --extract ${input}dnmt3asig.txt --recodeA --out ${resultdir}extract_sigsnpsdnmt3a


${plink} --bfile ${resultdir}impute2/cleanchr_qc --noweb --logistic hide-covar --ci 0.95 --covar ${input}mycovpca.txt --out ${resultdir}unilogassoc_myelofibrosis
gawk '$12!="NA" && $12<=0.0000005 || NR==1 {print}' ${resultdir}unilogassoc_jak2.assoc.logistic > ${resultdir}unilog_4covs_jak2

#=============================================================
#annotation
#annotation="/scratch/zhans23/siwei/gwas/pulmonary_hypertension/annotation/"
annotation="/scratch/h_vangard_1/zhans23/myelofibrosis/annotation/"
tar xzvf /scratch/zhans23/siwei/gwas/pulmonary_hypertension/annovar.latest.tar.gz --directory ${annotation}
#extract a chromosome for example
#gunzip -c ${reference}ALL_1000G_phase1integrated_v3_annotated_legends/ALL_1000G_phase1integrated_v3_chr1_impute.legend.gz > ${annotation}chr1_legend
#gawk '$2==731718 {print}' ${annotation}chr1_legend >> ${annotation}chr1_test
#prepare the input vcf file
##make a list of significant snps <5*10^-5
#gawk -F"," '$2!="SNP" {print $2}' ${resultdir}unilog_4covs_ph.csv > ${annotation}mysnps.txt
gawk '$2!="SNP" {print $2}' ${resultdir}unilog_4covs_ph > ${annotation}mysnps.txt
gawk '$2!="SNP" {print $2}' ${resultdir}unilog_4covs_myelofibrosis > ${annotation}mysnps.txt
##extract the significant snps plink format < 5*10^-5
${plink} --bfile ${resultdir}impute2/cleanchr_qc --extract ${annotation}mysnps.txt --make-bed --out ${annotation}sigsnps
#use R script to change the bim file: minor/major to alt/ref 

##convert to vcf format
${plink} --bfile ${annotation}sigsnps --recode vcf --out ${annotation}sigsnpsvcf

#download the database??
perl ${annotation}annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene ${annotation}
perl ${annotation}annovar/annotate_variation.pl -buildver hg19 -downdb cytoBand ${annotation}
perl ${annotation}annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar exac03 ${annotation}
perl ${annotation}annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar avsnp147 ${annotation}
perl ${annotation}annovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar dbnsfp30a ${annotation}
#focus on chromosome 6 and chromosome 2
#wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/phase1/analysis_results/integrated_call_sets/ALL.chr2.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.vcf.gz -P ${annotation}
#gunzip ALL.chr1.integrated_phase1_v3.20101123.snps_indels_svs.genotypes.vcf.gz | 
#gawk -v '{print $1,$2,$3,$4,$5}' >> ${annotation}snpsreference.txt;

#annotation in one step using vcf file
${annotation}annovar/table_annovar.pl ${annotation}sigsnpsvcf.vcf ${annotation} -buildver hg19 -out ${annotation}sigannotation -remove -protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a -operation g,r,f,f,f -nastring . -vcfinput 
#annotation in one step using .avinput file
${annotation}annovar/table_annovar.pl ${annotation}sigsnps.avinput ${annotation} -buildver hg19 -out ${annotation}sigannotation2 -remove -protocol refGene,cytoBand,exac03,avsnp147,dbnsfp30a -operation gx,r,f,f,f -nastring . -csvout -polish -xref ${annotation}annovar/example/gene_xref.txt


#annotationin separate steps using .avinput file
#convert vcf file to .avinput
##perl ${annotation}annovar/convert2annovar.pl -format vcf4 ${annotation}sigsnpsvcf.vcf -outfile ${annotation}sigsnps.avinput
##conduct this process in R
#gene based annotation

perl ${annotation}annovar/annotate_variation.pl --geneanno -dbtype refGene -out ${annotation}sigannotation_gene -build hg19 ${annotation}sigsnps.avinput ${annotation}

#visualization of the annotation
gawk '$1==2 {print $1,$2,$3,$12}' ${resultdir}unilog_4covs_ph > ${annotation}chr2