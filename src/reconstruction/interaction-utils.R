library('modules')

utils <- import('../utils')
utils$install_packages('readr')

readr <- import_package('readr')
# feather must been installed with devtools, see main.R
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
  interactions <- import_from_feather_file(otl_interactions_path)
  if (is.null(interactions)) {
    print(paste('IMPORTING INTERACTIONS FROM ', otl_interactions_path))
    interactions <- readr$read_tsv(
      otl_interactions_path,
      col_names = TSV_COLUMNS
    )
    cache_to_feather_file(interactions, otl_interactions_path)
  }
  # return(interactions)
  filtered_interactions <- filter_interactions(interactions)
  # # TODO cache these in a feather file
  return(filtered_interactions)
}

get_feather_path_from_tsv_path <- function (tsvPath) {
  return(sub('.tsv', '.feather', tsvPath))
}

cache_to_feather_file <- function (dataFrame, tsvPath) {
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

# "Private" function
p__bind_source_and_target <- function (source, target) {
  input_source_names <- c('source_ott', 'source_common_name', 'interaction')
  input_target_names <- c('target_ott', 'target_common_name', 'interaction')
  result_names <- c('ott', 'common_name', 'interaction')
  s <- source[input_source_names]
  names(s) <- result_names
  t <- target[input_target_names]
  names(t) <- result_names
  return(rbind(s, t))
}

#' Find all parasites in a given interaction file from OTL
#' A parasite is a specie that has a parasitic interaction with another species
#' 
#'  @param interactions a dataframe containing the OTL formatted interactions
#'  @export
find_parasites <- function (interactions) {
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
  
  parasites <- p__bind_source_and_target(
    source_is_parasite, 
    target_is_parasite
  )
  
  return(parasites)
}

#' Find all freelivings in a given interaction file from OTL
#' A freeliving is a specie that is a host of a parasitic interaction if it is
#' not itself a parasite (this accounts for parasites of parasites)
#' 
#'  @param interactions a dataframe containing the OTL formatted interactions
#'  @param parasites a dataframe of parasites with at least an ott column
find_freelivings <- function (interactions, parasites) {
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
  
  freelivings <- p__bind_source_and_target(
    source_is_freeliving, 
    target_is_freeliving
  )
  
  return(freelivings)
}

#' Filter interactions between parasites and freelivings
#' 
#' @param interactions a dataframe containing the OTL formatted interactions
#' @return The list 
#'     \item{parasites}{the parasites found in the interactions set}
#'     \item{freelivings}{the freelivings found in the interactions set}
#'     
#' @export
filter_interactions <- function (interactions) {
  print('FILTERING INTERACTIONS')
  parasites <- find_parasites(interactions)
  freelivings <- find_freelivings(interactions, parasites)
  
  deduplicate_ott <- function (data) {
    data <- data[!duplicated(data$ott),]
    return(data)
  }
  
  cleanup_ott_formatting <- function (data) {
    data$ott <- sub('OTT:', 'ott', data$ott)
    return(data)
  }
  
  parasites <- cleanup_ott_formatting(deduplicate_ott(parasites))
  freelivings <- cleanup_ott_formatting(deduplicate_ott(freelivings))
  
  return(list(parasites = parasites, freelivings = freelivings))
}
