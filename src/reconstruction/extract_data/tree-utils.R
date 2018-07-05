# Prepare the tree:
# - read the full tree from OTL
# - read the full interactions file from OTL
# - find the subtree we are interested in
# - tag the tree accordingly (N/A, FL=0, P=1)
# Outputs the tagged tree

library('modules')

CONFIG <- import('../../config')
utils <- import('../../utils')
utils$install_packages('castor')

castor <- import_package('castor')

read_tree <- function () {
  path <- CONFIG$full_tree_path
  print(paste('LOADING TREE FROM', path))
  tree <- castor$read_tree(file = path)
  return(tree)
}

extract_clades <- function (tree) {
  clades <- lapply(
    CONFIG$clade_otts,
    function (clade_ott) {
      print(paste('EXTRACTING CLADE', clade_ott))
      clade <- castor$get_subtree_at_node(tree, node = clade_ott)
      return(clade$subtree)
    }
  )
  return(clades)
}

build_tip_states_for_clade <- Vectorize(
  function (clade, parasites, freelivings) {
    print('BUILDING P|FL STATES FOR CLADE')
    labels <- clade$tip.label
    labels[labels %in% freelivings$ott] <- 1
    labels[labels %in% parasites$ott] <- 2
    labels[labels != 1 & labels != 2] <- NA
    return(as.integer(labels))
  },
  vectorize.args = c('clade'),
  SIMPLIFY = FALSE
)

# This method is only there to double-check the results of the other 
# count_trait_changes implementation
# Took approx 40 minutes to run (compared to mere seconds for the other one)
# count_trait_changes <- function (tree, states) {
#   number_of_origins <- 0
#   number_of_losses <- 0
#   edge <- tree$edge
#   queue <- c(tree$root)
#   safe <- 0
#   old <- Sys.time()
#   hash_map <- new.env(hash = TRUE)
#   sapply(
#     seq_along(edge[,1]), 
#     function (index) { 
#       origin <- as.character(edge[index, 1])
#       cur_value <- hash_map[[origin]]
#       hash_map[[origin]] <- c(cur_value, edge[index, 2])
#     }
#   )
#   while (length(queue) > 0) {
#     safe <- safe + 1
#     parent <- queue[1]
#     queue <- tail(queue, length(queue) - 1)
#     children <- hash_map[[as.character(parent)]]
#     queue <- c(queue, children)
#     parent_state <- states[parent]
#     children_states <- states[children]
#     if (parent_state >= 0.5 & any(children_states < 0.5, na.rm=TRUE)) {
#       number_of_origins = number_of_origins + 1
#     }
#     else if (parent_state < 0.5 & any(children_states >= 0.5, na.rm=TRUE)) {
#       number_of_losses = number_of_losses + 1
#     }
#   }
#   print(Sys.time() - old)
#   return(c(
#     state_of_root_node = states[tree$root],
#     number_of_losses = number_of_losses,
#     number_of_origins = number_of_origins
#   ))
# }

# Using castor to traverse the tree is orders of magnitude faster
# Produce same results as above
count_trait_changes <- function (tree, states) {
  # We only care for the first column (since col#1 + col#2 = 1 for every row)
  states <- states[, 1]
  number_of_losses <- 0
  number_of_origins <- 0
  # Traversal returns also queue which we don't want here
  # - edges is a list of "grouped" edges for every non-terminal node in the tree
  #   indices in edges point to the tree$edge row indices
  # - node2first_edge is a list of indices that point to edges. For a given node
  #   n, edges[node2first_edge[n]] will be the first edge (index) of that node.
  # - node2last_edge is the same, but for the last edge (index of that ndoe).
  #  This way we can access all the edges of node directly, and so traverse the
  #  tree from root to tip.
  traversal <- castor$get_tree_traversal_root_to_tips(
    tree,
    include_tips = FALSE
  )
  edges <- traversal$edges
  node2first_edge <- traversal$node2first_edge
  node2last_edge <- traversal$node2last_edge
  for (n in 1:length(node2first_edge)) {
    edge_row_indices <- edges[node2first_edge[n]:node2last_edge[n]]
    edge <- tree$edge[edge_row_indices, , drop=FALSE]
    # We are guaranteed that first column is the parent id repeated for all rows
    parent <- edge[, 1][1] # if (edge_row_indices == c()) then edge[1, 1] throws
    children <- edge[, 2]
    parent_state <- states[parent]
    children_states <- states[children]
    if (parent_state >= 0.5 & any(children_states < 0.5, na.rm=TRUE)) {
      # parent was a freeliving
      number_of_origins = number_of_origins + 1
    }
    else if (parent_state < 0.5 & any(children_states >= 0.5, na.rm=TRUE)) {
      # parent was a parasite
      number_of_losses = number_of_losses + 1
    }
  }
  return(c(
    state_of_root_node = states[traversal$queue[1]],
    number_of_losses = number_of_losses,
    number_of_origins = number_of_origins
  ))
}
