options(tidyverse.quiet = TRUE)
library(crew)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(
  packages = c("brms", "Matrix", "rstan", "tidyverse"),
  controller = crew_controller_local(workers = 2)
  )
tar_source()

# simulation targets
sim_targets <-
  tar_map(
    # iterate over values of lambda and rho
    values = expand_grid(lambda = c(0.2, 0.5, 0.8), rho = c(0.2, 0.5, 0.8)),
    # set up simulation model where true correlation is 0
    # using religious covariance with dow proximity matrix
    tar_target(
      sim_model,
      setup_simulation_model(religious_proximity_dow, lambda, rho)
    ),
    # simulate datasets
    tar_target(
      sim_data,
      simulate_data(sim_model, iter, lambda, rho),
      pattern = map(iter),
      iteration = "list"
    ),
    # fit models and extract slopes
    tar_target(
      sim_fit,
      fit_analysis_model(
        sim_data, analysis_model, religious_proximity,
        lambda, rho, iter
      ),
      pattern = map(sim_data, iter)
    )
  )

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
    ),
  # set up analysis model with religious covariance
  tar_target(analysis_model, setup_analysis_model(sim_data_0.2_0.2[[1]],
                                                  religious_proximity)),
  # simulation
  tar_target(iter, 1:100),
  sim_targets,
  tar_combine(sim_fit, sim_targets[["sim_fit"]]),
  tar_target(sim_fit_summary, summarise_simulation_results(sim_fit))
)
