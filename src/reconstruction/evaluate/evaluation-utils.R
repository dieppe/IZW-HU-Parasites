library('modules')

CONFIG <- import('../../config')
utils <- import('../../utils')
tree_utils <- import('../extract_data/tree-utils')
utils$install_packages('castor')
castor <- import_package('castor')
parallel <- import_package('parallel')

run_exact <- function (tree, tip_states) {
  result <- castor$hsp_max_parsimony(
    tree, 
    tip_states, 
    Nstates=2, 
    transition_costs=CONFIG$evaluations$transition_costs, 
    edge_exponent=0.0, 
    weight_by_scenarios=TRUE, 
    check_input=TRUE
  )
  return(result)
}

evaluate <- Vectorize(
  function (clade, tip_states) {
    drops <- seq(
      from=CONFIG$evaluations$from_percentage_dropped,  
      to=CONFIG$evaluations$to_percentage_dropped,  
      length.out=CONFIG$evaluations$number_of_steps
    )
    
    replication_sequence <- 1:(CONFIG$evaluations$number_of_replications)
    
    # We leave out only known states
    known_tips_selector <- !is.na(tip_states)
    number_of_known_tip_states <- length(tip_states[known_tips_selector])
    
    evaluation_results <- lapply(
      drops,
      function (drop) {
        print(paste0('Evaluation with ', drop, '% drop'))
        number_of_tip_states_to_drop <- 
          number_of_known_tip_states * (drop / 100)
        
        result <- parallel$mclapply(
          replication_sequence,
          function (...) {
            kept_tip_states <- tip_states
            indices_to_drop <- sample(
              number_of_known_tip_states, 
              number_of_tip_states_to_drop
            )
            kept_tip_states[known_tips_selector][indices_to_drop] <- NA
            castor_result <- run_exact(clade, kept_tip_states)
            analysis <- analyse_run(
              clade, 
              tip_states, 
              drop, 
              castor_result$likelihoods
            )
            return(analysis)
          },
          mc.cores = parallel$detectCores() / 2
        )
        names(result) <- replication_sequence
        return(result)
      }
    )
    names(evaluation_results) <- drops
    
    return(evaluation_results)
  },
  SIMPLIFY = FALSE
)

analyse_run <- function (clade, tip_states, drop, results) {
  return(list(
    recall = get_recall(clade, tip_states, drop, results),
    state_counts = count_states(results),
    number_of_state_changes = tree_utils$count_trait_changes(clade, results)
  ))
}

get_recall <- function (clade, tip_states, drop, results) {
  results_for_tips <- results[1:length(clade$tip.label), 1]
  
  # If a tip_state is not NA, then it means we knew if the tip was a FL|P
  known_tip_states_selector <- !is.na(tip_states)
  
  # Select reconstructed states for the tips with known states
  results_for_known_tips <- results_for_tips[known_tip_states_selector]
  # Select the known states
  known_tip_states <- tip_states[known_tip_states_selector]
  
  # Compare known and reconstructed states
  number_of_matching_states <- sum(
    (known_tip_states == 1 & results_for_known_tips > 0.5) |
    (known_tip_states == 2 & results_for_known_tips < 0.5),
    na.rm = TRUE
  )
  number_of_known_states <- length(known_tip_states)
  
  number_of_states_to_reconstruct <- as.integer(
    (as.double(drop) / 100) * number_of_known_states
  )
  number_of_states_kept <- 
    number_of_known_states - number_of_states_to_reconstruct

  number_of_correctly_reconstructed_states <- 
    number_of_matching_states - number_of_states_kept
  
  recall <- 
    number_of_correctly_reconstructed_states / number_of_states_to_reconstruct

  return(recall)
}

count_states <- function (results) {
  return(list(
    number_of_freelivings = sum(results[, 1] > 0.5, na.rm=TRUE),
    number_of_parasites = sum(results[, 1] < 0.5, na.rm=TRUE),
    number_of_undecided = sum(results[, 1] == 0.5, na.rm=TRUE)
  )) 
}
