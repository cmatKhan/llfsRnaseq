#' remove coefficient effects from counts
#'
#' @importFrom DESeq2 design
#' @importFrom SummarizedExperiment colData
#' @importFrom stats coef
#' @importFrom rlang is_formula
#'
#' @description subtract effect from norm counts of a single factor from
#'   coef x design. coef is in normalized log space. dds must have been
#'   created with model.matrix
#' @note works for both formula and model.matrix designs in the dds object
#'
#' @param deseq_object a deseq data object REQUIRED: the object must have
#'   been created with a model.matrix rather than a formula for the
#'   design argument
#' @param col_indicies a numeric vector corresponding to the column
#'   indicies of the batch parameters you'd like to remove
#'
#' @return a log2 scale gene by samples matrix with desired effects removed
#'
#' @export
remove_parameter_effects = function(deseq_object, col_indicies){

  # if the design(dds) is a formula
  if(is_formula(DESeq2::design(deseq_object))){
    model_matrix = model.matrix(DESeq2::design(deseq_object),
                                SummarizedExperiment::colData(deseq_object))
  } else if(is.matrix(DESeq2::design(deseq_object))){
    model_matrix = DESeq2::design(deseq_object)
  } else{
    stop("design(deseq_object) is not recognized as a formula or matrix")
  }
  browser()
  coefficients = coef(deseq_object)[,col_indicies]
  batch_effect_matrix = model_matrix[,col_indicies]

  # note psuedocount
  log_norm_counts = log2(DESeq2::counts(deseq_object, normalized=TRUE)+1)

  # coefficients is dim gene x features
  # design_matrix is dim sample x features to remove
  return(log_norm_counts - (coefficients %*% t(batch_effect_matrix)))

}
