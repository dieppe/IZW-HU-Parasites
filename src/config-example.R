# YOU NEED A config.R FILE FOR THE CODE TO RUN
# HERE ARE ALL THE CONFIG OPTIONS YOU NEED TO DEFINE
# ---
# MAKE SURE THAT ALL PATHS EXIST
full_tree_path <- normalizePath('../data/opentree9.1_tree/labelled_supertree/labelled_supertree.tre')

interaction_tree_path <- normalizePath('../data/GloBI_Dump/interactions.tsv')

output_path <- normalizePath('../output/')

clade_otts <- c(
  Eukaryota = 'ott304358',
  Nematoda = 'ott395057'
)

evaluations <- list(
  from_percentage_dropped = 90,
  to_percentage_dropped = 99.999,
  number_of_steps = 2,
  number_of_sampling_per_step = 2
)

stats <- c(min = min, max = max, mean = mean, median = median, sd = sd)

plots <- list(
  output_path = normalizePath(output_path, '/images'),
  extension = '.png',
  width = 12,
  height = 12,
  units = 'cm',
  res = 320
)
