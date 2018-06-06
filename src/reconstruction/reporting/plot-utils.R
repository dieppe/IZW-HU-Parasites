library('modules')

utils <- import('../../utils')

utils$install_packages(c('ggplot2', 'reshape2'))
ggplot <- import_package('ggplot2')
reshape <- import_package('reshape2')

plot_results <- function (evaluation_results, stats) {
  stats_results <- lapply(
    evaluation_results,
    function (result) {
      sapply(
        stats,
        function (stat) {
          apply(result, 2, stat)
        }
      )
    }
  )
  
  melted_results <- reshape$melt(evaluation_results)
  melted_stats <- reshape$melt(stats_results)
  
  ggplot$ggplot(
      melted_results,
      ggplot$aes(
        x = Var2,
        y = value,
        group = L1
      )
    ) + 
    ggplot$geom_point() +
    ggplot$theme_bw() +
    ggplot$scale_x_discrete(name = "Dropped") + 
    ggplot$scale_y_continuous(name = "Recall") +
    ggplot$geom_line(
      data = melted_stats[melted_stats$Var2 == "min",],
      ggplot$aes(
        x = Var1,
        y = value,
        group = Var2 
      ),
      col = "blue"
    ) +
    ggplot$geom_line(
      data = melted_stats[melted_stats$Var2 == "max",],
      ggplot$aes(
        x = Var1,
        y = value,
        group = Var2 
      ),
      col = "red"
    )
}
