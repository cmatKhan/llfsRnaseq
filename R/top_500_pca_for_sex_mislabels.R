#' Use the top 500 most variable genes to calculate PCs and infer sex
#'
#' @description it happens that the variation int he top 500 most variable
#'   genes is driven the expression of genes related to biological sex.
#'   Because of this, we can use the top two PCs to infer the sex of the
#'   samples. The separation of samples is clearer in the PCs than it is when
#'   looking directly at sex chromosome experssion, it turns out.
#'
#' @param vst a vst(dds) object
#' @param slope the sex groups separate nicely when plotted on PC1 and PC2 such
#'   that they can be separated with a line. the `slope` controls the slope
#'   of that line. see also `intercept`
#' @param intercept see also `slope`. This controls the intercept of the
#'   line used to separate the sex labels
#' @param inferred_sex_direction one of c("up", "down"). Default is 'up',
#'   an arbitrary designation. This will 'flip' the labels, and is used b/c
#'   the 'direction' of the PCs is arbitrary.
#'
#' @return a list which has the data and the plot
#'
#' @importFrom dplyr filter
#' @importFrom DESeq2 plotPCA
#' @importFrom stringr str_remove str_extract
#'
#' @export
top_500_pca_for_sex_mislabels <- function(vst,
                                          slope,
                                          intercept = 0,
                                          inferred_sex_direction = "up") {
  top_500_gene_pca_data <- DESeq2::plotPCA(vst,
    intgroup = "sex",
    returnData = TRUE
  ) %>%
    left_join(as_tibble(colData(vst)), by = c(
      "name" = "count_headers",
      "sex"
    ))

  # return
  switch(inferred_sex_direction,
    "up" = top_500_gene_pca_data %>%
      mutate(inferred_sex = ifelse(PC2 < ((slope * PC1) + intercept), 1, 2)) %>%
      mutate(inferred_sex_mislabel = inferred_sex != sex),
    "down" = top_500_gene_pca_data %>%
      mutate(inferred_sex = ifelse(PC2 > ((slope * PC1) + intercept), 1, 2)) %>%
      mutate(inferred_sex_mislabel = inferred_sex != sex)
  )
}
