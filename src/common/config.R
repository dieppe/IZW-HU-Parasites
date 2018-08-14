full_tree_path <- normalizePath('../data/opentree9.1_tree/labelled_supertree/labelled_supertree.tre')

interaction_tree_path <- normalizePath('../data/GloBI_Dump/interactions.tsv')

output_path <- normalizePath('../output/')

clade_otts <- c(
  # Eukaryota = 'ott304358',
  # Chloroplastida = 'ott361838',
  # Fungi = 'ott352914',
  # Metazoa = 'ott691846',
  # Apicomplexa = 'ott422673',
  # Arthropoda = 'ott632179',
  # Chordata = 'ott125642',
  # Nematoda = 'ott395057',
  # Platyhelminthes = 'ott555379',
  Insecta = 'ott1062253'
)

evaluations <- list(
  from_percentage_dropped = 0,
  to_percentage_dropped = 99.999,
  number_of_steps = 1,
  number_of_replications = 1,
  transition_costs = 'all_equal'
  # transition_costs = matrix(c(0, 1, 1, 0), nrow = 2)
)

stats <- c(min = min, max = max, mean = mean, median = median, sd = sd)

plots <- list(
  output_path = normalizePath(paste0(output_path, '/images')),
  extension = '.png',
  width = 12,
  height = 12,
  units = 'cm',
  res = 320
)

simulation <- list(
  how_many_tips = 1000000,
  how_many_trees = 10,
  how_many_simulations_per_tree = 100
)
