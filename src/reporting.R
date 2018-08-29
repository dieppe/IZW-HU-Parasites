library('modules')

tryCatch(
  {
    rstudioapi = import_package('rstudioapi')
    setwd(dirname(rstudioapi$getActiveDocumentContext()$path))
  },
  error = function (cond) {
    print("Not working in R Studio, check the working directory (should point to $PROJECT_ROOT/src/):")
    getwd()
  }
)

CONFIG <- import('./common/config')
plot_utils <- import('./common/plot-utils')

transform_results <- function (result) {
  recalls <- list()
  for (drop in names(result)) {
    for (replicate in result[[drop]]) {
      recalls[[drop]] <- c(recalls[[drop]], replicate$recall)
    }
  }
  return(recalls)
}

apply_stats <- function (recalls) {
  stats <- data.frame(sapply(
    CONFIG$stats,
    function (stat) {
      sapply(
        recalls,
        function (recall) {
          return(stat(recall))
        }
      )
    }
  ))
  stats$drop <- as.numeric(rownames(stats))
  return(stats)
}

transformed_results <- lapply(evaluation_results, transform_results)
stats_for_results <- lapply(transformed_results, apply_stats)

plots <- plot_utils$plot_results(
  names(transformed_results),
  transformed_results,
  stats_for_results,
  as.numeric(names(transformed_results$Eukaryota))
)

plot_utils$save_plot(plots, names(plots))
