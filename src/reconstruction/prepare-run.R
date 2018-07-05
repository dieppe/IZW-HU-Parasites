tree_utils <- import('./extract_data/tree-utils')
interaction_utils <- import('./extract_data/interaction-utils')

prepare <- function () {
  print('LOADING OBJECTS NEEDED FOR RECONSTRUCTION OF THE REAL TREE')
  return(list(
    interactions = interaction_utils$extract_interactions(),
    tree = tree_utils$read_tree()
  ))
}

get_run <- function (prepared = NA) {
  print('PREPARING RUN FOR RECONSTRUCTION OF THE REAL TREE')

  if (any(is.na(prepared))) {
    stop('PLEASE CALL preload FUNCTION FIRST')
  }
  
  clades <- tree_utils$extract_clades(prepared$tree)
  tip_states_by_clade <- tree_utils$build_tip_states_for_clade(
    clades,
    prepared$interactions$parasites,
    prepared$interactions$freelivings
  )
  return(list(
    clades = clades,
    tip_states_by_clade = tip_states_by_clade
  ))
}
