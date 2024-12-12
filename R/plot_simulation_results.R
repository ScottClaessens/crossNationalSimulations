# function to plot results of simulation
plot_simulation_results <- function(sim_fit_summary) {
  # plot
  out <-
    sim_fit_summary %>%
    mutate(
      model = ifelse(
        model == "Analysis without controls",
        "Analysis\nwithout controls",
        "Analysis using religious\nproximity matrix from ARDA"
      )
    ) %>%
    ggplot(
      mapping = aes(
        x = lambda,
        y = false_positives,
        ymin = lower,
        ymax = upper,
        group = factor(rho),
        colour = factor(rho)
        )
      ) +
    geom_hline(
      yintercept = 0.05,
      linetype = "dashed"
      ) +
    geom_pointrange(
      position = position_dodge(width = 0.08),
      size = 0.3
      ) +
    geom_line(
      position = position_dodge(0.08)
      ) +
    facet_wrap(
      . ~ fct_rev(model),
      scales = "free_y"
      ) +
    scale_x_continuous(
      name = "Strength of autocorrelation for outcome variable",
      limits = c(0.1, 0.9),
      breaks = c(0.2, 0.5, 0.8)
      ) +
    scale_y_continuous(
      name = "False positive rate",
      limits = c(0, 1),
      breaks = c(0, 0.25, 0.5, 0.75, 1)
      ) +
    guides(
      colour = guide_legend(
        title = "Strength of\nautocorrelation\nfor predictor\nvariable"
        )
      ) +
    ggtitle("Simulation using religious proximity matrix from Dow") +
    theme_classic() +
    theme(
      strip.background = element_blank(),
      strip.text = element_text(size = 10)
      )
  # save
  ggsave(
    filename = "plots/simulation_results.pdf",
    plot = out,
    width = 6.5,
    height = 3.5
  )
  return(out)
}
