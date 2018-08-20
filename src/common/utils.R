CONFIG <- import('./config')

install_packages <- function (packages) {
  to_install = setdiff(packages, rownames(installed.packages()))
  if (length(to_install) > 0) {
    print(
      paste('PACKAGES',
      paste(to_install, collapse = ' '),
      'WILL BE INSTALLED')
    )
    install.packages(to_install)
  }
  else {
    print('NO PACKAGE TO INSTALL')
  }
}

export_data <- function (base_name) {
  save.image(
    file = paste0(
      CONFIG$output_path,
      '/.',
      base_name,
      '?from=',
      CONFIG$evaluations$from_percentage_dropped,
      '&to=',
      CONFIG$evaluations$to_percentage_dropped,
      '&steps=',
      CONFIG$evaluations$number_of_steps,
      '&replications=',
      CONFIG$evaluations$number_of_replications,
      '&FtoP_transition_cost=',
      CONFIG$evaluations$transition_costs[1,2]
    )
  )
}
