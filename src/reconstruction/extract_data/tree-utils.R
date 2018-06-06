# Prepare the tree:
# - read the full tree from OTL
# - read the full interactions file from OTL
# - find the subtree we are interested in
# - tag the tree accordingly (N/A, FL=0, P=1)
# Outputs the tagged tree

library('modules')

utils <- import('../../utils')
utils$install_packages('ape')

ape <- import_package('ape')

read_tree_from_path <- function (otl_tree_path) {
  print(paste('LOAD TREE FROM', otl_tree_path))
  tree <- ape::read.tree(otl_tree_path)
  return(tree)
}

extract_clades <- function (tree, clade_otts) {
  clades <- lapply(
    clade_otts,
    function (clade_ott) {
      print(paste('EXTRACTING CLADE', clade_ott))
      clade <- ape::extract.clade(tree, node = clade_ott)
      return(clade)
    }
  )
  names(clades) <- names(clade_otts)
  return(clades)
}

build_tip_states_for_clade <- function (clade, parasites, freelivings) {
  print('BUILDING P|FL STATES FOR CLADE')
  labels <- clade$tip.label
  labels[labels %in% freelivings$ott] <- 1
  labels[labels %in% parasites$ott] <- 2
  labels[labels != 1 & labels != 2] <- NA
  return(as.integer(labels))
}
