tree_utils <- import('../common/tree-utils')
utils <- import('../common/utils')
utils$install_packages('castor')

castor <- import_package('castor')
parallel <- import_package('parallel')

Nthreads <- parallel$detectCores() / 2

fit_mk_model <- function (clade) {
  model <- castor$asr_mk_model(
    clade,
    Nthreads = Nthreads
  )
  if (!model$success) {
    stop('MK MODEL COULD NOT BE FITTED')
  }
  model$transition_matrix
}

simulate_states_with_transition_matrix <- function (tree, transition_matrix) {
  states <- castor::simulate_mk_model(tree, transition_matrix)
  return(states)
}

generate_states_for_clade <- function (clade, simulated_clade) {
  transition_matrix <- fit_mk_model(clade)
  simulated_states <- simulate_states_with_transition_matrix(
    simulated_clade, 
    transition_matrix
  )
  return(simulated_states)
}

generate_states_for_clades <- Vectorize(generate_states_for_clade)

fit_tree_model <- function (clade) {
  # TODO castor$multifurcations_to_bifurcations ?
  tree_model <- castor$fit_tree_model(
    clade,
    Nthreads = Nthreads
  )
  print(tree_model)
  if (!tree_model$success) {
    print(clade$root)
    stop(paste('TREE MODEL COULD NOT BE FITTED:', tree_model$error))
  }
  return(tree_model)
}

simulate_tree_with_model <- function (model, number_of_tips) {
  simulated_tree <- castor$generate_random_tree(
    parameters = model$parameters,
    max_tips = 1000
  )
  return(simulated_tree)
}

# fit_multifurcation_model <- function (clade) {
#   multifurcation_data <- tree_utils$get_multifurcation_data(clade)
#   multifurcation_model <- glm(
#     level ~ node_count, 
#     family = "poisson", 
#     data = multifurcation_data
#   )
#   return(multifurcation_model)
# }
# 
# simulate_multifurcation_with_model <- function (tree, model) {
#   
# }

generate_tree_for_clade <- function (clade) {
  tree_model <- fit_tree_model(clade)
  # multifurcation_model <- fit_multifurcation_model(clade)
  simulated_tree <- simulate_tree_with_model(
    tree_model, 
    10000 # Simulation is highly memory intensive
  )
  return(simulated_tree)
}

generate_trees_for_clades <- Vectorize(generate_tree_for_clade)
