#!/usr/bin/env python

import os
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
SNPcallrate = config.get_SNPcallrate()
maf = config.get_maf()
hwe = config.get_hwe()


def postimputation():
    # combine all chunks in each chromosome
    os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
    os.system("Rscript %spostimputation.R %s %s %s %s %s" % (rscript, inputfile, resultdir, impute2, reference, refdir))
    account = input("Please input the account: ")
    mail = input("Please input the mail: ")
    cpus = input("Please input cpus: ")
    time = input("Please input time: ")
    memory = input("Please input memory: ")
    for chr in range(1, 23):
        phasedfile = "cleantotaldata_extractqc.chr%s.phased" % (chr)
        dir = str(inputfile)
        filename = "combinechr_TASK_%s.slurm" % chr
        filename = "%s%s" % (dir, filename)
        combinechr = open(filename, "w")
        combinechr.write("#!/bin/bash\n")
        combinechrlist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
        combinechrlist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=imputejob_%s.out\n" % chr]
        combinechr.writelines(combinechrlist1)
        combinechr.writelines(combinechrlist2)
        maxposition = os.popen("gawk -v chr=%s 'FNR==chr {print}' %smaxposition" % (chr, inputfile))
        maxposition = "%d" % maxposition + 1
        combinechrlist3 = ["for chunk in `seq 1 %s`;do\n" % maxposition]
        combinechrlist4 = ["cat %simpute2/chr%s/%s.chunk${chunk}.impute2 >> %simpute2/chr%s_chunkall.gen;done" % (resultdir, chr, phasedfile, resultdir, chr)]
        combinechr.writelines(combinechrlist3)
        combinechr.writelines(combinechrlist4)
        combinechr.close()
    # after combining all chunks together for each chromosome, convert them to the plink format data files, SNPs with uncertainty greater than 0.2 are treated as missing
    for chr in range(1, 23):
        dir2 = str(inputfile)
        filename2 = "chrplink_TASK_%s.slurm" % chr
        filename2 = "%s%s" % (dir2, filename2)
        chrplink = open(filename2, "w")
        chrplink.write("#!/bin/bash\n")
        chrplinklist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
        chrplinklist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=imputejob_%s.out\n" % chr]
        chrplink.writelines(chrplinklist1)
        chrplink.writelines(chrplinklist2)
        chrplinklist3 = ["plink --data -gen %simpute2/chr%s_chunkall.gen " % (resultdir, chr),  "--sample %sshapeit/cleantotaldata_extractqc.chr%s.phased.sample " % (resultdir, chr), "--hard-call-threshold 0.2 --oxford-single-chr %s " % (chr)]
        chrplinklist4 = ["--make-bed --out %simpute2/chr%s_chunkall" % (resultdir, chr)]
        chrplink.writelines(chrplinklist3)
        chrplink.writelines(chrplinklist4)
        chrplink.close()
    # after converting into plink format, merge all chromosomes together
    dir3 = str(inputfile)
    filename3 = "combinechrplink.tzt"
    filename3 = "%s%s" % (dir3, filename3)
    combinechrplink = open(filename3, "a")
    for chr in range(1, 23):
        combinechrplinklist = ["%simpute2/chr%s_chunkall.bed %simpute2/chr%s_chunkall.bim %simpute2/chr%s_chunkall.fam\n" % (resultdir, chr, resultdir, chr, resultdir, chr)]
        combinechrplink.writelines(combinechrplinklist)
    os.system("plink --bfile %simpute2/chr1_chunkall --merge-list %sall_chromosomes.txt --make-bed --out %simpute2/allchr" % (resultdir, inputfile, resultdir))
    # remove SNPs with 3+ alleles, detect which chromosome these SNPs on
    # after getting one plink format file, exclude snps with certainty for best guess <0.9
    # firstly get a list of excluded snps for chromosome
    for chr in range(1, 23):
        maxposition = os.popen("gawk -v chr=%s 'FNR==chr {print}' %smaxposition" % (chr, inputfile))
        maxposition = "%d" % maxposition + 1
        for chunk in range(1, maxposition):
            os.system("gawk '$8 < 0.9 {print $2}' %simpute2/chr%s/cleantotaldata_extractqc.chr%s.phased.chunk%s.impute2_info >> %sexcludesnps.txt" % (resultdir, chr, chr, chunk, inputfile))


def postimputation2():
    # remove SNPs with duplicate positions
    os.system("plink --bfile %simpute2/allchr --noweb --list-duplicate-vars ids-only suppress-first --out %sduplicatesnps_allchr" % (resultdir, inputfile))
    os.system("plink --bfile %simpute2/allchr --noweb --exclude %sduplicatesnps_allchr.dupvar --make-bed --out %simpute2/allchr2" % (resultdir, inputfile, resultdir))
    # exclude snps with certainty for best guess < 0.9
    os.system("plink --bfile %simpute2/allchr2 --exclude %sexcludesnps.txt --make-bed --out %simpute2/cleanchr" % (resultdir, inputfile, resultdir))
    # do the post imputation quality control
    os.system("plink --bfile %simpute2/cleanchr --noweb --geno %s --maf %s --hwe %s --make-bed --out %simpute2/cleanchr_qc" % (resultdir, SNPcallrate, maf, hwe, resultdir))


postimputation()
postimputation2()

