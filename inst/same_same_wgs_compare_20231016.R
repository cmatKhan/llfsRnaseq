library(tidyverse)
library(RSQLite)
library(here)

con = dbConnect(RSQLite::SQLite(),
                here('llfs_rnaseq_data/llfs_rnaseq_database.sqlite'))

# this is just a single column list of wgs subject identifiers which are in
# the freeze5 wgs
wgs_subject_vector = read_csv('/mnt/scratch/llfs_rna_dna_compare_test/lookups/wgs_dna_subject_ids.txt',
                              col_names=FALSE)$X1

sample_tbl = tbl(con,'sample') %>%
  collect() %>%
  dplyr::rename(library_id='pk')

corrected_sample_tbl = tbl(con,'corrected_sample') %>%
  collect()

batch_tbl = tbl(con,'batch') %>%
  collect()

whatdatall_tbl = tbl(con,'whatdatall') %>%
  collect()

wgs_compare_tbl = tbl(con,'wgs_compare') %>%
  collect()

wgs_compare_tbl_batch =
  wgs_compare_tbl %>%
  left_join(sample_tbl)

rna_gds_tbl = tbl(con,'rna_gds') %>%
  collect()

sample_in_wgs = sample_tbl %>%
  mutate(library_id = as.character(library_id)) %>%
  dplyr::rename(sample_notes=notes) %>%
  left_join(corrected_sample_tbl %>% select(-pk)) %>%
  filter(is.na(reason)|reason !='phantom',
         str_detect(fastq_id, regex('pool', ignore_case=TRUE),
                    negate=TRUE)) %>%
  left_join(whatdatall_tbl %>%
              mutate(id=as.character(id)) %>%
              select(-c(pk,notes)),
            by = c('fastq_id' = 'id'))

sample_in_wgs_id_typos = sample_in_wgs %>%
  filter(is.na(subject)) %>%
  select(-any_of(colnames(whatdatall_tbl))) %>%
  left_join(whatdatall_tbl %>%
              mutate(id=as.character(id)),
            by = c('whatdatall_id' = 'id')) %>%
  select(library_id, subject,fastq_id,visit)

wgs_same_same_compare = sample_in_wgs %>%
  select(library_id,subject,fastq_id,visit) %>%
  filter(!is.na(subject)) %>%
  bind_rows(sample_in_wgs_id_typos) %>%
  filter(subject %in% wgs_subject_vector) %>%
  filter(!library_id %in% wgs_compare_tbl$library_id) %>%
  left_join(rna_gds_tbl %>%
              mutate(library_id=as.character(library_id)) %>%
              select(-pk))

# note! there are 11 samples that do not have gds files -- must
# check this
wgs_same_same_compare_ready = wgs_same_same_compare %>%
  filter(!is.na(gds)) %>%
  left_join(select(sample_tbl,library_id,batch_id) %>%
              mutate(library_id=as.character(library_id))) %>%
  left_join(select(batch_tbl,pk,data_dir), by = c('batch_id'='pk')) %>%
  mutate(rna_gds_identifier=ifelse(data_dir==20231009,fastq_id,subject),
         dna_subject=subject,
         chr=21,
         rna_gds = file.path('/scratch/mblab/chasem/llfs_rna_dna_compare_test/data',
                             data_dir,
                             basename(gds)),
         dna_gds='/ref/mblab/data/llfs/agds/LLFS.WGS.freeze5.chr21.gds')

s3_pull_gds_df = wgs_same_same_compare_ready %>%
  select(gds,data_dir) %>%
  mutate(data_dir=file.path('/scratch/mblab/chasem/llfs_rna_dna_compare_test/data',
                            data_dir))
# %>%
#   write_tsv('/mnt/scratch/llfs_rna_dna_compare_test/lookups/same_same_gds_lookup_20231016.txt',
#             col_names = FALSE)

wgs_same_same_compare_ready_lookup = wgs_same_same_compare_ready %>%
  mutate(output_dir = file.path('/scratch/mblab/chasem/llfs_rna_dna_compare_test/same_same_20231016',
                                data_dir)) %>%
  select(rna_gds_identifier,
         visit,
         dna_subject,
         rna_gds,
         chr,
         dna_gds,
         output_dir)
# %>%
#   write_tsv('/mnt/scratch/llfs_rna_dna_compare_test/samplesheets/same_same_gds_20231016.txt',
#             col_names = FALSE)

wgs_same_same_compare_ready_lookup_library_id = wgs_same_same_compare_ready %>%
  mutate(output_dir = file.path('/scratch/mblab/chasem/llfs_rna_dna_compare_test/same_same_20231016',
                                data_dir)) %>%
  select(library_id,
         data_dir,
         rna_gds_identifier,
         visit,
         dna_subject,
         rna_gds,
         chr,
         dna_gds,
         output_dir)
# %>%
#   write_csv('data/wgs_same_same_compare_ready_lookup_library_id_20231016.csv')

all_by_all_20231017_lookup_library_id = all_by_all_20231017_df %>%
  filter(!library_id %in% percent_intergenic_greater_8_library_ids) %>%
  select(-pk) %>%
  mutate(library_id=as.character(library_id)) %>%
  left_join(select(wgs_same_same_compare_ready_lookup_library_id,
                   library_id,rna_gds_identifier,rna_gds)) %>%
  left_join(sample_tbl %>%
              select(pk,fastq_id,visit,batch_id) %>%
              mutate(pk=as.character(pk)),
            by=c('library_id'='pk')) %>%
  mutate(rna_gds_identifier=ifelse(is.na(rna_gds_identifier),
                                   fastq_id, rna_gds_identifier)) %>%
  select(-fastq_id) %>%
  left_join(rna_gds_tbl %>%
              select(-pk) %>%
              mutate(library_id=as.character(library_id)) %>%
              dplyr::rename(gds_tmp=gds)) %>%
  mutate(rna_gds=ifelse(is.na(rna_gds), gds_tmp, rna_gds),
         output_dir=file.path('/scratch/mblab/chasem/llfs_rna_dna_compare_test/all_by_all_20231017',
                              paste0('batch_',batch_id))) %>%
  select(library_id,rna_gds_identifier,visit,rna_gds,output_dir)

  # write_csv(all_by_all_20231017_lookup_library_id,
  #           here('data/all_by_all_20231017_lookup_library_id.csv'))

# used this, along with edit() to create a look up to download the remaining 12
# s3 gds files and then replace the paths
# pull_from_s3= all_by_all_20231017_lookup...

all_by_all_20231017_lookup = all_by_all_20231017_lookup_library_id %>%
  select(-library_id) %>%
  left_join(to_pull_df %>%
              mutate(rna_gds_tmp = file.path(data_dir,basename(rna_gds))), by='rna_gds') %>%
  mutate(rna_gds = ifelse(str_detect(rna_gds,'^s3'), rna_gds_tmp,rna_gds)) %>%
  select(-rna_gds_tmp,-data_dir)

# all_by_all_20231017_lookup %>% write_tsv('/mnt/scratch/llfs_rna_dna_compare_test/samplesheets/all_by_all_20231017.txt',
#                                          col_names = FALSE)
