# function to fit analysis model and return slope
# adapted from https://github.com/ScottClaessens/crossNationalCorrelations
fit_analysis_model <- function(sim_data, analysis_model, 
                               religious_proximity, lambda, rho, iter) {
  # remove hong kong and puerto rico from matrix and dataset
  # as no data on religious proximity in these two countries
  religious_proximity <- 
    religious_proximity[!(rownames(religious_proximity) %in% c("HK","PR")),
                        !(colnames(religious_proximity) %in% c("HK","PR"))]
  sim_data <- dplyr::filter(sim_data, !(country %in% c("HK", "PR")))
  # get religious covariance matrix
  religious_covariance <- as.matrix(Matrix::nearPD(religious_proximity)$mat)
  # fit model
  fit <- update(
    object = analysis_model,
    newdata = sim_data,
    data2 = list(A = religious_covariance),
    control = list(adapt_delta = 0.99),
    chains = 4,
    cores = 4,
    seed = 1
    )
  # extract statistics
  tibble(
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