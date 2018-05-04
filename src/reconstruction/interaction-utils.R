library('modules')

utils <- import('../utils')
utils$install_packages('readr')

readr <- import_package('readr')
feather <- import_package('feather')

TSV_COLUMNS <- c(
  'source_ott', 'source_common_name', 'source_type', 'source_blank', 
  'source_taxonomy',  'source_taxonomy_ids', 'source_taxonomy_columns', 
  'source_info', 'source_pic', 'intercation_page', 'interaction', 'target_ott', 
  'target_common_name', 'target_type', 'target_blank', 'target_taxonomy', 
  'target_taxonomy_ids', 'target_taxonomy_columns', 'target_info', 'target_pic',
  'blank', 'paper_name', 'info_source', 'interaction_reporter', 
  'interaction_archive', 'blank2', 'interaction_id', 'version'
)

PARASITE_SOURCE <- c('parasiteOf', 'pathogenOf')
PARASITE_TARGET <- c('hasParasite', 'hasPathogen')

FREELIVING_SOURCE <- c(
  'preysOn', 'eats', 'flowersVisitedBy', 'hasPathogen', 'pollinatedBy',
  'hasParasite', 'hostOf'
)
FREELIVING_TARGET <- c(
  'preyedUponBy', 'parasiteOf', 'visitsFlowersOf', 'pathogenOf', 'hasHost'
)

extract_interactions_from_path <- function (otl_interactions_path) {
  print(paste('EXTRACTING INTERACTIONS FROM ', otl_interactions_path))
  interactions <- import_from_feather_file(otl_interactions_path)
  if (is.null(interactions)) {
    interactions <- readr$read_tsv(
      otl_interactions_path,
      col_names = TSV_COLUMNS
    )
    cache_feather_to_file(interactions, otl_interactions_path)
  }
  return(interactions)
  # filtered_interactions <- filter_interactions(interactions)
  # # TODO cache these in a feather file
  # return(filtered_interactions)
}

get_feather_path_from_tsv_path <- function (tsvPath) {
  return(sub('.tsv', '.feather', tsvPath))
}

cache_feather_to_file <- function (dataFrame, tsvPath) {
  print('CACHING INTERACTION FILE TO FEATHER')
  feather$write_feather(
    dataFrame, 
    get_feather_path_from_tsv_path(tsvPath)
  )
}

import_from_feather_file <- function (tsvPath) {
  print('IMPORTING INTERACTIONS FROM FEATHER FILE...')
  featherPath <- get_feather_path_from_tsv_path(tsvPath)
  if (file.exists(featherPath)) {
    return(feather$read_feather(featherPath))
  }
  print('FEATHER FILE NOT FOUND')
  return(NULL)
}

# TODO add missing informations to the resulting vector
# (better then to create a dataframe...)
# Info: ott, common_name, interaction_name
filter_interactions <- function (interactions) {
  source_is_parasite <-
    interactions[
      interactions$interaction %in% PARASITE_SOURCE &
      grepl('OTT', interactions$source_ott), 
    ]
  target_is_parasite <-
    interactions[
      interactions$interaction %in% PARASITE_TARGET &
      grepl('OTT', interactions$target_ott), 
    ]
  
  
  ps <- source_is_parasite[c('source_ott', 'source_common_name', 'interaction')]
  names(ps) <- c('ott', 'common_name', 'interaction')
  
  pt <- target_is_parasite[c('target_ott', 'target_common_name', 'interaction')]
  names(pt) <- c('ott', 'common_name', 'interaction')
  
  parasites <- rbind(ps, pt)
  
  # parasites <- c(source_is_parasite$source_ott, target_is_parasite$target_ott)
  
  source_is_freeliving <-
    interactions[
      interactions$interaction %in% FREELIVING_SOURCE &
      !interactions$source_ott %in% parasites$ott &
      grepl('OTT', interactions$source_ott), 
    ]
  target_is_freeliving <-
    interactions[
      interactions$interaction %in% FREELIVING_TARGET &
      !interactions$target_ott %in% parasites$ott &
      grepl('OTT', interactions$target_ott), 
    ]
  
  freelivings <- c(
    source_is_freeliving$source_ott, 
    target_is_freeliving$target_ott
  )
  
  parasites <- parasites[unique(parasites$ott)]
  
  return(
    sub('OTT:', 'ott', c(parasites = parasites, freelivings = freelivings))
  )
}
