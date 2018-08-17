# install.packages('devtools')
# devtools::install_github('klmr/modules')
# devtools::install_github('wesm/feather/R')

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
utils <- import('./common/utils')
tree_utils <- import('./common/tree-utils')
simulation_utils <- import('./simulation/simulation-utils')
evaluation_utils <- import('./common/evaluation-utils')
stat_utils <- import('./common/stat-utils')
plot_utils <- import('./common/plot-utils')

reload_modules <- function () {
  reload(CONFIG)
  reload(utils)
  reload(tree_utils)
  reload(simulation_utils)
  reload(evaluation_utils)
  reload(stat_utils)
  reload(plot_utils)
}

tree <- tree_utils$read_tree()
clades <- tree_utils$extract_clades(tree)

simulated_clades <- simulation_utils$generate_trees_for_clades(clades)
simulated_states <- simulation_utils$generate_states_for_clades(
  clades, 
  simulated_clades
)

evaluation_results <- evaluation_utils$evaluate(
  simulated_clades, 
  simulated_states$tip_states
)

utils$export_data('simulation')
