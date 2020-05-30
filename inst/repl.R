# ALL WIP and just tinkering with ideas

library(tidyverse)
pathway_data <- tempfile()
download.file("https://github.com/thibautjombart/epichange/blob/994cc7d211a5473b1b27bcf7c7159aee1c14dcbd/factory/data/rds/pathways_latest.rds?raw=true", pathway_data)
pathway_data <- readRDS(pathway_data)
pathway_data <- as_tibble(pathway_data) %>%
  mutate(weekday = as.factor(weekdays(date))) %>%
  mutate(date = as.numeric(date))

global_ts <- pathway_data %>%
  group_by(date, weekday) %>%
  summarise(count = sum(count)) %>%
  ungroup()

zero_count_ts <- tibble(
  date = seq(min(global_ts$date), max(global_ts$date), 1),
  count = 0
)

# the first step is to find a good model to monitor your time series
# here we define a number of models we want to evaluate
model_constant <- lm_model(count ~ 1)
model1 <- glm_model(count ~ 1 + date, poisson())
model2 <- lm_model(count ~ 1 + date)
model3 <- lm_model(count ~ 1 + date + I(weekday %in% c("Saturday", "Sunday")))
#model4 <- brms_model(
#  count ~ 1 + date + I(weekday %in% c("Saturday", "Sunday")) + I(weekday %in% c("Monday")),
#  brms::negbinomial(),
#  chains = 1
#)
model4 <- glm_nb_model(count ~ 1 + date + I(weekday %in% c("Saturday", "Sunday")) + I(weekday %in% c("Monday")))

models <- list(
  null = model_constant,
  glm_poisson = model1,
  lm_trend = model2,
  lm_weekdays = model3,
  glm_negbin = model4
)

# now we need to think about what part of the time series is representative
# for the current trend
# In this example we are interested in monitoring the last 7 days
# and training the model on the last 30 - 7 days. I.e. we assume
# days 30 to 8 can be used to predict the cases in days 7 to 1.
cut_df <- function(df, from, to = -Inf) {
  filter(df, date >= max(date) - !!from, date <= max(date) - !!to)
}
training_data <- cut_df(global_ts, 40, 8)
monitoring_data <- cut_df(global_ts, 7)
library(yardstick)

# the ... are passed to the evaluation function
auto_fit <- select_model(training_data, models, evaluate_resampling, metrics = list(rmse), v = 10, repeats = 10)
auto_fit$leaderboard

best_model <- auto_fit$best_model
trained_best_model <- best_model$train(training_data)
result <- detect_outliers(monitoring_data, trained_best_model) %>%
  bind_rows(training_data)


ggplot(result, aes(x = date, y = count)) +
  geom_point() +
  geom_ribbon(aes(y = pred, ymin = lower, ymax = upper), alpha = 0.3)


# we assume the best model for the aggregate data is also the best for subsets
stratified_monitoring <- pathway_data %>%
  group_by(age) %>%
  do({
    data <- .
    ts <- data %>%
      group_by(date, weekday) %>%
      summarise(count = sum(count)) %>%
      ungroup()
    ts <- zero_count_ts %>% # hacky way to fill in the gaps with 0
      left_join(ts, by = "date") %>%
      mutate(count = count.x + ifelse(is.na(count.y), 0, count.y))

    training_data <- cut_df(ts, 40, 8)
    monitoring_data <- cut_df(ts, 7)
    trained_best_model <- best_model$train(training_data)
    detect_outliers(monitoring_data, trained_best_model) %>%
      bind_rows(training_data) %>%
      arrange(date)
  })

ggplot(stratified_monitoring, aes(x = date, y = count)) +
  geom_point(aes(color = classification)) +
  geom_ribbon(aes(y = pred, ymin = lower, ymax = upper), alpha = 0.3) +
  facet_wrap(~age)

# we could also do model selection for each group
stratified_monitoring <- pathway_data %>%
  group_by(age) %>%
  do({
    data <- .
    ts <- data %>%
      group_by(date, weekday) %>%
      summarise(count = sum(count)) %>%
      ungroup()
    ts <- zero_count_ts %>%
      left_join(ts, by = "date") %>%
      mutate(count = count.x + ifelse(is.na(count.y), 0, count.y))

    training_data <- cut_df(ts, 40, 8)
    monitoring_data <- cut_df(ts, 7)
    auto_fit <- select_model(training_data, models, evaluate_resampling, metrics = list(rmse), v = 10, repeats = 10)
    best_model <- auto_fit$best_model
    trained_best_model <- best_model$train(training_data)
    detect_outliers(monitoring_data, trained_best_model) %>%
      bind_rows(training_data) %>%
      arrange(date)
  })

ggplot(stratified_monitoring, aes(x = date, y = count)) +
  geom_point(aes(color = classification)) +
  geom_ribbon(aes(y = pred, ymin = lower, ymax = upper), alpha = 0.3) +
  facet_wrap(~age) +
  geom_vline(xintercept = max(stratified_monitoring$date) - 7)


# evaluate_resampling(model1, global_ts)
# evaluate_resampling(model2, global_ts)
# evaluate_resampling(model3, global_ts)
# evaluate_aic(model1, global_ts)
# evaluate_aic(model2, global_ts)
# evaluate_aic(model3, global_ts)
#
# x_mtcars <- mtcars
# names(x_mtcars) <- paste0("x_", names(mtcars))
# models <- list(null = model2, glm_gaussian = model1, glm_negbin = model3)
# evaluate_models(models, mtcars)
# evaluate_models(models, x_mtcars, hp = x_hp, cyl = x_cyl)
#
# # find best model
# select_model(models, mtcars, evaluate_aic)
# best_model <- select_model(models, mtcars, evaluate_aic)$model
#
# # detect outliers
# detect_outliers(models, x_mtcars, hp = x_hp, cyl = x_cyl)
# detect_outliers(best_model$train(mtcars), tail(mtcars, 3))
#
#
# # general wrapper: detect trend and k, identify outliers
# epichange(models, mtcars)
# epichange(models, x_mtcars, hp = x_hp, cyl = x_cyl, method = evaluate_aic)
