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

taggedTree <- tree_utils$tag_tree_with_interactions(tree, interactions)
