#!/usr/bin/env python

import os
# import argparse
import config
import numpy as np
np.set_printoptions(suppress=True)

rawdatadir = config.get_rawdatadir()
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
    # incorporate shell script to do the quality control
    # firstly, focus on snp level (also include individual missing)
    print("Quality Control on SNP level:")


def qc1():
    os.system("chmod u+x plink")
    os.system("./plink --bfile " + str(rawdatafile) + " --noweb " + "--geno " + str(SNPcallrate) + " --mind " + str(mind) + " --maf " + str(maf) + " --hwe " + str(hwe) + " --make-bed --out " + str(inputfile) + "qcgenomindmafhwe")


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


qc1()
qc2()










