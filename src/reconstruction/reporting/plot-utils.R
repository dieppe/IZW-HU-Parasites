library('modules')

utils <- import('../../utils')

utils$install_packages(c('ggplot2', 'reshape2'))
ggplot <- import_package('ggplot2')
reshape <- import_package('reshape2')

plot_results <- Vectorize(
  function (clade_name, evaluation_results_for_clade, stat_results_for_clade) {
    melted_results <- reshape$melt(evaluation_results_for_clade)
    melted_stats <- reshape$melt(stat_results_for_clade)
  
    plot <- ggplot$ggplot(
        melted_results,
        ggplot$aes(
          x = Var2,
          y = value
        )
      ) +
      ggplot$geom_point(size = 0.1, color = "#ff967f") +
      ggplot$theme_bw() +
      ggplot$theme(
        text=element_text(size=20, family = "Phosphate Inline"),
        title = element_text(colour = alpha(colour = "#ff967f", 0.8)),
        axis.text = element_text(size=10, family = "Optima", colour = alpha(colour = "#000000", 0.6)),
        axis.title = element_text(size=14, family = "Optima", colour = alpha(colour = "#000000", 0.3)),
        plot.background = element_rect(fill = alpha(colour = "#7fffd9", 0.3)),
        panel.border = element_rect(color = alpha("#7fffd9", 0.3), size = 0.2),
        panel.background = element_rect(fill = alpha(colour = "#ffffff", 0.8) , color = "white"),
        panel.grid.major = element_line(color = alpha("#7fffd9", 0.4), size = 0.2),
        panel.grid.minor = element_line(color = alpha("#7fffd9", 0.4), size = 0.2, linetype = "dashed")
      ) +
      ggplot$scale_x_continuous(name = "dropped", breaks = 90:100) +
      ggplot$scale_y_continuous(name = "recall", breaks = 0:10 / 10, labels = 0:10 * 10) +
      ggplot$geom_line(
        data = melted_stats[melted_stats$Var2 == "min",],
        ggplot$aes(
          x = Var1,
          y = value
        ),
        col = "#ffd67f"
      ) +
      ggplot$geom_line(
        data = melted_stats[melted_stats$Var2 == "max",],
        ggplot$aes(
          x = Var1,
          y = value
        ),
        col = "#ac7fff"
      ) +
      ggplot$ggtitle(toupper(clade_name))
    return(plot)
  },
  SIMPLIFY = FALSE
)

save_plot <- Vectorize(
  function (plot, clade_name, evaluation_config, plot_config) {
    path = plot_config$output_path
    filename <- paste0(
      clade_name, 
      '_from=',
      evaluation_config$from_percentage_dropped,
      '&to=',
      evaluation_config$to_percentage_dropped,
      '&steps=',
      evaluation_config$number_of_steps,
      '&times=',
      evaluation_config$number_of_replications,
      plot_config$extension
    )
    ggplot$ggsave(
      filename = filename,
      path = path,
      # see https://github.com/tidyverse/ggplot2/issues/2276
      device = function (...) {
        png(
          ..., 
          units = plot_config$units,
          res = plot_config$res
        )
      },
      plot = plot,
      width = plot_config$width,
      height = plot_config$height
    )
  },
  vectorize.args = c('plot', 'clade_name')
)
