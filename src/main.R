# install.packages('devtools')
# devtools::install_github('klmr/modules')
# devtools::install_github('wesm/feather/R')

library('modules')

tryCatch(
  {
    # TODO if rstudioapi is not present, try the other way...
    rstudioapi = import_package('rstudioapi')
    setwd(dirname(rstudioapi$getActiveDocumentContext()$path))
  },
  error = function (cond) { print("Not working in R Studio, check the working directory") }
)

getwd()

utils <- import('./utils')
CONFIG <- import('./config')

tree_utils <- import('./reconstruction/extract_data/tree-utils')
interaction_utils <- import('./reconstruction/extract_data/interaction-utils')
evaluation_utils <- import('./reconstruction/evaluate/evaluation-utils')
stat_utils <- import('./reconstruction/reporting/stat-utils')
plot_utils <- import('./reconstruction/reporting/plot-utils')

interactions <- interaction_utils$extract_interactions_from_path(
  CONFIG$interaction_tree_path
)

tree <- tree_utils$read_tree_from_path(CONFIG$full_tree_path)
clades <- tree_utils$extract_clades(tree, CONFIG$clade_otts)

percentage_to_recall_sequence <- seq(
  from=CONFIG$evaluations$from_percentage_dropped, 
  to=CONFIG$evaluations$to_percentage_dropped, 
  length.out=CONFIG$evaluations$number_of_steps
)

evaluation_results <- lapply(
  seq_along(clades),
  function (i) {
    # This is not pretty, but it seems to be an accepted way of accessing
    # names in `lapply`
    clade_name <- names(clades)[i]
    clade <- clades[[clade_name]]

    print(paste('EVALUATION FOR CLADE', clade_name))

    mapped_states <- tree_utils$build_tip_states_for_clade(
      clade,
      interactions$parasites,
      interactions$freelivings
    )
    
    results <- sapply(
      percentage_to_recall_sequence,
      function (percentage_to_recall) {
        evaluation_result <- evaluation_utils$evaluate(
          clade,
          mapped_states, 
          percentage_to_recall, 
          CONFIG$evaluations$number_of_sampling_per_step
        )
        print(evaluation_result)
        return(evaluation_result)
      }
    )
    
    dimnames(results)[[2]] <- percentage_to_recall_sequence

    return(results)
  }
)
names(evaluation_results) <- names(clades)

stat_results <- lapply(
  evaluation_results,
  function (evaluation_results_for_clade) {
    stat_results_for_clade <- stat_utils$run_stats(
      evaluation_results_for_clade, 
      CONFIG$stats
    )
    return(stat_results_for_clade)
  }
)

plots <- plot_utils$plot_results(
  names(CONFIG$clade_otts), 
  evaluation_results, 
  stat_results
)

plot_utils$save_plot(
  plots,
  names(plots),
  CONFIG$evaluations,
  CONFIG$plots
)

save.image(
  file = paste0(
    '.RData_from=',
    CONFIG$evaluations$from_percentage_dropped,
    '&to=',
    CONFIG$evaluations$to_percentage_dropped,
    '&steps=',
    CONFIG$evaluations$number_of_steps,
    '&times=',
    CONFIG$evaluations$number_of_sampling_per_step
  )
)
