# function to set up brms model without controls
# adapted from https://github.com/ScottClaessens/crossNationalCorrelations
setup_analysis_model1 <- function(data) {
  # initialize model
  brm(
    formula = y ~ 0 + Intercept + x,
    data = data,
    prior = c(
      prior(normal(0, 0.5), class = b),
      prior(exponential(5), class = sigma)
    ),
    chains = 0
    )
}
