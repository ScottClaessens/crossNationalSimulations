# function to set up brms model controlling for religious proximity
# adapted from https://github.com/ScottClaessens/crossNationalCorrelations
setup_analysis_model <- function(data, religious_proximity) {
  # remove hong kong and puerto rico from matrix and dataset
  # as no data on religious proximity in these two countries
  religious_proximity <- 
    religious_proximity[!(rownames(religious_proximity) %in% c("HK","PR")),
                        !(colnames(religious_proximity) %in% c("HK","PR"))]
  data <- dplyr::filter(data, !(country %in% c("HK", "PR")))
  # get religious covariance matrix
  religious_covariance <- as.matrix(Matrix::nearPD(religious_proximity)$mat)
  # initialize model
  brm(
    formula = y ~ 0 + Intercept + x + (1 | gr(country, cov = A)),
    data = data,
    data2 = list(A = religious_covariance),
    prior = c(
      prior(normal(0, 0.5), class = b),
      prior(exponential(5), class = sd),
      prior(exponential(5), class = sigma)
    ),
    chains = 0
    )
}
