# Prepare the tree:
# - read the full tree from OTL
# - read the full interactions file from OTL
# - find the subtree we are interested in
# - tag the tree accordingly (N/A, FL=0, P=1)
# Outputs the tagged tree

library('modules')

utils = import('../../utils')
utils$install_packages('ape')

ape = import_package('ape')

extract_tree_from_path <- function (otl_tree_path, root_ott) {
  print(paste('LOAD TREE FROM', otl_tree_path))
  tree <- ape::read.tree(otl_tree_path)
  tree <- ape::extract.clade(tree, node = root_ott)
  return(tree)
}

get_parsimony_tip_states <- function (tree, parasites, freelivings) {
  print('TAG TREE')
  labels <- tree$tip.label
  labels[labels %in% freelivings$ott] <- 1
  labels[labels %in% parasites$ott] <- 2
  labels[labels != 1 & labels != 2] <- NA
  as.integer(labels)
}
