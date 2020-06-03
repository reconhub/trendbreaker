
# needs the current devel @master
# install using:
remotes::install_github("reconhub/projections")
library(projections)
devtools::load_all()
library(tidyverse)


# simulation parameters
## serial interval distribution
si_param = epitrix::gamma_mucv2shapescale(4.7, 2.9/4.7)
si_distribution <- distcrete::distcrete("gamma", interval = 1,
                                        shape = si_param$shape,
                                        scale = si_param$scale,
                                        w = 0.5)



# simulations scenarios
# all values include log-normally distributed R

## 1. constant: 1000 initial cases, R = 1 (6 weeks)

## 2. lockdown: 10 initial cases, R = 3 (5 weeks) then R = 0.8 (1 week)

## 3. relapse: 1000 initial cases, R = 0.8 (5 weeks) then R = 1.2 (1 week)

n_replicates <- 10
sd <- .1
duration <- 6 * 7
change_at <- 5 * 7
true_k <- duration - change_at

params_constant <- list(
  n_ini = 1000,
  R = rlnorm(n_replicates, log(1), sd),
  duration = duration,
  n_replicates = n_replicates,
  si = si_distribution
)

params_lockdown <- list(
  n_ini = 10,
  R = list(rlnorm(n_replicates, log(3), sd),
           rlnorm(n_replicates, log(0.7), sd)
           ),
  time_change = change_at,
  duration = duration,
  n_replicates = n_replicates,
  si = si_distribution
)

params_relapse <- list(
  n_ini = 1000,
  R = list(rlnorm(n_replicates, log(0.7), sd),
           rlnorm(n_replicates, log(1.2), sd)
           ),
  time_change = change_at,
  duration = duration,
  n_replicates = n_replicates,
  si = si_distribution
)


list_params <- list(
  constant = params_constant,
  lockdown = params_lockdown,
  relapse = params_relapse)


# Run simulations

## Simulate epi trajectories
## Auxiliary function wrapping around projections::project
make_simulations <- function(params, duration_ini = 14) {
  i <- incidence::incidence(rep(seq_len(duration_ini), each = params$n_ini))
  project(i,
          R = params$R,
          n_sim = params$n_replicates,
          n_days = params$duration,
          time_change = params$time_change,
          si = params$si)
}

## Run for the different scenarios
## TODO: check simulations in projections::project, 2nd plot is weird
list_sims <- lapply(list_params, make_simulations)
cowplot::plot_grid(plotlist = lapply(list_sims, plot), ncol = 1)



# analyse data
library(epichange)

# define candidate models
models <- list(
  poisson_constant = glm_model(count ~ 1, family = "poisson"),
  regression = lm_model(count ~ date),
  negbin_time = glm_nb_model(count ~ date)
)

## small helper to make a data.frame for a single trajectory
get_sim <- function(x, i) {
  data.frame(date = get_dates(x), count = as.integer(x[, i]))
}



# run analyses
# we try with free k (max = 10 days) and a fixed one (10 days)

## free k, max = 10
list_res_free_k <- lapply(
  list_sims,
  function(e) lapply(
    1:ncol(e),
    function(i) asmodee(get_sim(e, i),
                        models = models,
                        max_k = 10,
                        method = evaluate_aic)))

## fixed k
list_res_fixed_k <- lapply(
  list_sims,
  function(e) lapply(
    1:ncol(e),
    function(i) asmodee(get_sim(e, i),
                        models = models,
                        fixed_k = 10,
                        method = evaluate_aic)))


# analyse results

## we look at:
## FPR 
## FNR
## ability to infer true k

library(cadet)

inferred_k <- lapply(list_res_free_k, sapply, function(e) e$k)
inferred_k

## results for 'constant' scenario
tnr_constant_free_k <- 1 - sapply(list_res_free_k$constant, function(e) mean(get_results(e)$outlier))
tnr_constant_fixed_k <- 1 - sapply(list_res_fixed_k$constant, function(e) mean(get_results(e)$outlier))

## results for 'lockdown' scenario
ref_lockdown <- rep(c(FALSE, TRUE), c(duration - 7, 7))
ref_lockdown <- factor(ref_lockdown, levels = c(FALSE, TRUE))

tpr_lockdown_free_k <- sapply(
  list_res_free_k$lockdown,
  function(e) caret::sensitivity(factor(get_results(e)$outlier),
                                 ref_lockdown))

tpr_lockdown_fixed_k <- sapply(
  list_res_fixed_k$lockdown,
  function(e) caret::sensitivity(factor(get_results(e)$outlier),
                                 ref_lockdown))

tnr_lockdown_free_k <- sapply(
  list_res_free_k$lockdown,
  function(e) caret::specificity(factor(get_results(e)$outlier),
                                 ref_lockdown))

tnr_lockdown_fixed_k <- sapply(
  list_res_fixed_k$lockdown,
  function(e) caret::specificity(factor(get_results(e)$outlier),
                                 ref_lockdown))

## results for 'relapse' scenario
ref_relapse <- rep(c(FALSE, TRUE), c(duration - 7, 7))
ref_relapse <- factor(ref_relapse, levels = c(FALSE, TRUE))

tpr_relapse_free_k <- sapply(
  list_res_free_k$relapse,
  function(e) caret::sensitivity(factor(get_results(e)$outlier),
                                 ref_relapse))

tpr_relapse_fixed_k <- sapply(
  list_res_fixed_k$relapse,
  function(e) caret::sensitivity(factor(get_results(e)$outlier),
                                 ref_relapse))

tnr_relapse_free_k <- sapply(
  list_res_free_k$relapse,
  function(e) caret::specificity(factor(get_results(e)$outlier),
                                 ref_relapse))

tnr_relapse_fixed_k <- sapply(
  list_res_fixed_k$relapse,
  function(e) caret::specificity(factor(get_results(e)$outlier),
                                 ref_relapse))













# ================================
# ==== MAYBE OF USE FOR LATER ====
# ================================

# Some optional thoughts on how to add reporting to the data

## Add reporting effects to a set of epi trajectories
## `x` is a `projections` object
## `f` is a function generating reporting 'n' onset -> reporting delays
## Note: this is getting very slow for large numbers of cases!
add_reporting <- function(x, f) {
  lapply(1:ncol(x), function(i) {
    sim_as_dates <- rep(get_dates(x), x[, i])
    out <- incidence::incidence(sim_as_dates + f(length(sim_as_dates)))
    as.data.frame(out)
  })
}


f_reporting <- function(n) rpois(n, lambda = 2)
list_data <- lapply(list_res, add_reporting, f_reporting)
