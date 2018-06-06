library('modules')

castor <- import_package('castor')

run_exact <- function (tree, mapped_states) {
  result <- castor$hsp_max_parsimony(
    tree, 
    mapped_states, 
    Nstates=2, 
    transition_costs="all_equal", 
    edge_exponent=0.0, 
    weight_by_scenarios=TRUE, 
    check_input=TRUE
  )
  return(result)
}

evaluate <- function (clade, mapped_states, percentage_to_recall, how_many_times) {
  # We leave out only known states
  N_states <- length(mapped_states[!is.na(mapped_states)])
  N_state_to_recall <- N_states * (percentage_to_recall / 100)
  print(paste0(
    'RECALL ',
    round(percentage_to_recall, digits=2), 
    '% (',
    round(N_state_to_recall),
    ')'
  ))
  
  print(sum(!is.na(mapped_states), na.rm = TRUE))
  
  evaluation_results <- sapply(
    1:how_many_times, 
    function (i) {
      print(paste0(
        'SAMPLING #', 
        i, 
        '/', 
        how_many_times, 
        ' (',
        percentage_to_recall, 
        '% RECALL)'
      ))
      sampled_states <- mapped_states
      sampled_indices <- sample(N_states, N_state_to_recall)
      sampled_states[!is.na(sampled_states)][sampled_indices] <- NA
      castor_result <- run_exact(clade, sampled_states)
      analyse(clade, castor_result, mapped_states, percentage_to_recall)
    }
  )
  names(evaluation_results) <- 1:how_many_times
  
  return(evaluation_results)
}

analyse <- function (clade, castor_result, mapped_states, percentage_to_recall) {
  liks <- castor_result$likelihoods
  
  tip_liks <- liks[1:length(clade$tip.label), 1]
  known_tip_liks <- tip_liks[!is.na(mapped_states)]
  known_states <- mapped_states[!is.na(mapped_states)]
  
  correct_states <-
    (known_states == 1 & known_tip_liks > 0.5) |
    (known_states == 2 & known_tip_liks < 0.5)
  number_of_correct_states <- sum(correct_states, na.rm = TRUE)
  nnumber_of_know_states <- length(known_states)
  number_of_left_out <- as.integer(
      (as.double(percentage_to_recall) / 100) * number_of_know_states
  )
  number_of_kept <- number_of_know_states - number_of_left_out
  
  print(paste0(
    'ANALYSING EVALUATION WITH ',
    number_of_kept,
    '/',
    number_of_know_states,
    ' REMAINING STATES (',
    round(as.double(percentage_to_recall), digits=2),
    '% LEFT OUT)'
  ))
  
  print(paste0(
    number_of_correct_states,
    '/',
    number_of_know_states,
    ' STATES HAVE BEEN CORRECTLY PREDICTED (',
    round(number_of_correct_states / number_of_know_states * 100, digits=2),
    '%)'
  ))
  
  percentage_recovered <-
    (number_of_correct_states - number_of_kept) /
    number_of_left_out
  # Another way to calculate is by doing:
  # p_r <- ((n_o_f_s / n_o_k_s) - 0.9) / 0.1
  print(paste0(
    number_of_correct_states - number_of_kept,
    '/',
    number_of_left_out,
    ' LEFT OUT STATES HAVE BEEN CORRECTLY PREDICTED (',
    round(percentage_recovered * 100, digits=2),
    '%)'
  ))
  return(percentage_recovered)
}