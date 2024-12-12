# function to summarise simulation results and add bootstrapped 95% CIs
summarise_simulation_results <- function(sim_fit1, sim_fit2) {
  sim_fit1 %>%
    bind_rows(sim_fit2) %>%
    group_by(model, rho, lambda) %>%
    summarise(false_positives = mean(sig)) %>%
    rowwise() %>%
    # add bootstrapped 95% CIs
    mutate(
      bootstrap = map(false_positives, function(x) 
        replicate(1000, mean(rbinom(100, 1, x)))
        ),
      lower = quantile(bootstrap, 0.025),
      upper = quantile(bootstrap, 0.975)
      ) %>%
    select(!bootstrap)
}
