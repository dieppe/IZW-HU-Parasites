library("modules")

CONFIG <- import('./config')

run_stats <- Vectorize(
  function (evaluation_results_for_clade) {
    stats_results <- sapply(
      CONFIG$stats,
      function (stat) {
        return(
          lapply(
            evaluation_results_for_clade,
            function (dropped) {
              return(
                lapply(
                  dropped,
                  function (run_results) {
                    return(stat(run_results$recall))
                  }
                )
              )
            }
          )
        )
      }
    )
    return(stats_results)
  },
  vectorize.args = c('evaluation_results_for_clade'),
  SIMPLIFY = FALSE
)
