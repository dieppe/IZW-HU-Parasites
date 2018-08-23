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
  return(model$transition_matrix)
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
  if (!tree_model$success) {
    print(clade$root)
    stop(paste('TREE MODEL COULD NOT BE FITTED:', tree_model$error))
  }
  print("TREE MODEL FITTED")
  return(tree_model)
}

simulate_tree_with_model <- function (model, number_of_tips) {
  simulated_tree <- castor$generate_random_tree(
    parameters = model$parameters,
    max_tips = number_of_tips
  )
  return(simulated_tree)
}

fit_multifurcation_model <- function (clade) {
  multifurcation_data <- tree_utils$get_multifurcation_data(clade)
  multifurcation_model <- glm(
    level ~ 1,
    family = "poisson",
    data = multifurcation_data
  )
  return(multifurcation_model)
}

simulate_multifurcation_with_model <- function (tree, lambda) {
  probability_of_collapse <- lambda * exp(-lambda)
  traversal <- castor$get_tree_traversal_root_to_tips(
    tree,
    include_tips = FALSE
  )
  
  queue <- traversal$queue
  edges <- traversal$edges
  node2first_edge <- traversal$node2first_edge
  node2last_edge <- traversal$node2last_edge
  
  for(n in queue)
  {
    if (rbinom(1, 1 , probability_of_collapse)[1] == 1) {
      # collapse
      
    }
    else {
      # don't collapse
      
    }
  }
}
