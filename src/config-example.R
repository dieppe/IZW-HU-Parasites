# YOU NEED A config.R FILE FOR THE CODE TO RUN
# HERE ARE ALL THE CONFIG OPTIONS YOU NEED TO DEFINE
full_tree_path <- normalizePath('../data/opentree9.1_tree/labelled_supertree/labelled_supertree.tre')

interaction_tree_path <- normalizePath('../data/GloBI_Dump/interactions.tsv')

clade_otts <- c(
  Eukaryota = 'ott304358',
  Nematoda = 'ott395057'
)

number_of_evaluations = 2
lower_percentage_to_recall = 90
upper_percentage_to_recall = 99.999

number_of_sampling_per_recall = 2

stats <- c(min = min, max = max, mean = mean, median = median, sd = sd)