
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

evaluate <- function (tree, mapped_states) {
  # We want to leave 10..98% of the data out, and check how well the algorithm
  # fares on real data
  percent_to_leave_out <- seq(from=10, to=98, length.out=10)
  # We leave out only known states
  N_states <- length(mapped_states[!is.na(mapped_states)])
  
  samples <- lapply(
    percent_to_leave_out, 
    function (percent) {
      sampled_states <- mapped_states
      sampled_indices <- sample(N_states, N_states * (percent / 100))
      sampled_states[!is.na(sampled_states)][sampled_indices] <- NA
      return(sampled_states)
    }
  )
  
  results <- lapply(samples, function (s) { run_exact(tree, s) })
  names(results) <- percent_to_leave_out
  return(results)
}
