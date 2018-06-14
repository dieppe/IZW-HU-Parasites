library("modules")

run_stats <- function (evaluation_results_for_clade, stats) {
  stats_results <- sapply(
    stats,
    function (stat) {
      apply(evaluation_results_for_clade, 2, stat)
    }
  )
  return(stats_results)
}
