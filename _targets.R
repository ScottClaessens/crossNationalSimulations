library(targets)
tar_option_set(packages = "tidyverse")
tar_source()

# pipeline
list(
  # proximity matrix files
  tar_target(geographic_proximity_file,    "data/geographic_proximity.rds"),
  tar_target(linguistic_proximity_file,    "data/linguistic_proximity.rds"),
  tar_target(religious_proximity_file,     "data/religious_proximity.rds"),
  tar_target(religious_proximity_dow_file, "data/religious_proximity_dow.rds"),
  # load proximity matrices
  tar_target(geographic_proximity,    readRDS(geographic_proximity_file)),
  tar_target(linguistic_proximity,    readRDS(linguistic_proximity_file)),
  tar_target(religious_proximity,     readRDS(religious_proximity_file)),
  tar_target(religious_proximity_dow, readRDS(religious_proximity_dow_file)),
  # get correlations between matrices
  tar_target(
    cors,
    get_correlations(geographic_proximity, linguistic_proximity,
                     religious_proximity, religious_proximity_dow)
    )
)
