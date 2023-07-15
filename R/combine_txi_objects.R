#' combine two txi objects
#'
#' @param txi1 one of the two txi objects to combine
#' @param txi2 the other txi object
#'
#' @return the result of combining `txi1` and `txi2`
#'
#' @note the column names of `txi1` and `txi2` are required to be unique
#'
#' @export
combine_txi_objects = function(txi1, txi2){
  if(length(intersect(colnames(txi1$abundance),colnames(txi2$abundance))) > 0){
    stop(paste0("The two txi objects share colnames -- ",
         "make sure the colnames (sample ids) are unique"))
  }

  txi = list()
  txi$abundance = cbind(txi1$abundance,
                        txi2$abundance)

  txi$counts = cbind(txi1$counts,
                     txi2$counts)

  txi$length = cbind(txi1$length,
                     txi2$length)

  txi$countsFromAbundance = "no"

  # return the txi object
  txi
}
