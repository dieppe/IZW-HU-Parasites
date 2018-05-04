# Prepare the tree:
# - read the full tree from OTL
# - read the full interactions file from OTL
# - find the subtree we are interested in
# - tag the tree accordingly (N/A, FL=0, P=1)
# Outputs the tagged tree

library('modules')

utils = import('../utils')
utils$install_packages('ape')

ape = import_package('ape')

extract_tree_from_path <- function (otl_tree_path, root_ott) {
  print(paste('LOAD TREE FROM', otl_tree_path))
  tree <- ape::read.tree(otl_tree_path)
  tree <- ape::extract.clade(tree, node = root_ott)
  return(tree)
}

tag_tree_with_interactions <- function (tree, interactions) {
  print('TAG TREE')
}
