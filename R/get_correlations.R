# function to get correlations between different proximity matrices
get_correlations <- function(geographic_proximity,
                             linguistic_proximity,
                             religious_proximity,
                             religious_proximity_dow) {
  tibble(
    geographic_proximity    = as.numeric(geographic_proximity),
    linguistic_proximity    = as.numeric(linguistic_proximity),
    religious_proximity     = as.numeric(religious_proximity),
    religious_proximity_dow = as.numeric(religious_proximity_dow)
  ) %>%
    cor(use = "pairwise")
}