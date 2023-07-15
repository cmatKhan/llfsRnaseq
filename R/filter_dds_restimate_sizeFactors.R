#' Apply boolean vector filtering on the columns and/or rows and return
#' filtered DDS object with size factors
#'
#' @param dds a DeseqDataSet object
#' @param gene_fltr a boolean vector of length nrow(dds) where TRUE are the
#'   indicies to keep. Optional
#' @param qc_sample_fltr a boolean vector of length ncol(dds) where TRUE are
#'   the indicies to keep. Optional
#'
#' @importFrom DESeq2 estimateSizeFactors
#'
#' @return a filtered DESeqDataSet. Size factors are calculated.
#'
#' @export
filter_dds_restimate_sizeFactors <- function(dds, gene_fltr = NULL,
                                           qc_sample_fltr = NULL) {
  if (!is.null(gene_fltr) & is.null(qc_sample_fltr)) {
    dds <- dds[gene_fltr, ]
  } else if (is.null(gene_fltr) & !is.null(qc_sample_fltr)) {
    dds <- dds[, qc_sample_fltr]
  } else if (!is.null(gene_fltr) & !is.null(qc_sample_fltr)) {
    dds <- dds[gene_fltr, qc_sample_fltr]
  }
  # return dds with fltr and new size factors
  DESeq2::estimateSizeFactors(dds)
}
