library("modules")

CONFIG <- import('./config')

run_stats <- Vectorize(
  function (evaluation_results_for_clade) {
    stats_results <- sapply(
      CONFIG$stats,
      function (stat) {
        apply(evaluation_results_for_clade, 2, stat)
      }
    )
    return(stats_results)
  },
  vectorize.args = c('evaluation_results_for_clade'),
  SIMPLIFY = FALSE
)
