
library(tidyverse)
devtools::load_all()

# download data
pathways <- tempfile()
download.file("https://github.com/thibautjombart/epichange/blob/994cc7d211a5473b1b27bcf7c7159aee1c14dcbd/factory/data/rds/pathways_latest.rds?raw=true", pathways)
pathways <- readRDS(pathways)


# add variables and subsets
day_of_week <- function(date) {
  day_of_week <- weekdays(date)
  out <- dplyr::case_when(
    day_of_week %in% c("Saturday", "Sunday") ~ "weekend",
    day_of_week %in% c("Monday") ~ "monday",
    TRUE ~ "rest_of_week"
  )
  out <- factor(out, levels = c("rest_of_week", "monday", "weekend"))
  out
}

pathways <- as_tibble(pathways) %>%
  mutate(nhs_region = str_to_title(gsub("_"," ",nhs_region)),
         nhs_region = gsub(" Of ", " of ", nhs_region),
         nhs_region = gsub(" And ", " and ", nhs_region),
         day = as.integer(date - min(date, na.rm = TRUE)),
         weekday = day_of_week(date))

first_date <- Sys.Date() - 28
pathways_recent <- pathways %>%
  filter(date >= first_date)



# define candidate models
models <- list(
  regression = lm_model(count ~ day),
  poisson_constant = glm_model(count ~ 1, family = "poisson"),
  negbin_time = glm_nb_model(count ~ day),
  negbin_time_weekday = glm_nb_model(count ~ day + weekday)
  )


# analyses on all data
counts_overall <- pathways_recent %>%
  group_by(date, day, weekday) %>%
  summarise(count = sum(count))


res_overall <- epichange(counts_overall, models, method = evaluate_aic)

plot(res_overall, "day")
# For Tibo to fix; also fix value of "k" and its display
# plot(res_overall, "date")



# run analyses by NHS regions
counts_nhs_region <- pathways_recent %>%
  group_by(nhs_region, date, day, weekday) %>%
  summarise(count = sum(count)) %>%
  split(.$nhs_region)

res_nhs_region <- lapply(counts_nhs_region,
                         epichange,
                         models,
                         method = evaluate_aic,
                         alpha = 0.05)

plots_nhs_region <- lapply(seq_along(res_nhs_region),
                           function(i)
                             plot(res_nhs_region[[i]], "date", point_size = 1, guide = FALSE) +
                               labs(subtitle = names(res_nhs_region)[i]))
cowplot::plot_grid(plotlist = plots_nhs_region)
