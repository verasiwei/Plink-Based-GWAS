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
annotation = config.get_annotation()
SNPcallrate = config.get_SNPcallrate()
maf = config.get_maf()
hwe = config.get_hwe()

os.system("module load GCC/6.4.0-2.28  OpenMPI/2.1.1 R/3.4.3")
os.system("module load GCC/6.4.0-2.28 Python/3.6.3")
os.system("R --version")
os.system("python --version")


def postimputation():
    # combine all chunks in each chromosome
    os.system("Rscript %spostimputation.R %s %s %s %s %s" % (rscript, inputfile, resultdir, impute2, reference, refdir))
    account = input("Please input the account: ")
    mail = input("Please input the mail: ")
    cpus = input("Please input cpus: ")
    time = input("Please input time: ")
    memory = input("Please input memory: ")
    for chr in range(1, 23):
        print(chr)
        phasedfile = "shapeitcleantotaldata_extractqc.chr%s.phased" % (chr)
        dir = str(inputfile)
        filename = "combinechr_TASK_%s.slurm" % chr
        filename = "%s%s" % (dir, filename)
        combinechr = open(filename, "w")
        combinechr.write("#!/bin/bash\n")
        combinechrlist1 = ["#SBATCH --account=%s\n" % (account), "#SBATCH --mail-user=%s\n" % mail, "#SBATCH --mail-type=ALL\n", "#SBATCH --ntasks=1\n", "#SBATCH --cpus-per-task=%s\n" % cpus, "#SBATCH --time=%s\n" % time]
        combinechrlist2 = ["#SBATCH --mem=%s\n" % memory, "#SBATCH --output=imputejob_%s.out\n" % chr]
        combinechr.writelines(combinechrlist1)
        combinechr.writelines(combinechrlist2)
        maxposition = open("%smaxposition" % (inputfile))
        maxposition_chr = maxposition.readlines()[chr-1]
        maxposition_chr = maxposition_chr.strip("\n")
        combinechrlist3 = ["for chunk in `seq 1 %s`;do\n" % maxposition_chr]
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
        chrplinklist3 = [str(plink), " --data -gen %simpute2/chr%s_chunkall.gen " % (resultdir, chr),  "--sample %sshapeit/shapeitcleantotaldata_extractqc.chr%s.phased.sample " % (resultdir, chr), "--hard-call-threshold 0.2 --oxford-single-chr %s " % (chr)]
        chrplinklist4 = ["--make-bed --out %simpute2/chr%s_chunkall" % (resultdir, chr)]
        chrplink.writelines(chrplinklist3)
        chrplink.writelines(chrplinklist4)
        chrplink.close()

    # after converting into plink format, merge all chromosomes together
    dir3 = str(inputfile)
    filename3 = "combinechrplink.txt"
    filename3 = "%s%s" % (dir3, filename3)
    combinechrplink = open(filename3, "a")
    for chr in range(2, 23):
        combinechrplinklist = ["%simpute2/chr%s_chunkall.bed %simpute2/chr%s_chunkall.bim %simpute2/chr%s_chunkall.fam\n" % (resultdir, chr, resultdir, chr, resultdir, chr)]
        combinechrplink.writelines(combinechrplinklist)
    os.system(str(plink) + " --bfile %simpute2/chr1_chunkall --merge-list %scombinechrplink.txt --make-bed --out %simpute2/allchr" % (resultdir, inputfile, resultdir))

    # remove SNPs with 3+ alleles, detect which chromosome these SNPs on
    os.system("%s --bfile %simpute2/chr17_chunkall --exclude %simpute2/allchr-merge.missnp --make-bed --out %simpute2/chr17_chunkall" % (plink, resultdir, inputfile, resultdir))
    os.system("%s --bfile %simpute2/chr1_chunkall --merge-list %scombinechrplink.txt --make-bed --out %simpute2/allchr" % (plink, resultdir, inputfile, resultdir))


