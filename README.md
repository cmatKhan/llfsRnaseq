[![R-CMD-check](https://github.com/cmatKhan/llfsRnaseq/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/cmatKhan/llfsRnaseq/actions/workflows/R-CMD-check.yaml)

# Introduction

This repository documents how the Long Life Family Study RNA sequencing data 
is processed.  

There is no data stored in this repository. If you feel like you need the 
data, and don't already have access, then you should talk to your lab and 
ask how to get access.  Please see the [Getting Started](https://cmatkhan.github.io/llfsRnaseq/articles/llfsRnaseq.html) section of the 
documentation for an explanation of how this data is tracked in relation to the 
versioned software releases.

## Wait -- this is different

I used to distribute this data as a tarred, zipped R project. There was a 
subdirectory called `data` which had both the `DeseqDataSet` gene and 
transcript objects 
(see [Why Use DESeqDataSet Objects](#why-use-deseqdataset-objects)) and 
`csv` files.  

That `data` directory is now what will be distributed through **box** and on 
the `dsg` cluster. This repository will store the versioned code which 
corresponds to a given data release, and the documentation.  

# Installation and Usage

You can use this in a couple different ways, but the starting point for all 
of those ways is the [served documentation](https://cmatkhan.github.io/LLFS_RNAseq_dataprocessing/). 
I'd start with [**Getting Started**](https://cmatkhan.github.io/llfsRnaseq/articles/llfsRnaseq.html), myself.

# Why Use DESeqDataSetObjects

Even if you aren't going to do differential expression analysis using DESeq2,
it is useful to use the DESeqDataSet object. DESeqDataSet objects inherit from
the basebioconductor object 
[SummarizedExperiment](https://www.bioconductor.org/packages/devel/bioc/vignettes/SummarizedExperiment/inst/doc/SummarizedExperiment.html).
 And, `SummarizedExperiment` is a core component of Bioconductor's 
 [Scalable Genomics Toolset](https://pubmed.ncbi.nlm.nih.gov/28018047/).  
 
The LLFS `dds` object has the GRCh38 annotations stored in the `rowRanges`. The
metadata rows also are forced to correspond to the count columns. So, you could
choose a single gene in a single sample like this:

```R
dds['ENSG....', dds$library_id==2]
```
 
 # Some final notes
 
 if the `R CMD Check` CI is passing, that means that this package successfully 
 builds on the latest Windows, latest Mac, and the two most current Ubuntu OS's. 
 If you are using one of these operating systems, then this will install on 
 your system. If you are using an older, or different, OS, then there are no 
 promises. Go ahead and open a bug report if this is the case, and I will create 
 a Docker and/or singularity container for you.
