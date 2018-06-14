library('modules')

utils <- import('../../utils')
utils$install_packages('castor')
castor <- import_package('castor')
parallel <- import_package('parallel')

run_exact <- function (tree, tip_states) {
  result <- castor$hsp_max_parsimony(
    tree, 
    tip_states, 
    Nstates=2, 
    transition_costs="all_equal", 
    edge_exponent=0.0, 
    weight_by_scenarios=TRUE, 
    check_input=TRUE
  )
  return(result)
}

evaluate <- Vectorize(
  function (clade, tip_states, drops, number_of_sampling_per_step) {
    # We leave out only known states
    known_tips_indexes <- !is.na(tip_states)
    number_of_known_tips <- length(tip_states[known_tips_indexes])
    
    evaluation_results <- sapply(
      drops,
      function (percentage_to_drop) {
        number_of_tips_to_drop <- (
          number_of_known_tips * (percentage_to_drop / 100)
        )
        result <- parallel$mclapply(
          1:number_of_sampling_per_step,
          function (...) {
            tips_to_evaluate <- tip_states
            sampled_indices_to_drop <- sample(
              number_of_known_tips, 
              number_of_tips_to_drop
            )
            tips_to_evaluate[known_tips_indexes][sampled_indices_to_drop] <- NA
            castor_result <- run_exact(clade, tips_to_evaluate)
            result <- analyse(clade, castor_result, tip_states, percentage_to_drop)
            return(result)   
          },
          mc.cores = parallel$detectCores()
        )
        result <- unlist(result)
        return(result)
      }
    )
    dimnames(evaluation_results)[[2]] <- drops
    
    return(evaluation_results)
  },
  vectorize.args = c('clade', 'tip_states'),
  SIMPLIFY = FALSE
)

analyse <- function (clade, castor_result, tip_states, percentage_to_recall) {
  liks <- castor_result$likelihoods
  
  tip_liks <- liks[1:length(clade$tip.label), 1]
  known_tip_liks <- tip_liks[!is.na(tip_states)]
  known_states <- tip_states[!is.na(tip_states)]
  
  correct_states <-
    (known_states == 1 & known_tip_liks > 0.5) |
    (known_states == 2 & known_tip_liks < 0.5)
  number_of_correct_states <- sum(correct_states, na.rm = TRUE)
  number_of_know_states <- length(known_states)
  number_of_left_out <- as.integer(
      (as.double(percentage_to_recall) / 100) * number_of_know_states
  )
  number_of_kept <- number_of_know_states - number_of_left_out

  percentage_recovered <-
    (number_of_correct_states - number_of_kept) /
    number_of_left_out

  return(percentage_recovered)
}
