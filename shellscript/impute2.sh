#!/bin/bash
#=============================================imputation
chmod u+x parameters.sh
source parameters.sh
for chr in `seq 1 22`; do 
mkdir ${resultdir}impute2/chr${chr};
done

echo "do you want to do it on local or cluster: "
read answer

if [ "$answer" == "cluster" ]; then
module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R
Rscript ${rscript}splitchr.R ${input} ${resultdir} ${impute2} ${reference} ${refdir}
for chr in `seq 1 22`; do
echo '#!/bin/bash' > ${input}chr${chr}.slurm;
echo "#SBATCH --account=h_cqs
#SBATCH --mail-user=siwei.zhang@vumc.org
#SBATCH --mail-type=ALL
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12 
#SBATCH --time=240:00:00
#SBATCH --mem=200G
#SBATCH --output=chr${chr}.out
#directory
chmod u+x /scratch/h_vangard_1/zhans23/myelofibrosis/shellscript/parameters.sh
source /scratch/h_vangard_1/zhans23/myelofibrosis/shellscript/parameters.sh
cat ${resultdir}impute2/chr${chr}_task | parallel" >> ${input}chr${chr}.slurm
done

for chr in `seq 1 2`; do
sbatch ${input}chr21_${chr}.slurm;
done


else
Rscript ${rscript}splitchr_local.R ${input} ${resultdir} ${impute2} ${reference} ${refdir}
cat ${input}impute2_parallel_task.sh | parallel 

fi