#'
#' set up the QC notebook with the data sets which are used throughout
#'
#' @param dds a deseq data set object
#' @param percent_samples_for_expr_fltr this is used to set a minimum number of
#' samples which have more than a certain number of cpm count. ie
#'   num_samples = floor(ncol(dds)*percent_samples_for_expr_fltr)
#' @param cpm_count_thres the number of cpm required for a given gene to pass
#'   in a given sample. ie expr_fltr =
#'   rowSums(cpm(counts(dds)) > cpm_count_thres ) >= num_samples
#'
#' @importFrom edgeR cpm
#' @importFrom DESeq2 counts vst
#' @importFrom SummarizedExperiment colData
#' @importFrom dplyr as_tibble mutate select left_join all_of
#'
#' @return a list with the various vst data and dds data objects. This is
#'   very large -- need a lot of RAM.
#'
#' @export
batch_effect_qc_setup <- function(dds,
                           percent_samples_for_expr_fltr = .015,
                           cpm_count_thres = 3) {

  # at the time of writing, num_samples comes out to 19
  num_samples <- floor(ncol(dds) * percent_samples_for_expr_fltr)

  expr_fltr <-
    rowSums(edgeR::cpm(DESeq2::counts(dds)) > cpm_count_thres) >= num_samples

  # label a filter failed if it has greater than 8 % intergenic coverage of
  # the sex is suspicious
  sample_fltr <- SummarizedExperiment::colData(dds)$percent_intergenic < 0.08

  dds$sample_status <- ifelse(sample_fltr == TRUE, "qc_pass", "qc_fail")

  vst_list <- list(
    all = DESeq2::vst(
      filter_dds_restimate_sizeFactors(dds,
        gene_fltr = expr_fltr,
        qc_sample_fltr = NULL
      ),
      blind = TRUE
    ),
    passing = DESeq2::vst(
      filter_dds_restimate_sizeFactors(dds,
        gene_fltr = expr_fltr,
        qc_sample_fltr = sample_fltr
      ),
      blind = TRUE
    )
  )

  pca_list <- list(
    all = prcomp(t(assay(vst_list$all))),
    passing = prcomp(t(assay(vst_list$passing)))
  )

  pca_df_list <- list(
    all = pca_list$all$x %>%
      dplyr::as_tibble() %>%
      dplyr::mutate(name = rownames(pca_list$all$x)) %>%
      dplyr::select(name, dplyr::all_of(paste0("PC", seq(1, 10)))) %>%
      dplyr::left_join(
        dplyr::as_tibble(SummarizedExperiment::colData(vst_list$all)),
        by = c("name" = "count_headers")
      ),
    passing = pca_list$passing$x %>%
      dplyr::as_tibble() %>%
      dplyr::mutate(name = rownames(pca_list$passing$x)) %>%
      dplyr::select(name, dplyr::all_of(paste0("PC", seq(1, 10)))) %>%
      left_join(
        dplyr::as_tibble(SummarizedExperiment::colData(vst_list$passing)),
        by = c("name" = "count_headers")
      )
  )

  out <- list(
    vst_list = vst_list,
    dds = dds,
    expr_fltr = expr_fltr,
    sample_fltr = sample_fltr,
    pca_list = pca_list,
    pca_df_list = pca_df_list
  )
}
