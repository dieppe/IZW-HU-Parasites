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

utils <- import('./utils')
CONFIG <- import('./config')

tree_utils <- import('./reconstruction/extract_data/tree-utils')
interaction_utils <- import('./reconstruction/extract_data/interaction-utils')
evaluation_utils <- import('./reconstruction/evaluate/evaluation-utils')
stat_utils <- import('./reconstruction/reporting/stat-utils')
plot_utils <- import('./reconstruction/reporting/plot-utils')

interactions <- interaction_utils$extract_interactions_from_path(
  CONFIG$interaction_tree_path
)

tree <- tree_utils$read_tree_from_path(CONFIG$full_tree_path)
clades <- tree_utils$extract_clades(tree, CONFIG$clade_otts)
tip_states_by_clade <- tree_utils$build_tip_states_for_clade(
  clades,
  interactions$parasites,
  interactions$freelivings
)

drops <- seq(
  from=CONFIG$evaluations$from_percentage_dropped,  
  to=CONFIG$evaluations$to_percentage_dropped,  
  length.out=CONFIG$evaluations$number_of_steps
)

evaluation_results <- evaluation_utils$evaluate(
  clades,
  tip_states_by_clade,
  drops,
  CONFIG$evaluations$number_of_sampling_per_step
)

stat_results <- stat_utils$run_stats(
  evaluation_results, 
  CONFIG$stats
)

plots <- plot_utils$plot_results(
  names(CONFIG$clade_otts), 
  evaluation_results, 
  stat_results
)

plot_utils$save_plot(
  plots,
  names(plots),
  CONFIG$evaluations,
  CONFIG$plots
)

save.image(
  file = paste0(
    CONFIG$output_path,
    '/.RData_from=',
    CONFIG$evaluations$from_percentage_dropped,
    '&to=',
    CONFIG$evaluations$to_percentage_dropped,
    '&steps=',
    CONFIG$evaluations$number_of_steps,
    '&times=',
    CONFIG$evaluations$number_of_sampling_per_step
  )
)