def postimputation2():
    # remove SNPs with duplicate positions
    os.system("%s --bfile %simpute2/allchr --noweb --list-duplicate-vars ids-only suppress-first --out %sduplicatesnps_allchr" % (plink, resultdir, inputfile))
    os.system("%s --bfile %simpute2/allchr --noweb --exclude %sduplicatesnps_allchr.dupvar --make-bed --out %simpute2/allchr2" % (plink, resultdir, inputfile, resultdir))
    # exclude snps with certainty for best guess < 0.9
    # after getting one plink format file, exclude snps with certainty for best guess <0.9
    # firstly get a list of excluded snps for chromosome
    for chr in range(1, 23):
        maxposition = open("%smaxposition" % (inputfile))
        maxposition_chr = maxposition.readlines()[chr-1]
        maxposition_chr = maxposition_chr.strip("\n")
        for chunk in range(1, maxposition_chr):
            os.system("gawk '$8 < 0.9 {print $2}' %simpute2/chr%s/cleantotaldata_extractqc.chr%s.phased.chunk%s.impute2_info >> %sexcludesnps.txt" % (resultdir, chr, chr, chunk, inputfile))
    os.system("%s --bfile %simpute2/allchr2 --exclude %sexcludesnps.txt --make-bed --out %simpute2/cleanchr" % (plink, resultdir, inputfile, resultdir))
    # do the post imputation quality control
    os.system("%s --bfile %simpute2/cleanchr --noweb --geno %s --maf %s --hwe %s --make-bed --out %simpute2/cleanchr_qc" % (plink, resultdir, SNPcallrate, maf, hwe, resultdir))


def unilog():
    # you should change the column of phenotype in the .fam file and provide a file of "mycovpca" which includes the adjusted covariates like age, sex and PCs by yourself
    # do the logistic regression
    os.system("%s --bfile %simpute2/cleanchr_qc --noweb --logistic hide-covar --ci 0.95 --covar %smycovpca.txt --out %sunilogassoc" % (plink, resultdir, inputfile, resultdir))
    # extract significant snps from the results
    os.system("gawk '$12!=\"" + "NA" + "\" " + "&& $12<=0.000005 || NR==1 {print}' %sunilogassoc.assoc.logistic > %sunilog_covs" % (resultdir, resultdir))
    # manhattan plot and significant snps csv file
    os.system("Rscript %sunilogassoc.R %s" % (rscript, resultdir))


def prs():
    # this is used to generate prs score
    # R script is used to get the log of odds ratio for each SNP
    os.system("Rscript %sprs.R %sunilog_covs.csv" % (rscript, resultdir))
    # this is used to generate prs score file
    os.system("%s --bfile %simpute2/cleanchr_qc --noweb --score %ssnpprs_logOR.raw --out %ssnpprs_logOR" % (plink, resultdir, inputfile, resultdir))


def annotation():
    # unzip the annovar tool that downloaded in the folder annotation
    os.system("tar xzvf %sannovar.latest.tar.gz --directory %s" % (annotation, annotation))
    # download the reference database
    os.system("perl %sannovar/annotate_variation.pl -buildver hg19 -downdb -webfrom annovar refGene %s" % (annotation, annotation))
    annotationtype = input("Please input your type of annotation. Please answer vcf or avinput: ")
    if annotationtype == "vcf":
        # first choice, annotation in one step using vcf file
        # prepare the data that the format satisfies the ANNOVAR requirements
        # extract significant snps from the results
        os.system("gawk '$2!=\"" + "SNP" + "\" " + "{print $2}' %sunilog_covs > %smysnps.txt" % (resultdir, annotation))
        os.system("%s --bfile %simpute2/cleanchr_qc --extract %smysnps.txt --make-bed --out %ssigsnps" % (plink, resultdir, annotation, annotation))
        # notice the major allele in plink format file is not always the reference allele, we need to change the column of major and minor allele colomuns before converting to vcf
        os.system("Rscript %sannotation.R %ssigsnps.bim")
        # convert to vcf format
        os.system("%s --bfile %ssigsnps --recode vcf --out %ssigsnpsvcf" % (plink, annotation, annotation))
        # annotation in one step using vcf file
        os.system("%sannovar/table_annovar.pl %ssigsnpsvcf.vcf %s -buildver hg19 -out %ssigannotation -remove -protocol refGene -operation g -nastring . -vcfinput")
    else:
        # second choice, annotation in one step using .avinput file
        os.system("Rscript %sannotation.R %ssigsnps.bim")
        os.system("perl %sannovar/table_annovar.pl %ssigsnps.avinput %s -buildver hg19 -out %ssigannotation -remove -protocol refGene -operation gx -nastring . -csvout -polish -xref %sannovar/example/gene_xref.txt" % (annotation, annotation, annotation, annotation, annotation))


# postimputation()
# for chr in range(1, 23):
#        os.system("sbatch " + str(inputfile) + "combinechr_TASK_%s.slurm" % chr)
# for chr in range(1, 23):
#        os.system("sbatch " + str(inputfile) + "chrplink_TASK_%s.slurm" % chr)
# postimputation2()
# unilog()
# prs()
# annotation()




