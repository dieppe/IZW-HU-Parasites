library(ape)
library(Rcpp)
library(castor)

print("READING TREE")
# -------- Tree: --------
path_tree <- "data/subtree/Eukaryota.tre"
# read.tree(file = "", text = NULL, tree.names = NULL, skip = 0, comment.char = "", keep.multi = FALSE, ...)
tree <- read.tree(path_tree)
print("TREE READ")

print("READING TAGGED TREE")
# -------- Tagged tree: --------
path_tagged_tree <- "code/bufferfiles/tagged_tree.tre"
tagged_tree <- read.tree(path_tagged_tree)

print("TAGGED TREE READ")
# ---- get the tagged tips of the tree ----
state_ids <- tree$tip.label

number_of_tips <- length(state_ids)
internal_nodes <- tree$node.label

tip_states <- tagged_tree$tip.label

mapped_tip_states <- as.integer(tip_states)

# ---- run parsimony algorithm ----
# Reconstruct ancestral discrete states of nodes and predict unknown (hidden) states of tips on a tree using maximum parsimony. Transition costs can vary between transitions, and can optionally be weighted by edge length.
likelihoods = hsp_max_parsimony(tree, mapped_tip_states, Nstates=2, transition_costs="all_equal", edge_exponent=0.0, weight_by_scenarios=TRUE, check_input=TRUE)
