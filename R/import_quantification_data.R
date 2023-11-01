# library(tximport)
# library(vroom)
#
# process_tximport <- function(quant_df_path, TX_QUANTS = TRUE, tx2gene = NULL) {
#
#   if(!TX_QUANTS){
#     if(is.null(tx2gene)){
#       stop('tx2gene cannot be null if TX_QUANTS is TRUE')
#     } else if(!file.exists(tx2gene)){
#       stop('tx2gene file does not exist')
#     }
#   }
#
#   if(!file.exists(quant_df_path)){
#     stop('quant_df_path does not exist')
#   }
#
#   quant_df <- vroom::vroom(quant_df_path)
#
#   missing_cols <- setdiff(c('isoform_file', 'library_id'),
#                           colnames(quant_df))
#   if(length(missing_cols) > 0){
#     stop(paste("`", paste(missing_cols, collapse="`, `"),
#                "` must be columns in `quant_df`"))
#   }
#
#   isoform_list <- setNames(quant_df$isoform_file,
#                            paste0('library_', quant_df$library_id))
#
#   if(TX_QUANTS){
#     txi_isoform <- tximport(files = isoform_list,
#                             type = 'rsem',
#                             txIn = TRUE,
#                             txOut = TRUE,
#                             importer = vroom)
#     # Save the result
#     saveRDS(txi_isoform, file.path("txi_isoform.rds"))
#   } else {
#     tx2gene <- vroom::vroom(tx2gene)
#     txi_gene <- tximport(files = isoform_list,
#                          type = 'rsem',
#                          txIn = TRUE,
#                          txOut = FALSE,
#                          tx2gene = tx2gene,
#                          importer = vroom)
#     # Save the result
#     saveRDS(txi_gene, file.path("txi_gene.rds"))
#   }
#
#   return(invisible(NULL))  # Return nothing, to avoid cluttering output
# }

# # Define your parameters
# params_list <- list(quant_df_path = "isoforms_df_20231009.csv",
#                     TX_QUANTS = FALSE,
#                     tx2gene="gencode38_tx2gene_20210919.csv")
#
# # Specify required packages
# required_pkgs <- c("tximport", "vroom")
#
# # Set your SLURM options
# # --mem-per-cpu=10G -N 1 -n 5
# slurm_opts <- list(time = '00:60:00',
#                    nodes = 1,
#                    mem='80G')
#
#
# rslurm::slurm_call(
#   process_tximport,
#   params = params_list,
#   jobname='tximport',
#   pkgs=required_pkgs,
#   slurm_options = slurm_opts,
#   submit = FALSE
# )
