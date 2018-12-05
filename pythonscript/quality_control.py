#!/usr/bin/env python

import os
# import argparse
import config
import numpy as np
np.set_printoptions(suppress=True)

rawdatadir = config.get_rawdatadir()
resultdir = config.get_resultdir()
inputfile = config.get_inputfile()
plink = config.get_plink()
rscript = config.get_rscript()
SNPcallrate = config.get_SNPcallrate()
maf = config.get_maf()
hwe = config.get_hwe()
mind = config.get_mind()
LDprune1 = config.get_LDprune1()
LDprune2 = config.get_LDprune2()
LDprune3 = config.get_LDprune3()
pca = config.get_pca()
MINIBD = config.get_MINIBD()


# ==========================quality control
# user input raw data file
rawdatafile = input("The raw plink format data is: ")
rawdatafile = "%s%s" % (rawdatadir, rawdatafile)
print("Please check if this is the correct raw data file you want to use: %s" % rawdatafile)


answer = input("Is this the file you want to use? Please answer yes or no: ")
if answer == "no":
    rawdatafile = input("The raw plink format data is: ")
    rawdatafile = "%s%s" % (rawdatadir, rawdatafile)
else:
    print("Great! This is my plink format raw data file!")


# since in the imputation procedure, shapeit does not allow the duplicate SNPs of the same positions, so remove duplicate SNPs of same position


def matchID():
    os.system("plink --bfile " + str(rawdatafile) + " --noweb --list-duplicate-vars ids-only suppress-first --out " + str(inputfile) + "duplicatesnps")
    os.system("plink --bfile " + str(rawdatafile) + "--noweb --exclude " + str(inputfile) + "duplicatesnps.dupvar" + " --make-bed --out " + str(rawdatadir) + "totaldatanodup")
    # whether ID match
    matchID = input("Does the ID in the genotype data match the ID in the phenotype data? Please answer yes or no: ")
    if matchID == "no":
        os.system("plink --bfile " + str(rawdatadir) + "totaldatanodup" + "--keep " + str(inputfile) + "mylist.txt --noweb --chr 1-22 --make-bed --out " + str(rawdatadir) + "totaldata_extract")
    else:
        os.system("plink --bfile " + str(rawdatadir) + "totaldatanodup" + " --noweb --chr 1-22 --make-bed --out " + str(rawdatadir) + "totaldata_extract")


# firstly, focus on snp level (also include individual missing)
print("Quality Control on SNP level:")


def qc1():
    os.system("chmod u+x plink")
    os.system("./plink --bfile " + str(rawdatadir) + "totaldata_extract --noweb " + "--geno " + str(SNPcallrate) + " --mind " + str(mind) + " --maf " + str(maf) + " --hwe " + str(hwe) + " --make-bed --out " + str(inputfile) + "qcgenomindmafhwe")


# Then, focus on sample level
print("Quality Control on Sample level:")


def qc2():
    os.system("chmod u+x plink")

    # HETEROZYGOSITY
    os.system("plink --bfile " + str(inputfile) + "qcgenomindmafhwe --noweb --het --out " + str(inputfile) + "qcgenomindmafhwe")
    # whether you want to remove samples because of heterozygosity, please answer yes/no
    removesample1 = input("Do you want to exclude samples? Please answer yes or no: ")
    if removesample1 == "yes":
        os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
        os.system("chmod u+x " + str(rscript) + "sampleremove.R") 
        os.system("Rscript " + str(rscript) + "sampleremove.R" + str(inputfile))
        # emove people since HETEROZYGOSITY
        os.system("plink --bfile " + str(inputfile) + "qcgenomindmafhwe" + " --noweb --remove " + str(inputfile) + "removesamplelisthet.txt" + " --make-bed --out " + str(inputfile) + "qcgenomindmafhwehet")
    else:
        os.system("plink --bfile " + str(inputfile) + "qcgenomindmafhwe --noweb --make-bed --out " + str(rawdatadir) + "qcgenomindmafhwehet")

    # LD prune and create a pruned list of SNP IDs for PCA: qcgenomindmafhwehetLD.prune.in
    os.system("plink --bfile " + str(inputfile) + "qcgenomindmafhwehet --noweb --indep-pairwise " + str(LDprune1) + str(LDprune2) + str(LDprune3) + " --out " + str(inputfile) + "qcgenomindmafhwehetLD")
    # check IBD and create a list of subjects to remove due to relatedness
    os.system("plink --bfile " + str(inputfile) + " --noweb --extract " + str(inputfile) + "qcgenomindmafhwehetLD.prune.in --genome --min " + str(MINIBD) + " --out " + str(inputfile) + "qcgenomindmafhwehetIBD")
    removesample2 = input("Do you want to exclude samples? Please answer yes or no: ")
    if removesample2 == "yes":
        # remove subjects, I set removing one of pair with PI_HAT>0.2 here, you can change the threshold
        os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
        os.system("chmod u+x " + str(rscript) + "sampleremove2.R")
        os.system("Rscript " + str(rscript) + "sampleremove2.R" + str(inputfile))
        os.system("plink --bfile " + str(inputfile) + "qcgenomindmafhwehet" + " --noweb --remove " + str(inputfile) + "removesamplelist2.txt" + " --make-bed --out " + str(inputfile) + "totaldata_extractqc")
    else:
        os.system("plink --bfile " + str(input) + "qcgenomindmafhwehet --noweb --make-bed --out " + str(input) + "totaldata_extractqc")


def pca():
    # LD pruning at first
    os.system("plink --bfile " + str(inputfile) + "totaldata_extractqc" + " --noweb --indep-pairwise " + str(LDprune1) + str(LDprune2) + str(LDprune3) + " --out " + str(inputfile) + "totaldata_extractqcLD")
    os.system("plink --bfile " + str(inputfile) + "totaldata_extractqc" + " extract " + str(inputfile) + "totaldata_extractqcLD.prune.in --pca " + str(pca) + "header --noweb --out " + str(input) + "totaldata_extractqcpca")
    # covariates
    # os.system("module load GCC/5.4.0-2.26  OpenMPI/1.10.3 R")
    # pca #number of principle components output in plink
    # s.system("Rscript " + str(rscript) + "cov.R" + str(input) + str(resultdir))


matchID()
qc1()
qc2()
pca()










