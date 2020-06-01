
library(tidyverse)
library(devtools)
load_all()

# download data
pathways <- tempfile()
download.file("https://github.com/qleclerc/nhs_pathways_report/raw/master/data/rds/pathways_latest.rds", pathways)
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
  mutate(nhs_region = stringr::str_to_title(gsub("_", " ", nhs_region)),
         nhs_region = gsub(" Of ", " of ", nhs_region),
         nhs_region = gsub(" And ", " and ", nhs_region),
         day = as.integer(date - min(date, na.rm = TRUE)),
         weekday = day_of_week(date))

first_date <- max(pathways$date, na.rm = TRUE) - 28
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


## results with automated detection of 'k'
res_overall <- asmodee(counts_overall, models, method = evaluate_aic)
plot(res_overall, "date")

# results with fixed value of 'k' (7 days)
res_overall_k7 <- asmodee(counts_overall, models, fixed_k = 7)
plot(res_overall_k7, "date")


## analyses by NHS regions
counts_nhs_region <- pathways_recent %>%
  group_by(nhs_region, date, day, weekday) %>%
  summarise(count = sum(count)) %>%
  complete(date, fill = list(count = 0)) %>% 
  split(.$nhs_region)

res_nhs_region <- lapply(counts_nhs_region,
                         asmodee,
                         models,
                         method = evaluate_aic,
                         alpha = 0.05)

plots_nhs_region <- lapply(seq_along(res_nhs_region),
                           function(i)
                             plot(res_nhs_region[[i]], "date", point_size = 1, guide = FALSE) +
                               labs(subtitle = names(res_nhs_region)[i], x = NULL))
cowplot::plot_grid(plotlist = plots_nhs_region)






## analyses by CCG
## note: this takes about 1 minute to run with AIC model selection,
## areound 16-17 min with cross validation
counts_ccg <- pathways_recent %>%
  group_by(ccg_name, date, day, weekday) %>%
  summarise(count = sum(count)) %>%
  complete(date, fill = list(count = 0)) %>% 
  split(.$ccg_name)

res_ccg <- lapply(counts_ccg,
                  asmodee,
                  models,
                  method = evaluate_aic,
                  alpha = 0.05)


## here we can select results to display as we want: based on low p-values, a
## fixed number of outliers, a value of k, ...

ccg_stats <- lapply(res_ccg, function(e)
  data.frame(
    p_value = e$p_value,
    k = e$k,
    n_outliers_recent = e$n_outliers_recent,
    n_outliers = e$n_outliers)) %>%
  bind_rows(.id = "ccg") %>%
  arrange(desc(n_outliers_recent),
          desc(k))

ccg_stats %>%
  mutate(p_value = format.pval(p_value, digits = 3)) %>% 
  DT::datatable(ccg_stats, rownames = FALSE)


## display all CCGs with at least one recent
top_ccg <- ccg_stats %>%
  pull(ccg) %>%
  head(12)

res_ccg_top <- res_ccg[top_ccg]
plots_ccg_top <- lapply(seq_along(res_ccg_top),
                           function(i)
                             plot(res_ccg_top[[i]], "date", point_size = 1, guide = FALSE) +
                               labs(subtitle = names(res_ccg_top)[i]))
cowplot::plot_grid(plotlist = plots_ccg_top)


