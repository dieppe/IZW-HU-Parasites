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
interaction_utils <- import('./cross-evaluation/interaction-utils')
evaluation_utils <- import('./common/evaluation-utils')
stat_utils <- import('./common/stat-utils')
plot_utils <- import('./common/plot-utils')

reload_modules <- function () {
  reload(CONFIG)
  reload(utils)
  reload(tree_utils)
  reload(interaction_utils)
  reload(evaluation_utils)
  reload(stat_utils)
  reload(plot_utils)
}

interactions <- interaction_utils$extract_interactions()
tree <- tree_utils$read_tree()

clades <- tree_utils$extract_clades(tree)
tip_states_by_clade <- tree_utils$build_tip_states_for_clade(
  clades,
  interactions$parasites,
  interactions$freelivings
)

evaluation_results <- evaluation_utils$evaluate(clades, tip_states_by_clade)

utils$export_data('evaluation')
