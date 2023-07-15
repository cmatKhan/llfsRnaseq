#'
#' Project counts, presumably with some effect removed, onto different
#' PCs
#'
#' @param dds a DESeqDataSet object
#' @param effect_removed_counts A "count" matrix where some effect
#'   (coefficient) has been removed
#'
#' @importFrom SummarizedExperiment assays
#' @importFrom DESeq2 normTransform
#' @importFrom stats prcomp
#'
#' @return the reult of projecting the effect removed counts onto the old PCs.
#'   This should show reduced variance/tighter expected grouping
#'
#' @export
project_counts_onto_orig_pcs = function(dds, effect_removed_counts){

  logNorm_prcomp = stats::prcomp(
    t(SummarizedExperiment::assays(DESeq2::normTransform(dds))[[1]]))

  x = scale(t(effect_removed_counts),
            logNorm_prcomp$center,
            logNorm_prcomp$scale)

  crossprod(t(x), logNorm_prcomp$rotation)

}
