#'
#' make a plot showing the direction of percent intergenic on PC1/2 axis
#'
#' @param pca_df_list list of PCA dfs
#' @param plate_colors a vector corresponding to plate colors. should be equal
#'   in length to the number of plates
#' @param slope_dir either 1 or -1, to flip slope depending on how the PCs are
#'   calculated
#'
#' @import ggplot2
#' @importFrom broom tidy
#' @importFrom stats lm
#'
#' @return A plot showing the line which results from conducting a linear
#'   module with formula percent_intergenic ~ PC1 + PC2
#'
#' @export
direction_change_in_percent_intergenic <- function(pca_df_list,
                                                   plate_colors,
                                                   slope_dir = 1) {

  only_passing_lm <- broom::tidy(stats::lm(percent_intergenic ~ PC1 + PC2,
    data = pca_df_list$passing
  ))

  delta_y <- only_passing_lm %>%
    filter(term == "PC2") %>%
    pull(estimate)
  delta_x <- only_passing_lm %>%
    filter(term == "PC1") %>%
    pull(estimate)

  pca_df_list$all$sample_status <-
    ifelse(pca_df_list$all$purpose == "control", "control",
      as.character(pca_df_list$all$sample_status)
    )


  as_tibble(pca_df_list$all) %>%
    ggplot() +
    geom_point(aes(x = PC1, y = PC2,
                   color = sample_status), size = 3, alpha = .7) +
    scale_color_manual(
      labels = c(
        ">= 8 % intergenic",
        "< 8 % intergenic",
        "control"
      ),
      values = c(
        "qc_fail" = "#DB4325",
        "qc_pass" = "#006164",
        "control" = "#F4A000"
      )
    ) +
    geom_abline(slope = slope_dir * delta_y / delta_x) +
    labs(color = "")
}

# direction_change_in_percent_intergenic(qc_datasets, PLATE_COLORS, slope_dir = -1)
