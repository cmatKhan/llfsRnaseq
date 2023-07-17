# llfsRnaseq 1.0.0

* Inaugural release of llfsRnaseq, the code which is used to process the LLFS 
fastq files to released counts data.
    - The major, major change compared to how I did this before is the creation 
    of the llfs_rnaseq_metadata.sqlite database. All of the re-labelling that I
    used to do is now stored and performed by the database. Please see the 
    database documentation 
    [here](https://cmatkhan.github.io/llfsRnaseq/articles/database-overview.html.
