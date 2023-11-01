library(tidyverse)
library(here)

con = RSQLite::dbConnect(RSQLite::SQLite(),
                         here('llfs_rnaseq_data/llfs_rnaseq_database.sqlite'))

sample_df = tbl(con,'sample') %>%
  collect() %>%
  dplyr::rename(library_id = pk) %>%
  select(library_id, fastq_id, visit, batch_id)

batch_df = tbl(con,'batch') %>%
  collect() %>%
  dplyr::rename(batch_id = pk)

sample_info_df = sample_df %>%
  left_join(batch_df) %>%
  select(fastq_id, visit, data_dir, library_id, batch_id) %>%
  mutate(fastq_id = as.character(fastq_id))

compile_files = list.files("/mnt/scratch/llfs_rna_dna_compare_test",
                           "compiled_metrics.csv",
                           recursive = TRUE,
                           full.names = TRUE)

compile_files_new = compile_files[7]

names(compile_files_new) = basename(dirname(compile_files_new))

compiled_wgs_compare = map(
  compile_files_new,
  read_csv
) %>%
  bind_rows(.id='data_dir') %>%
  dplyr::rename(fastq_id = rna_sample,
                visit = rna_visit)

compiled_wgs_compare_upload =
  compiled_wgs_compare %>%
  mutate(fastq_id = as.character(fastq_id),
         visit = as.character(visit)) %>%
  dplyr::rename(dna_subject = dna_sample,
                homo_expr_cand = homo_expr_cand_fltr,
                total_variants = overlap_fltr,
                matching_variants = n_match_fltr) %>%
  mutate(match_ratio = matching_variants / total_variants) %>%
  left_join(sample_info_df) %>%
  select(library_id,
         dna_subject,
         chr,
         total_variants,
         matching_variants,
         homo_expr_cand,
         match_ratio)

# dbAppendTable(con, 'wgs_compare', compiled_wgs_compare_upload)


