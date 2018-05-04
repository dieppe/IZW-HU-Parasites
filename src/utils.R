# packages <- c("ggplot2", "dplyr", "Hmisc", "lme4", "arm", "lattice", "lavaan")
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
