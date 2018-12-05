#!/usr/bin/env python

import os
import subprocess
# import argparse
import config

rawdatadir = config.get_rawdatadir()
resultdir = config.get_resultdir()
inputfile = config.get_inputfile()
plink = config.get_plink()
rscript = config.get_rscript()
reference = config.get_refdir()
output = config.get_output()
refdir = config.get_refdir()
impute2 = config.get_impute2()

# download the reference dataset of 1000 Genome
os.system("wget https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz")
os.system("tar xzvf ALL_1000G_phase1integrated_v3_impute.tgz --directory " + str(reference))

os.system("wget https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_annotated_legends.tgz")
os.system("tar xzvf ALL_1000G_phase1integrated_v3_annotated_legends.tgz --directory " + str(reference))


def preimpute():
    # create a file with all the SNP names that are in the reference set
    subprocess.call((
        "for i in `seq 1 22`; do",
        "gunzip -c ",
        str(reference),
        "ALL_1000G_phase1integrated_v3_annotated_legends/ALL_1000G_phase1integrated_v3_chr${i}_impute.legend.gz | ",
        "gawk -v chr=${i} '$5=='SNP' {print chr" "$2}' >> ",
        str(inputfile),
        "snpsref.txt; done"))

    # get a list of positions of SNPs that are in the target set
    os.system("gawk '{print $1" "$4}' " + str(inputfile) + "totaldata_extractqc.bim > " + str(input) + "snpsraw.txt")
    # get SNPs that are in both the target set and reference set, to make the format corresponding to the --extract range option in plink
    os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
    os.system("Rscript " + str(rscript) + "snpref_raw.R" + str(inputfile))
    # since some SNPs in target set but not in reference set,SNPs that are in both the target set and reference set need to be extracted from the target set, according to the physical position, not the SNP name
    os.system("plink --noweb --bfile " + str(inputfile) + "totaldata_extractqc --extract range " + str(inputfile) + "duplicatesnp --make-bed --out " + str(inputfile) + "cleantotaldata_extractqc")


def preshapeit():
    # split 22 chromosomes
    os.system("for chr in `seq 1 22`; do plink --bfile " + str(inputfile) + " cleantotaldata_extractqc --chr $chr --make-bed --out " + str(output) + "cleantotaldata_extractqc.chr$chr; done")
    # alignment of the SNPs between the target set and reference set
    aligncmd1 = "for chr in `seq 1 22`; do "
    aligncmd2 = "shapeit -check -B " + str(output) + "cleantotaldata_extractqc.chr${chr} -M " + str(reference) + str(refdir) + "genetic_map_chr${chr}_combined_b37.txt --input-ref "
    aligncmd3 = str(reference) + str(refdir) + "ALL_1000G_phase1integrated_v3_chr${chr}_impute.hap.gz " + str(reference) + str(refdir) + "ALL_1000G_phase1integrated_v3_chr${chr}_impute.legend.gz "
    aligncmd4 = str(reference) + str(refdir) + "ALL_1000G_phase1integrated_v3.sample --output-log " + str(output) + "chr${chr}.alignment;done"
    align = aligncmd1 + aligncmd2 + aligncmd3 + aligncmd4
    subprocess.call(align, shell=True)


def shapeit():
    account = input("Please input the account: ")
    mail = input("Please input the mail: ")
    cpus = input("Please input cpus: ")
    time = input("Please input time: ")
    memory = input("Please input memory: ")
    for chr in range(1, 23):
        dir = str(inputfile)
        filename = "SHAPEIT_TASK_%s.slurm" % chr
        filename = "%s%s" % (dir, filename)
        shapeit = open(filename, "w")
        shapeit.write("#!/bin/bash\n")
        shapeitlist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
        shapeitlist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=shapeitjob_%s.out\n" % chr]
        shapeit.writelines(shapeitlist1)
        shapeit.writelines(shapeitlist2)
        phasedfile = "cleantotaldata_extractqc.chr%s" % chr
        shapeitlist3 = ["shapeit --force --input-bed %s%s.bed" % (output, phasedfile), " %s%s.bim" % (output, phasedfile), " %s%s.fam" % (output, phasedfile), " --input-map", " %s%sgenetic_map_chr%s_combined_b37.txt" % (reference, refdir, chr)]
        shapeitlist4 = [" --exclude-snp", " %schr%s.alignment.snp.strand.exclude" % (output, chr), " --output-max", " %sshapeit%s.phased" % (resultdir, phasedfile), " --thread 12 --output-log %sshapeit%s.phased" % (resultdir, phasedfile)]
        shapeit.writelines(shapeitlist3)
        shapeit.writelines(shapeitlist4)
        shapeit.close()


def imputation():
    for chr in range(1, 23):
        os.system("mkdir %simpute2/chr%s" % (resultdir, chr))
    # os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
    # os.system("Rscript %ssplit.R %s %s %s %s %s" % (rscript, inputfile, resultdir, impute2, reference, refdir))
    account = input("Please input the account: ")
    mail = input("Please input the mail: ")
    cpus = input("Please input cpus: ")
    time = input("Please input time: ")
    memory = input("Please input memory: ")
    for chr in range(1, 23):
        dir = str(inputfile)
        filename = "IMPUTE_TASK_%s.slurm" % chr
        filename = "%s%s" % (dir, filename)
        impute = open(filename, "w")
        impute.write("#!/bin/bash\n")  
        imputelist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
        imputelist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=imputejob_%s.out\n" % chr]  
        imputelist3 = ["cat %simpute2/chr%s_task | parallel" % (resultdir, chr)]
        impute.writelines(imputelist1)
        impute.writelines(imputelist2)
        impute.writelines(imputelist3)
        impute.close()
    

preimpute()
preshapeit()
shapeit()
imputation()
    










