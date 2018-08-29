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

reload_modules <- function () {
  reload(CONFIG)
  reload(utils)
  reload(tree_utils)
  reload(simulation_utils)
  reload(evaluation_utils)
}

tree <- tree_utils$read_tree()
clades <- tree_utils$extract_clades(tree)

lapply(
  clades, 
  function (clade) {
    tree_model <- simulation_utils$fit_tree_model(clade)
    # multifurcation_model <- fit_multifurcation_model(clade)
    simulated_tree <- simulation_utils$simulate_tree_with_model(
      tree_model, 
      1000 # Simulation is highly memory intensive
    )
    return(list(model = tree_model, tree = simulated_tree))
  }
)

utils$export_data('simulation-part1')

# TODO this needs the known states! (change needed in simulation-utils too...)
# simulated_states <- simulation_utils$generate_states_for_clades(
#   clades, 
#   simulated_clades
# )
# utils$export_data('simulation-part2')

# evaluation_results <- evaluation_utils$evaluate(
#   simulated_clades, 
#   simulated_states$tip_states
# )
# 
# utils$export_data('simulation')
