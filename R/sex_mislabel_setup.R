#' set up the QC notebook with the data sets which are used throughout
#'
#' @param dds_rds_path path to a dds object, either gene or transcript counts
#' @param percent_samples_for_expr_fltr this is used to set a minimum number of
#' samples which have more than a certain number of cpm count. ie
#'   num_samples = floor(ncol(dds)*percent_samples_for_expr_fltr)
#' @param cpm_count_thres the number of cpm required for a given gene to pass
#'   in a given sample. ie expr_fltr =
#'   rowSums(cpm(counts(dds)) > cpm_count_thres ) >= num_samples
#'
#' @return a list which contains the raw, expression filtered and expression
#'   filtered and passing sets
#'
#' @importFrom edgeR cpm
#' @importFrom DESeq2 estimateSizeFactors vst
#' @importFrom SummarizedExperiment colData
#'
#' @export
sex_mislabel_setup = function(dds_rds_path,
                              percent_samples_for_expr_fltr = .015,
                              cpm_count_thres = 3){
  dds = readRDS(dds_rds_path)

  # at the time of writing, num_samples comes out to 19
  num_samples = floor(ncol(dds)*percent_samples_for_expr_fltr)

  # this was used to check that the current filter produces the same results
  # as the original filter on the original set of plates did
  #mid_expression_filter <-
  # rowSums(cpm(counts(dds[,dds$plate %in% #c(3,4,5,6,7,8)])) > 3 ) >= 4 #num_samples

  mid_expression_filter =
    rowSums(edgeR::cpm(counts(dds)) > cpm_count_thres ) >= num_samples

  SummarizedExperiment::colData(dds)$sample_status =
    ifelse(SummarizedExperiment::colData(dds)$percent_intergenic > 8,
           "qc_fail", "qc_pass")

  SummarizedExperiment::colData(dds)$sample_status =
    as.factor(SummarizedExperiment::colData(dds)$sample_status)

  meta = as_tibble(SummarizedExperiment::colData(dds)) %>%
    mutate(name = colnames(dds))


  dds_list = list(
    raw = dds,
    expr = dds[mid_expression_filter],
    expr_passing = dds[mid_expression_filter,
                       SummarizedExperiment::colData(dds)$percent_intergenic < 8]
  )

  dds_list = map(dds_list, DESeq2::estimateSizeFactors)

  map(dds_list, DESeq2::vst)

}
