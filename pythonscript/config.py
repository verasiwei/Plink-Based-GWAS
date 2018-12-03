#!/usr/bin/env python
# ==========================to be edited by user
# directory and thresholds


class global_var:
    # directory
    rawdatadir = ""
    resultdir = ""
    inputfile = ""
    output = ""
    rscript = ""
    reference = ""
    refdir = ""
    shellscript = ""
    shapeit = ""
    plink = ""
    impute2 = ""
    # parameters
    SNPcallrate = 0.02
    maf = 0.01
    hwe = '%f' % 0.000001
    mind = 0.05
    LDprune1 = 50   # LDprune1 is the window size in SNPs
    LDprune2 = 5   # LDprune2 is the number of SNPs to shift the window at each step
    LDprune3 = 0.2    # LDprune3 is the multiple correlation coefficient
    pca = 10  # number of parameters to output
    MINIBD = 0.05  # to reduce the file size, output to file.genome pairs where PI_HAT is greater than MINIBD


def set_rawdatadir(rawdatadir):
    global_var.rawdatadir = rawdatadir


def get_rawdatadir():
    return global_var.rawdatadir


def set_resultdir(resultdir):
    global_var.resultdir = resultdir


def get_resultdir():
    return global_var.resultdir


def set_inputfile(inputfile):
    global_var.inputfile = inputfile


def get_inputfile():
    return global_var.inputfile


def set_output(output):
    global_var.output = output


def get_output():
    return global_var.output


def set_rscript(rscript):
    global_var.rscript = rscript


def get_rscript():
    return global_var.rscript


def set_reference(reference):
    global_var.reference = reference


def get_reference():
    return global_var.reference


def set_refdir(refdir):
    global_var.refdir = refdir


def get_refdir():
    return global_var.refdir


def set_shellscript(shellscript):
    global_var.shellscript = shellscript


def get_shellscript():
    return global_var.shellscript


def set_shapeit(shapeit):
    global_var.shapeit = shapeit


def get_shapeit():
    return global_var.shapeit


def set_impute2(impute2):
    global_var.impute2 = impute2


def get_impute2():
    return global_var.impute2


def set_plink(plink):
    global_var.plink = plink


def get_plink():
    return global_var.plink


def set_SNPcallrate(SNPcallrate):
    global_var.SNPcallrate = SNPcallrate


def get_SNPcallrate():
    return global_var.SNPcallrate


def set_maf(maf):
    global_var.maf = maf


def get_maf():
    return global_var.maf


def set_hwe(hwe):
    global_var.hwe = hwe


def get_hwe():
    return global_var.hwe


def set_mind(mind):
    global_var.mind = mind


def get_mind():
    return global_var.mind


def set_LDprune1(LDprune1):
    global_var.LDprune1 = LDprune1


def get_LDprune1():
    return global_var.LDprune1


def set_LDprune2(LDprune2):
    global_var.LDprune2 = LDprune2


def get_LDprune2():
    return global_var.LDprune2


def set_LDprune3(LDprune3):
    global_var.LDprune3 = LDprune3


def get_LDprune3():
    return global_var.LDprune3


def set_pca(pca):
    global_var.pca = pca


def get_pca():
    return global_var.pca


def set_MINIBD(MINIBD):
    global_var.MINIBD = MINIBD


def get_MINIBD():
    return global_var.MINIBD