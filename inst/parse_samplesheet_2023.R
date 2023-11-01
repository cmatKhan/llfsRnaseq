library(here)
library(tidyverse)

#' Parse a samplesheet into the correct format for the DB
#'
#' @desription This is intended to further parse the samplesheet in this project
#'   directories `samplesheet` directory. These samplesheets have been themselves
#'   parsed by `parse_nf_samplesheet.R` from the nf-core/rnaseq input
#'   samplesheet
#'   note that some info is re-extracted since some of my original nf-core
#'   samplesheets included info, like flow_cell_id, which later ones do not.
#'   These columns aren't used in the pipeline and so were dropped in 2023 in
#'   the nf input. It is worth recording in the DB, though.
parse_samplesheet = function(samplesheet_path){
  tmp_df = read_csv(samplesheet_path) %>%
    mutate(type = ifelse(str_detect(id, regex("pool", ignore_case=TRUE)),
                         "pool",
                         "experiment")) %>%
    mutate(lane = str_extract(fastq_1, 'L0\\d+'),
           flow_cell_id = str_extract(fastq_1, 'H.*?(?=_)')) %>%
    mutate(id = ifelse(id == 'pool', str_extract(fastq_1, '.*(?=\\.H)'), id)) %>%
    arrange(id) %>%
    mutate(batch = as.character(batch)) %>%
    replace_na(list(visit='0')) %>%
    mutate(visit = str_extract(visit, '\\d')) %>%
    select(id,
           visit,
           fastq_1,
           fastq_2,
           strandedness,
           index_sequence,
           flow_cell_id,
           lane,
           batch,
           type)

  if(tmp_df %>% filter(!complete.cases(.)) %>% nrow() > 0){
    stop(sprintf('the following samplesheet had parse errors: %s',
                 samplesheet_path))
  }
  tmp_df
}

con = RSQLite::dbConnect(RSQLite::SQLite(),
                here('llfs_rnaseq_data/llfs_rnaseq_database.sqlite'))

batch_df = tbl(con,'batch') %>%
  collect() %>%
  dplyr::rename(batch_id = pk)

samplesheets = list.files('data/samplesheets',
                          recursive = TRUE,
                          full.names = TRUE)
names(samplesheets) = str_remove(basename(samplesheets), '.csv')

samplesheets = samplesheets[names(samplesheets) %in% c('20231016')]

samplesheet_df_list = map(samplesheets, ~{parse_samplesheet(.) %>%
                            left_join(select(batch_df,
                                             batch_id,data_dir),
                                      c('batch' = 'data_dir'))})

sample_df_upload = map(samplesheet_df_list,
                            ~select(.,id,visit, batch_id) %>%
    dplyr::rename(fastq_id = id) %>%
    mutate(mislabelled = FALSE,
           suspicious_sex = FALSE,
           notes='none')) %>%
  bind_rows()

#RSQLite::dbAppendTable(con, 'sample', sample_df_upload)

sample_df = tbl(con,'sample') %>%
  collect() %>%
  dplyr::rename(library_id = pk) %>%
  select(library_id, fastq_id, visit, batch_id)

fastq_df_upload = map(samplesheet_df_list,
                       ~select(.,id,visit, batch_id, fastq_1, fastq_2, strandedness, index_sequence, flow_cell_id, lane) %>%
                         dplyr::rename(fastq_id = id) %>%
                         mutate(mislabelled = FALSE,
                                suspicious_sex = FALSE,
                                notes='none')) %>%
  bind_rows() %>%
  left_join(sample_df) %>%
  select(library_id,fastq_1,fastq_2,strandedness,index_sequence, flow_cell_id, lane) %>%
  mutate(notes = 'none')

#RSQLite::dbAppendTable(con, 'fastq', fastq_df_upload)
