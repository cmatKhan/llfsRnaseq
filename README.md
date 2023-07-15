[![DOI](https://zenodo.org/badge/665251410.svg)](https://zenodo.org/badge/latestdoi/665251410)
[![R-CMD-check](https://github.com/cmatKhan/llfsRnaseq/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cmatKhan/llfsRnaseq/actions/workflows/R-CMD-check.yaml)

# Introduction

This repository documents how the Long Life Family Study RNA sequencing data 
is processed.  

There is no data stored in this repository. If you feel like you need the 
data, and don't already have access, then you should talk to your lab and 
ask how to get access.  

## Wait -- this is different

I used to distribute this data as a tarred, zipped R project. There was a 
subdirectory called `data` which had both the `DeseqDataSet` gene and 
transcript objects. These are useful because they store the gencode 
v38 annotations in the `rowRanges` slot, the sample metadata in the 
`colData` slot, and of course the count data in the `countData` slot. Since 
the `DeseqDataSet` object inherits from the Bioconductor class 
`SummarizedExperiment`, there are both convenient methods specific to `DESeq2`, 
but also the wider bioconductor environment.  

But there were, and are, also `csv` files.  

That `data` directory is now what will be distributed through **box**. This 
repository will store the code and documentation.  

# Installation and Usage

You can use this in a couple different ways, but the starting point for all 
of those ways is the [served documentation](https://cmatkhan.github.io/LLFS_RNAseq_dataprocessing/). 
I'd start with **Getting Started**, myself.
