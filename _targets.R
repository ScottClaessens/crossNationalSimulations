options(tidyverse.quiet = TRUE)
library(crew)
library(targets)
library(tarchetypes)
library(tidyverse)
tar_option_set(
  packages = c("brms", "Matrix", "rstan", "tidyverse")#,
  #controller = crew_controller_local(workers = 2)
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
      sim_fit1,
      fit_analysis_model1(sim_data, analysis_model1, lambda, rho, iter),
      pattern = map(sim_data, iter)
    ),
    tar_target(
      sim_fit2,
      fit_analysis_model2(
        sim_data, analysis_model2, religious_proximity, lambda, rho, iter
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
  # set up "no controls" analysis model
  tar_target(analysis_model1, setup_analysis_model1(sim_data_0.2_0.2[[1]])),
  # set up analysis model with religious covariance
  tar_target(analysis_model2, setup_analysis_model2(sim_data_0.2_0.2[[1]],
                                                    religious_proximity)),
  # run simulation
  tar_target(iter, 1:100),
  sim_targets,
  tar_combine(sim_fit1, sim_targets[["sim_fit1"]]),
  tar_combine(sim_fit2, sim_targets[["sim_fit2"]]),
  # get summary of simulation results
  tar_target(sim_fit_summary, summarise_simulation_results(sim_fit1, sim_fit2)),
  # plot simulation results
  tar_target(plot, plot_simulation_results(sim_fit_summary)),
  # render manuscript
  tar_render(manuscript, "manuscript.Rmd"),
  # print session info for reproducibility
  tar_target(
    sessionInfo,
    writeLines(capture.output(sessionInfo()), "sessionInfo.txt")
    )
)
