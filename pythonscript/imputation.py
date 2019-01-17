#!/usr/bin/env python

import os
# import subprocess
# import argparse
import config

rawdatadir = config.get_rawdatadir()
resultdir = config.get_resultdir()
inputfile = config.get_inputfile()
plink = config.get_plink()
rscript = config.get_rscript()
reference = config.get_reference()
output = config.get_output()
refdir = config.get_refdir()
impute2 = config.get_impute2()
shapeit = config.get_shapeit()

os.system("module load GCC/6.4.0-2.28  OpenMPI/2.1.1 R/3.4.3")
os.system("module load GCC/6.4.0-2.28 Python/3.6.3")
os.system("R --version")
os.system("python --version")

# download the reference dataset of 1000 Genome


def refdat():
        # Phase 1
        os.system("wget https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_impute.tgz")
        os.system("tar xzvf ALL_1000G_phase1integrated_v3_impute.tgz --directory " + str(reference))
        os.system("wget https://mathgen.stats.ox.ac.uk/impute/ALL_1000G_phase1integrated_v3_annotated_legends.tgz")
        os.system("tar xzvf ALL_1000G_phase1integrated_v3_annotated_legends.tgz --directory " + str(reference))
        # Phase 3
        os.system("wget https://mathgen.stats.ox.ac.uk/impute/1000GP_Phase3.tgz")
        os.system("tar xzvf 1000GP_Phase3.tgz --directory " + str(reference))


def preimpute():
        answer = input("Do you want to use 1000 Genome Phase3 or Phase1? Please answer Phase3 or Phase1: ")
        if answer == "Phase1":
                # create a file with all the SNP names that are in the reference set
                SNP = "SNP"
                os.system("for i in `seq 1 22`; do " + "gunzip -c " + str(reference) + "ALL_1000G_phase1integrated_v3_annotated_legends/ALL_1000G_phase1integrated_v3_chr${i}_impute.legend.gz | " + "gawk -v chr=${i} '$5==\"" + str(SNP) + "\" " + "{print chr\"" + " \"$2}' >> " + str(inputfile) + "snpsref.txt; done")
        else:
                # create a file with all the SNP names that are in the reference set
                SNP = "Biallelic_SNP"
                os.system("for i in `seq 1 22`; do " + "gunzip -c " + str(reference) + "1000GP_Phase3/1000GP_Phase3_chr${i}.legend.gz | " + "gawk -v chr=${i} '$5==\"" + str(SNP) + "\" " + "{print chr\"" + " \"$2}' >> " + str(inputfile) + "snpsref.txt; done")
        # get a list of positions of SNPs that are in the target set
        os.system("gawk '{print $1\"" + " \"$4}' " + str(inputfile) + "totaldata_extractqc.bim > " + str(inputfile) + "snpsraw.txt")
        # get SNPs that are in both the target set and reference set, to make the format corresponding to the --extract range option in plink
        os.system("Rscript " + str(rscript) + "snpref_raw.R " + str(inputfile))
        # since some SNPs in target set but not in reference set,SNPs that are in both the target set and reference set need to be extracted from the target set, according to the physical position, not the SNP name
        os.system(str(plink) + " --noweb --bfile " + str(inputfile) + "totaldata_extractqc --extract range " + str(inputfile) + "duplicatesnp --make-bed --out " + str(inputfile) + "cleantotaldata_extractqc")


def preshapeit():
        # split 22 chromosomes
        # os.system("for chr in `seq 1 22`; do " + str(plink) + " --noweb --bfile " + str(inputfile) + "cleantotaldata_extractqc --chr $chr --make-bed --out " + str(output) + "cleantotaldata_extractqc.chr$chr; done")
        os.system("chmod u+x " + str(shapeit))
        answer = input("Do you want to use 1000 Genome Phase3 or Phase1? Please answer Phase3 or Phase1: ")
        if answer == "Phase1":
                # alignment of the SNPs between the target set and reference set
                aligncmd1 = "for chr in `seq 1 22`; do "
                aligncmd2 = str(shapeit) + " -check -B " + str(output) + "cleantotaldata_extractqc.chr${chr} -M " + str(reference) + str(refdir) + "genetic_map_chr${chr}_combined_b37.txt --input-ref "
                aligncmd3 = str(reference) + str(refdir) + "ALL_1000G_phase1integrated_v3_chr${chr}_impute.hap.gz " + str(reference) + str(refdir) + "ALL_1000G_phase1integrated_v3_chr${chr}_impute.legend.gz "
                aligncmd4 = str(reference) + str(refdir) + "ALL_1000G_phase1integrated_v3.sample --output-log " + str(output) + "chr${chr}.alignment;done"
                align = aligncmd1 + aligncmd2 + aligncmd3 + aligncmd4
                os.system(align)
        else:
                # alignment of the SNPs between the target set and reference set
                aligncmd1 = "for chr in `seq 1 22`; do "
                aligncmd2 = str(shapeit) + " -check -B " + str(output) + "cleantotaldata_extractqc.chr${chr} -M " + str(reference) + "1000GP_Phase3/genetic_map_chr${chr}_combined_b37.txt --input-ref "
                aligncmd3 = str(reference) + "1000GP_Phase3/1000GP_Phase3_chr${chr}.hap.gz " + str(reference) + str(refdir) + "1000GP_Phase3/1000GP_Phase3_chr${chr}.legend.gz "
                aligncmd4 = str(reference) + str(refdir) + "1000GP_Phase3.sample --output-log " + str(output) + "chr${chr}.alignment;done"
                align = aligncmd1 + aligncmd2 + aligncmd3 + aligncmd4
                os.system(align)


