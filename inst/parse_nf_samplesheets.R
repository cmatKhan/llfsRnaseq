library(tidyverse)
library(here)

# sample_sheets = list.files(here("data/demux_samplesheet/sample_sheets/completed"),
#                               full.names = TRUE)

sample_sheets = c('/mnt/scratch/llfs_rna_pipeline/sample_sheets/20231016.csv')

names(sample_sheets) = str_remove(basename(sample_sheets), ".csv")
#sample_sheets = sample_sheets[startsWith(names(sample_sheets), '2023')]

sample_sheets = map(sample_sheets, read_csv)

manipulateSampleSheets = function(df, batch){

  df %>%
    mutate(fastq_1 = basename(fastq_1),
           fastq_2 = basename(fastq_2)) %>%
    mutate(batch = batch) %>%
    mutate(sample = ifelse(str_detect(sample, "pool"),
                           str_replace_all(sample, "_", "."),
                           sample)) %>%
    separate(sample, sep = "_", extra="merge", into = c('id', 'visit')) %>%
    mutate(id = ifelse(batch %in% c("20210312", "20210319") &
                         str_detect(id, "pool"),
                       paste(id, visit, sep="_"),
                       id)) %>%
    mutate(visit = ifelse(str_detect(id, "pool"), NA, visit))

}

sample_sheet_mutate = map(names(sample_sheets),
                              ~manipulateSampleSheets(sample_sheets[[.]], .))

names(sample_sheet_mutate) = names(sample_sheets)

map(names(sample_sheet_mutate),
    ~write_csv(sample_sheet_mutate[[.]],
               file.path(here("data/samplesheets"),
                         paste0(.,".csv"))))
