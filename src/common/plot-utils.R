library('modules')

CONFIG <- import('./config')
utils <- import('./utils')

utils$install_packages('ggplot2')
ggplot <- import_package('ggplot2')

plot_results <- Vectorize(
  function (
    clade_name, 
    evaluation_results_for_clade, 
    stat_results_for_clade, 
    drops
  ) {
    # One-liner from https://stackoverflow.com/a/12639740
    melted_results <- data.frame(
      X = rep(
        as.numeric(names(evaluation_results_for_clade)),
        sapply(evaluation_results_for_clade, length)
      ), 
      Y = unlist(evaluation_results_for_clade)
    )
    
    plot <- ggplot$ggplot(
        melted_results,
        ggplot$aes(
          x = X,
          y = Y
        )
      ) +
      ggplot$geom_point(size = 0.1, color = "#ff967f") +
      ggplot$theme_bw() +
      ggplot$theme(
        text = ggplot$element_text(
          size=20,
          # family = "Phosphate Inline"
          family = "Optima"
        ),
        # title = ggplot$element_text(
        #   colour = ggplot$alpha(colour = "#ff967f", 0.8)
        # ),
        axis.text = ggplot$element_text(
          size=12,
          family = "Optima"
          # colour = ggplot$alpha(colour = "#000000", 0.6)
        ),
        axis.title = ggplot$element_text(
          size=16,
          family = "Optima"
          # colour = ggplot$alpha(colour = "#000000", 0.3)
        )
        # plot.background = ggplot$element_rect(
        #   fill = ggplot$alpha(colour = "#7fffd9", 0.3)
        # ),
        # panel.border = ggplot$element_rect(
        #   color = ggplot$alpha("#7fffd9", 0.3),
        #   size = 0.2
        # ),
        # panel.background = ggplot$element_rect(
        #   fill = ggplot$alpha(colour = "#ffffff", 0.8),
        #   color = "white"
        # ),
        # panel.grid.major = ggplot$element_line(
        #   color = ggplot$alpha("#7fffd9", 0.4),
        #   size = 0.2
        # ),
        # panel.grid.minor = ggplot$element_line(
        #   color = ggplot$alpha("#7fffd9", 0.4),
        #   size = 0.2,
        #   linetype = "dashed"
        # )
      ) +
      ggplot$scale_x_continuous(
        name = "% known states dropped",
        breaks = seq(0, 100, length.out = 11),
        labels = seq(0, 100, length.out = 11)
      ) +
      ggplot$scale_y_continuous(
        name = "Accuracy"
        # breaks = 0:10 / 10
        # labels = 0:10 * 10
      ) +
      ggplot$geom_line(
        data = stat_results_for_clade,
        ggplot$aes(
          x = drop,
          y = min,
          group = 1
        ),
        col = "#ffd67f",
        size = 1
      ) +
      ggplot$geom_line(
        data = stat_results_for_clade,
        ggplot$aes(
          x = drop,
          y = max,
          group = 1
        ),
        col = "#ac7fff",
        size = 1
      ) +
      ggplot$geom_line(
        data = stat_results_for_clade,
        ggplot$aes(
          x = drop,
          y = mean,
          group = 1
        ),
        col = "#7FE7FF",
        size = 1
      ) +
      ggplot$ggtitle(toupper(clade_name))
    return(plot)
  },
  vectorize.args = c(
    'clade_name', 
    'evaluation_results_for_clade', 
    'stat_results_for_clade'
  ),
  SIMPLIFY = FALSE
)

save_plot <- Vectorize(
  function (plot, clade_name, evaluation_config = CONFIG$evaluations, plot_config = CONFIG$plots) {
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
      '&FtoP_transition_cost=',
      evaluation_config$transition_costs[1,2],
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
