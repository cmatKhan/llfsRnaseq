library(tidyverse)
library(TidyMultiqc)
library(RSQLite)
library(foreach)
library(here)

# see https://github.com/multimeric/TidyMultiqc/issues/6 for instructions
# on correcting

con = dbConnect(RSQLite::SQLite(),
                'llfs_rnaseq_data/llfs_rnaseq_database.sqlite')

batch_df = tbl(con,'batch') %>%
  collect() %>%
  dplyr::rename(batch_id = pk)

sample_df = tbl(con, 'sample') %>%
  collect() %>%
  left_join(batch_df)

sample_df_to_join = sample_df %>%
  select(pk,fastq_id,visit,batch_alias,batch_id) %>%
  dplyr::rename(library_id=pk)

parse_tidymultiqc_plot = function(json_path, plot_id, batch_alias){

  message(sprintf('working on: %s', json_path))

  df = TidyMultiqc::load_multiqc(json_path,
                                 plots = plot_id,
                                 sections = 'plot')

  bind_cols(df[,1], bind_rows(df[[2]])) %>%
    mutate(visit = str_extract(metadata.library_id, '_v.*')) %>%
    mutate(fastq_id = str_remove(metadata.library_id, "_v.*"),
           visit = str_extract(visit, "\\d"),
           batch_alias = batch_alias) %>%
    replace_na(list(visit = '0')) %>%
    mutate(fastq_id = ifelse(batch_alias==20231010&fastq_id=='RNA_pool_B', 'RNA.pool.B', fastq_id)) %>%
    left_join(sample_df_to_join, by = c('fastq_id', 'visit', 'batch_alias')) %>%
    select(-c(fastq_id,visit,batch_alias,batch_id))
}

plots_of_interest = list(
  samtools_idxstats_xy_plot='samtools-idxstats-xy-plot',
  qualimap_genomic_origin = 'qualimap_genomic_origin',
  rsem_assignment_plot = 'rsem_assignment_plot'
)

multiqc_list = as.list(list.files(here('data/multiqc_data_results'),
                          '*multiqc_data.json',
                          recursive = TRUE,
                          full.names = TRUE))

dir_prefix='/home/oguzkhan/code/llfsRnaseq/data/multiqc_data_results/'
dirname_suffix='_multiqc_report_data'
names(multiqc_list) = str_remove(dirname(str_remove(multiqc_list,dir_prefix)),
                                 dirname_suffix)
names(multiqc_list) = str_remove(names(multiqc_list), "_results")

multiqc_list = multiqc_list[names(multiqc_list) %in% c('20231016')]

multiqc_list_df = foreach(
  i=names(multiqc_list)
) %do% {
  df_list = map(plots_of_interest,
                ~parse_tidymultiqc_plot(
                  multiqc_list[[i]], ., i))
}

multiqc_df_agg = tibble(
  batch_alias = names(multiqc_list),
  df_list = multiqc_list_df
)

add_to_db = function(df_list){

  foreach(
    i=names(df_list)
  ) %do% {
    df = df_list[[i]] %>%
      select(-metadata.library_id)

    na_library_id_count = df %>%
      filter(!complete.cases(.)) %>%
      nrow()

    if(na_library_id_count > 0){
      print('here!')
    }

    message(sprintf('total number_samples: %s', nrow(df)))
    message(sprintf('na samples: %s', na_library_id_count))
    #dbAppendTable(con,i,df)
  }

}

# for(i in 1:nrow(multiqc_df_agg)){
#   batch_alias=multiqc_df_agg$batch_alias[i]
#   df_list=multiqc_df_agg$df_list[[i]]
#   message(sprintf('working on batch: %s', batch_alias))
#   add_to_db(df_list)
#
# }

multiqc_general = function(json_path, batch_alias){
  message(sprintf('working on: %s', json_path))

  df = TidyMultiqc::load_multiqc(json_path) %>%
    mutate(visit = str_extract(metadata.library_id, '_v.*')) %>%
    mutate(fastq_id = str_remove(metadata.library_id, "_v.*"),
           visit = str_extract(visit, "\\d"),
           batch_alias = batch_alias) %>%
    replace_na(list(visit = '0')) %>%
    mutate(fastq_id = ifelse(batch_alias==20231016, str_replace_all(fastq_id,"_","\\."), fastq_id)) %>%
    left_join(sample_df_to_join) %>%
    select(-c(fastq_id,visit,batch_alias,batch_id,metadata.library_id))
}

multiqc_general_df_list = map2(multiqc_list, names(multiqc_list), multiqc_general)

# NOTE!!! The multiqc general data is apparently missing the pool sample data,
# weirdly. it is included in the 'plot' data

add_multiqc_general = function(df){
  df_local = df %>%
    filter(!is.na(library_id))

  if(nrow(df) - nrow(df_local)>6){
    stop('nrow is greater than 6!')
  }

  #dbAppendTable(con, 'multiqc_general', df_local)
}

map(multiqc_general_df_list, add_multiqc_general)



