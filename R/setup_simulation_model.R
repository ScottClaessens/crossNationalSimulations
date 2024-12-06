# function to set up brms model that will simulate data
# adapted from https://github.com/ScottClaessens/crossNationalCorrelations
setup_simulation_model <- function(covMat, lambda, rho) {
  # covMat near positive definite
  covMat <- as.matrix(Matrix::nearPD(covMat)$mat)
  # signal for dependent variable = lambda
  # signal for independent variable = rho
  signalY <- lambda
  signalX <- rho
  # calculate sd and sigma values, assuming total variance sd^2 + sigma^2 = 1
  # signal = sd^2 / (sd^2 + sigma^2)
  # signal = sd^2 / 1
  # sd = sqrt(signal)
  sdY <- sqrt(signalY)
  sdX <- sqrt(signalX)
  # sd^2 + sigma^2 = 1
  # sigma = sqrt(1 - sd^2)
  sigmaY <- sqrt(1 - sdY^2)
  sigmaX <- sqrt(1 - sdX^2)
  # mock data for simulation (just to feed to stan so model can run)
  d <- data.frame(
    y = rnorm(nrow(covMat)),
    x = rnorm(nrow(covMat)),
    id = rownames(covMat)
    )
  # simulation
  brm(
    formula =
      bf(y ~ 0 + (1 | gr(id, cov = covMat))) +
      bf(x ~ 0 + (1 | gr(id, cov = covMat))) +
      set_rescor(TRUE),
    data = d,
    data2 = list(covMat = covMat),
    prior = c(
      prior_string(
        paste0("constant(", sdY, ")"),
        class = "sd",
        resp = "y"
      ),
      prior_string(
        paste0("constant(", sigmaY, ")"),
        class = "sigma",
        resp = "y"
      ),
      prior_string(
        paste0("constant(", sdX, ")"),
        class = "sd",
        resp = "x"
      ),
      prior_string(
        paste0("constant(", sigmaX, ")"),
        class = "sigma",
        resp = "x"
      ),
      prior_string(
        paste0("constant(cholesky_decompose(diag_matrix(rep_vector(1.0, 2))))"),
        class = "rescor"
      )
    ),
    sample_prior = "only",
    warmup = 0,
    iter = 1,
    chains = 1
  )
}
