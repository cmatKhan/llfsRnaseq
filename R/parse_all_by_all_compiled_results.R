#'
#' summarize an all_by_all_compiled_metrics dataframe for upload to the
#' database
#'
#' @param all_by_all_df a wgs all by all compiled metrics dataframe with the
#'   columns 'total_variants', 'library_id', 'rna_subject', 'dna_subject',
#'   'total_variants', 'matching_variants', 'match_ratio'
#'
#' @import dplyr
#'
#' @return a dataframe suitable for upload to the full_wgs_compare table
#'
#' @export
parse_all_by_all_compiled_results = function(all_by_all_df){

  stopifnot(all(c('total_variants', 'library_id',
                     'rna_subject', 'dna_subject', 'total_variants',
                     'matching_variants', 'match_ratio') %in%
                     colnames(all_by_all_df)))

  all_by_all_df %>%
    filter(total_variants>=100) %>%
    group_by(library_id) %>%
    arrange(desc(match_ratio)) %>%
    summarize(labelled_dna_subject=first(rna_subject),
              labelled_total_variants=
                total_variants[rna_subject==dna_subject][1],
              labelled_match_variants=
                matching_variants[rna_subject==dna_subject][1],
              labelled_match_ratio=
                match_ratio[rna_subject == dna_subject][1],
              emperical_best_subject=first(dna_subject),
              emperical_best_total_variants=first(total_variants),
              emperical_best_match_variants=first(matching_variants),
              emperical_best_match_ratio=first(match_ratio),
              emperical_next_subject=nth(dna_subject,2),
              emperical_next_total_variants=nth(total_variants,2),
              emperical_next_match_variants=nth(matching_variants,2),
              emperical_next_match_ratio=nth(match_ratio,2),
              chisq_labelled=chisq.test(matrix(
                c(total_variants[rna_subject==dna_subject]-
                    matching_variants[rna_subject==dna_subject],
                  first(total_variants)-first(matching_variants),
                  matching_variants[rna_subject==dna_subject],
                  first(matching_variants)), ncol = 2))$p.value,
              chisq_emperical=chisq.test(matrix(
                c(first(total_variants)-first(matching_variants),
                  nth(total_variants,2)-nth(matching_variants,2),
                  first(matching_variants),
                  nth(matching_variants,2)),
                ncol = 2))$p.value)
}


