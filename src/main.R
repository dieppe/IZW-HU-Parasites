# install.packages('devtools')
# devtools::install_github('klmr/modules')
# devtools::install_github('wesm/feather/R')

library('modules')

tryCatch(
  {
    # TODO if rstudioapi is not present, try the other way...
    rstudioapi = import_package('rstudioapi')
    setwd(dirname(rstudioapi$getActiveDocumentContext()$path))
  }
)

getwd()

utils <- import('./utils')
CONFIG <- import('./reconstruction/config')
tree_utils <- import('./reconstruction/extract_data/tree-utils')
interaction_utils <- import('./reconstruction/extract_data/interaction-utils')

evaluate_utils <- import('./reconstruction/evaluate/run_castor')

tree <- tree_utils$extract_tree_from_path(
  CONFIG$full_tree_path,
  CONFIG$root_ott
)

interactions <- interaction_utils$extract_interactions_from_path(
  CONFIG$interaction_tree_path
)

mapped_states <- tree_utils$get_parsimony_tip_states(tree, interactions$parasites, interactions$freelivings)

complete_run_result <- evaluate_utils$run_exact(tree, mapped_states)
evaluation_results <- evaluate_utils$evaluate(tree, mapped_states)
