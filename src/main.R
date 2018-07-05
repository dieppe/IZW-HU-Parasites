# install.packages('devtools')
# devtools::install_github('klmr/modules')
# devtools::install_github('wesm/feather/R')

library('modules')

tryCatch(
  {
    # TODO if rstudioapi is not present, try the other way...
    rstudioapi = import_package('rstudioapi')
    setwd(dirname(rstudioapi$getActiveDocumentContext()$path))
  },
  error = function (cond) { 
    print("Not working in R Studio, check the working directory (should point to $PROJECT_ROOT/src/):")
    getwd()
  }
)

CONFIG <- import('./config')
prepare_run <- import('./reconstruction/prepare-run')
# prepare_run <- import('./simulation/prepare-run')
evaluation_utils <- import('./reconstruction/evaluate/evaluation-utils')
stat_utils <- import('./reconstruction/reporting/stat-utils')
plot_utils <- import('./reconstruction/reporting/plot-utils')

reload_modules <- function () {
  reload(CONFIG)
  reload(prepare_run)
  reload(evaluation_utils)
  reload(stat_utils)
  reload(plot_utils)
}

prepared <- prepare_run$prepare()
run <- prepare_run$get_run(prepared)
clades <- run$clades
tip_states_by_clade <- run$tip_states_by_clade

evaluation_results <- evaluation_utils$evaluate(clades, tip_states_by_clade)

stat_results <- stat_utils$run_stats(evaluation_results)

plots <- plot_utils$plot_results(
  names(CONFIG$clade_otts),
  evaluation_results,
  stat_results,
  drops
)

plot_utils$save_plot(plots, names(plots))

save.image(
  file = paste0(
    CONFIG$output_path,
    '/.RData_from=',
    CONFIG$evaluations$from_percentage_dropped,
    '&to=',
    CONFIG$evaluations$to_percentage_dropped,
    '&steps=',
    CONFIG$evaluations$number_of_steps,
    '&replications=',
    CONFIG$evaluations$number_of_replications,
    '&FtoP_transition_cost=',
    CONFIG$evaluations$transition_costs[1,2]
  )
)
