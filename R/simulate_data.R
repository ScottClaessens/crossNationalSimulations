# function to simulate data from brms model
# adapted from https://github.com/ScottClaessens/crossNationalCorrelations
simulate_data <- function(model, iter, lambda, rho) {
  # run model
  sim <- update(
    object = model,
    sample_prior = "only",
    warmup = 0,
    iter = 1,
    chains = 1,
    seed = iter
    )
  # get simulated data
  pred <- posterior_predict(sim)
  # standardise simulated x and y
  y <- as.numeric(scale(pred[1, , "y"]))
  x <- as.numeric(scale(pred[1, , "x"]))
  # return dataset
  tibble(
    x = x,
    y = y,
    country = rownames(sim$data2$covMat),
    seed = iter
    )
}
