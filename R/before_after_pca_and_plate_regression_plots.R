#' @title FUNCTION_TITLE
#' @description FUNCTION_DESCRIPTION
#' @param counts log normalized "counts"
#' @param pca_basis_data data from which to create the PCA basis vectors
#' @param x_pc which PC to plot on the x axis
#' @param y_pc which PC to plot on the Y axis
#' @param meta sample metadata. Rows should be in same order as counts
#' @param plate_colors vector of colors for each batch_id
#' @param plot_title title of plot
#' @param pc_levels a vector of PC levels, eg 1,3,6,2,4,5 which will control
#'   the order which the PCs are plotted
#'
#' @return A list that includes plots and data
#'
#' @importFrom purrr map
#' @importFrom stringr str_remove
#' @importFrom dplyr as_tibble mutate select left_join all_of filter arrange desc pull
#' @importFrom broom tidy
#' @import ggplot2
#'
#' @export
before_after_pca_and_plate_regression_plots <- function(counts,
                                    pca_basis_data,
                                    x_pc,
                                    y_pc,
                                    meta,
                                    plate_colors,
                                    plot_title,
                                    pc_levels = NA) {

  counts_scaled_by_pca_basis <- scale(
    t(counts),
    pca_basis_data$center,
    pca_basis_data$scale
  )

  counts_projected_onto_pca_basis <- crossprod(
    t(counts_scaled_by_pca_basis),
    pca_basis_data$rotation
  )

  counts_projected_onto_pca_basis_df <-
    dplyr::as_tibble(counts_projected_onto_pca_basis, rownames = "sample") %>%
    plyr::mutate(sample_id = as.numeric(stringr::str_remove(sample, "sample_"))) %>%
    dplyr::select(sample_id, dplyr::all_of(paste0("PC", seq(1, 10)))) %>%
    dplyr::left_join(meta)

  counts_projects_onto_pca_basis_pcaplot <- counts_projected_onto_pca_basis_df %>%
    dplyr::filter(!is.na(batch_id)) %>%
    dplyr::mutate(batch_id = as.factor(batch_id)) %>%
    ggplot(aes_string(x_pc, y_pc, color = "batch_id")) +
    geom_point(alpha = .5, size = 3) +
    stat_ellipse(aes(linetype = batch_id)) +
    # scale_linetype_manual(values = c(0,0,0,0,1,0,0,0,0,1,0)) +
    scale_color_manual(values = plate_colors) +
    ylim(-70, 70) +
    xlim(-30, 30) +
    ggtitle(plot_title)


  data_for_lm <- counts_projected_onto_pca_basis_df %>%
    dplyr::filter(purpose == "experiment")

  plate_predicts_pc_rsquared <- data_for_lm %>%
    dplyr::select(dplyr::all_of(paste0("PC", seq(1, 10)))) %>% # exclude outcome, leave only predictors
    purrr::map(~ stats::lm(.x ~ data_for_lm$batch_id, data = data_for_lm)) %>%
    purrr::map(summary) %>%
    purrr::map_dbl("r.squared") %>%
    broom::tidy() %>%
    dplyr::arrange(dplyr::desc(x))

  if (unique(is.na(pc_levels))) {
    pc_levels <- dplyr::pull(dplyr::arrange(plate_predicts_pc_rsquared, x), names)
  }

  rsquared_plot <- plate_predicts_pc_rsquared %>%
    dplyr::mutate(names = factor(names, levels = pc_levels)) %>%
    ggplot(aes(x = names, y = x)) +
    geom_point(size = 5, color = "#CA0020") +
    ylab(expression(R^{
      2
    })) +
    xlab("response") +
    ggtitle(plot_title)

  list(
    pcaplot = counts_projects_onto_pca_basis_pcaplot,
    pc_pred_plate = rsquared_plot,
    pc_levels = pc_levels
  )
}
