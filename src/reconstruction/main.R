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

utils <- import('../utils')
CONFIG <- import('./config')
tree_utils <- import('./tree-utils')
interaction_utils <- import('./interaction-utils')

utils$install_packages('castor')

castor <- import_package('castor')

tree <- tree_utils$extract_tree_from_path(
  CONFIG$full_tree_path,
  CONFIG$root_ott
)

interactions <- interaction_utils$extract_interactions_from_path(
  CONFIG$interaction_tree_path
)

mapped_states <- tree_utils$get_parsimony_tip_states(tree, interactions$parasites, interactions$freelivings)

result <- castor$hsp_max_parsimony(tree, mapped_states, Nstates=2, transition_costs="all_equal", edge_exponent=0.0, weight_by_scenarios=TRUE, check_input=TRUE)
