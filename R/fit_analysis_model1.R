# function to fit analysis model and return slope
# adapted from https://github.com/ScottClaessens/crossNationalCorrelations
fit_analysis_model1 <- function(sim_data, analysis_model1, 
                                lambda, rho, iter) {
  # fit model
  fit <- update(
    object = analysis_model1,
    newdata = sim_data,
    control = list(adapt_delta = 0.99),
    chains = 4,
    cores = 4,
    seed = 1
    )
  # extract statistics
  tibble(
    model  = "Analysis without controls",
    rho    = rho,
    lambda = lambda,
    iter   = iter,
    bX     = fixef(fit)["x","Estimate"],
    Q2.5   = fixef(fit)["x","Q2.5"],
    Q97.5  = fixef(fit)["x","Q97.5"],
    sig    = (Q2.5 > 0 & Q97.5 > 0) | (Q2.5 < 0 & Q97.5 < 0),
    rhat   = rhat(fit)["b_x"],
    secs   = max(rowSums(get_elapsed_time(fit$fit)))
  )
}