def doshapeit():
    account = input("Please input the account: ")
    mail = input("Please input the mail: ")
    cpus = input("Please input cpus: ")
    time = input("Please input time: ")
    memory = input("Please input memory: ")
    for chr in range(1, 23):
        dir = str(inputfile)
        filename = "SHAPEIT_TASK_%s.slurm" % chr
        filename = "%s%s" % (dir, filename)
        shapeitfile = open(filename, "w")
        shapeitfile.write("#!/bin/bash\n")
        shapeitlist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
        shapeitlist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=shapeitjob_%s.out\n" % chr]
        shapeitfile.writelines(shapeitlist1)
        shapeitfile.writelines(shapeitlist2)
        phasedfile = "cleantotaldata_extractqc.chr%s" % chr
        shapeitlist3 = [str(shapeit), " --force --input-bed %s%s.bed" % (output, phasedfile), " %s%s.bim" % (output, phasedfile), " %s%s.fam" % (output, phasedfile), " --input-map", " %s%sgenetic_map_chr%s_combined_b37.txt" % (reference, refdir, chr)]
        shapeitlist4 = [" --exclude-snp", " %schr%s.alignment.snp.strand.exclude" % (output, chr), " --output-max", " %sshapeit/%s.phased" % (resultdir, phasedfile), " --thread 12 --output-log %sshapeit%s.phased" % (resultdir, phasedfile)]
        shapeitfile.writelines(shapeitlist3)
        shapeitfile.writelines(shapeitlist4)
        shapeitfile.close()


def imputation():
    largesample = input("Please input whether the number of samples is very large (Please answer yes or no): ")
    if largesample == "no":
            os.system("Rscript " + str(rscript) + "splitchr.R " + str(inputfile) + " " + str(resultdir) + " " + str(impute2) + " " + str(reference) + " " + str(refdir))
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
    else:
            os.system("Rscript " + str(rscript) + "splitlarge.R " + str(inputfile) + " " + str(resultdir) + " " + str(impute2) + " " + str(reference) + " " + str(refdir))
            account = input("Please input the account: ")
            mail = input("Please input the mail: ")
            cpus = input("Please input cpus: ")
            time = input("Please input time: ")
            memory = input("Please input memory: ")
            for chr in range(1, 23):
                    for i in range(1, 12):
                            dir = str(inputfile)
                            filename = "IMPUTE_TASK_%s_%s.slurm" % (chr, i)
                            filename = "%s%s" % (dir, filename)
                            impute = open(filename, "w")
                            impute.write("#!/bin/bash\n") 
                            imputelist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
                            imputelist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=imputejob_%s_%i.out\n" % chr]
                            imputelist3 = ["cat %simpute2/chr%s_task_%s | parallel" % (resultdir, chr, i)]
                            impute.writelines(imputelist1)
                            impute.writelines(imputelist2)
                            impute.writelines(imputelist3)
                            impute.close()
    for chr in range(1, 23):
            os.system("mkdir %simpute2/chr%s" % (resultdir, chr))
    # os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
    # os.system("Rscript %ssplit.R %s %s %s %s %s" % (rscript, inputfile, resultdir, impute2, reference, refdir))
    

refdat()
preimpute()
preshapeit()
doshapeit()
for chr in range(1, 23):
        os.system("sbatch " + str(inputfile) + "SHAPEIT_TASK_%s.slurm" % chr)
imputation()
for chr in range(1, 23):
        os.system("sbatch " + str(inputfile) + "IMPUTE_TASK_%s.slurm" % chr)










