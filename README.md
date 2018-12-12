# GWAS Pipeline
This is the standard GWAS pipeline. Please notice that your GWAS sites is in buid37 coordinate system, if it is not the case, you can use the UCSC liftOver tool to perform the conversion to build37 system. Please also notice it is prefer that your GWAS dataset is forward strand, otherwise the SNPs which found in both reference panel and target panel that have an incompatible alleles types will be removed during the procedure of strand alignment check in this pipeline. 
## Requirement: 
please download tools to the folder "software": 
* plink (please download the latest plink1.9, otherwise you will waste a lot of time!!!)
* shapeit
* impute2

other pre-requirements:
* a cluster or you need a server with many cores
* genotyped data(plink format, transform to bed/bim/fam before running the pipeline if your genotyped data is ped/map)
* enough storage since very large files will be created during imputation procedure
* R 3.4.3;gawk;python3.6.3

## Procedures


* 1.**git clone https://github.com/verasiwei/GWAS_python**
* 2.users to edit the directory in config.py
* 3.On your terminal, cd to the folder "pythonscript"

  **python quality_control.py**

Notice: 

1.If IDs are not matched in genotype and phenotype data,you should provide "mylist.txt" file.

2.Answer each question on the screen during the process, do not need to include quotation markers

* 4.On your terminal, cd to the folder "pythonscript" 
  
  **python imputation.py**

Notice: 

1.You can choose whether to use 1000 Genome Phase1 or Phase3 as the reference panel 
during this process, just answer the "Phase1" or "Phase3" when the question promted on the screen

2.It may takes a long time if you want to impute the whole chromosomes, all chromosomes are separated into more than 500 chunks totally with each chunk 5MB according to the physical position, also you need to have enough storage to save the outputs!!!

* 5.On your terminal, cd to the folder "pythonscript", a manhattan plot and a qqplot shown like the below will be created. 

  **python post_imputation.py**

Notice:

1.You should change the column of phenotype in the .fam file and provide a file of "mycovpca.txt" which includes the adjusted covariates like age, sex and PCs by yourself. 

![Alt text](https://github.com/verasiwei/GWAS_python/blob/master/result/manhattan_jak2_4covs.png)
![Alt text](https://github.com/verasiwei/GWAS_python/blob/master/result/qqplot_jak2.png)










