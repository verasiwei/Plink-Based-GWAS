#!/bin/bash
#============================================SHAPEIT for pre-phasing
chmod u+x parameters.sh
source parameters.sh


#split 22 chromosomes
for chr in `seq 1 22`; do
${plink} --bfile ${input}cleantotaldata_extractqc --chr $chr --make-bed --out ${output}cleantotaldata_extractqc.chr$chr;
done
#alignment of the SNPs between the target set and reference set
for chr in `seq 1 22`; do
${shapeit} -check -B ${output}cleantotaldata_extractqc.chr${chr} -M ${reference}${refdir}genetic_map_chr${chr}_combined_b37.txt \
--input-ref ${reference}${refdir}ALL_1000G_phase1integrated_v3_chr${chr}_impute.hap.gz ${reference}${refdir}/ALL_1000G_phase1integrated_v3_chr${chr}_impute.legend.gz ${reference}${refdir}/ALL_1000G_phase1integrated_v3.sample \
--output-log ${output}chr${chr}.alignment;
done
#
echo "do you want to do it on local or cluster: "
read answer

if [ "$answer" == "cluster" ]; then
#============================to be edited by users
for chr in `seq 1 22`; do
echo '#!/bin/bash' > ${input}SHAPEIT_TASK_${chr}.slurm
echo "#SBATCH --account=h_vangard_1           
#SBATCH --mail-user=siwei.zhang@vumc.org
#SBATCH --mail-type=ALL
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --time=48:00:00
#SBATCH --mem=50G
#SBATCH --output=shapeitjob_${chr}.out
#
chmod u+x parameters.sh
source parameters.sh
phasedfile=\"cleantotaldata_extractqc.chr${chr}\"
\${shapeit} --force --input-bed \${output}\${phasedfile}.bed \${output}\${phasedfile}.bim \${output}\${phasedfile}.fam --input-map \${reference}\${refdir}genetic_map_chr${chr}_combined_b37.txt \
--exclude-snp \${output}chr${chr}.alignment.snp.strand.exclude --output-max \${resultdir}shapeit/\${phasedfile}.phased --thread 12 --output-log \${resultdir}shapeit/\${phasedfile}.phased" >> ${input}SHAPEIT_TASK_${chr}.slurm;
done
for chr in `seq 1 22`; do
sbatch ${input}SHAPEIT_TASK_${chr}.slurm
done
#
else
for chr in `seq 1 22`; do
phasedfile="cleantotaldata_extractqc.chr${chr}";
echo ${shapeit} --input-bed ${output}${phasedfile}.bed ${output}${phasedfile}.bim ${output}${phasedfile}.fam --input-map ${reference}${refdir}genetic_map_chr${chr}_combined_b37.txt \
--exclude-snp ${input}chr${chr}.alignment.snp.strand.exclude --output-max ${resultdir}shapeit2/${phasedfile}.phased --thread 12 --output-log ${resultdir}shapeit2/${phasedfile}.phased >> ${input}SHAPEIT_TASK.sh;
done
cat ${input}SHAPEIT_TASK.sh | parallel
fi