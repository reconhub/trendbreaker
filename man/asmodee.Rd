% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/epichange.R
\name{asmodee}
\alias{asmodee}
\title{Automatic Selection of Models Outlier DEtection for Epidemics (ASMODEE)}
\usage{
asmodee(
  data,
  models,
  alpha = 0.05,
  max_k = 7,
  fixed_k = NULL,
  method = evaluate_resampling,
  ...
)
}
\arguments{
\item{data}{A \code{data.frame} or a \code{tibble} containing the response and
explanatory variables used in the \code{models}.}

\item{models}{A list of \url{epichange_model} objects,
generated by \code{lm_model}, \code{glm_model}, \code{glm_nb_model}, \code{brms_model} and
similar functions (see \code{?epichange_model}) for details.}

\item{alpha}{The alpha threshold to be used for the prediction interval
calculation; defaults to 0.05, i.e. 95\% prediction intervals are
calculated.}

\item{max_k}{An \code{integer} indicating the maximum number of recent data points
to be excluded from the trend fitting procedure. By default, ASMODEE will
look for a changepoint within this recent time period, after which data no
longer fit the previous trend. Larger values will require more computation
from the method. Only used if \code{fixed_k} is \code{NULL}.}

\item{fixed_k}{An optional \code{integer} indicating the number of recent data points to be
excluded from the trend fitting procedure. Defaults to \code{NULL}, in which
case ASMODEE detects \code{k} automatically, at the expense of computational
time.}

\item{method}{A function used to evaluate model fit. Current choices are
\code{evaluate_resampling} (default) and \code{evaluate_aic}. \code{evaluate_resampling}
uses cross-validation and RMSE to assess model fit. \code{evaluate_aic} uses
Akaike's Information Criterion instead, which is faster but possibly less
good a selecting models with the best predictive power.}

\item{...}{Further arguments passed to \code{method}.}
}
\value{
An \code{epichange} object (S3 class inheriting \code{list}), containing items
which can be accessed by various accessors - see \code{?epichange-accessors}
}
\description{
This function implements an algorithm for epidemic time series analysis in
aim to detect recent deviation from the trend followed by the data. Data is
first partitioned into 'recent' data, using the last \code{k} observations as
supplementary individuals, and older data used to fit the
trend. Trend-fitting is done by fitting a series of user-specified models for
the time series, with different methods for selecting best fit (see details,
and the argument \code{method}). The prediction interval is then calculated for
the best model, and every data point (including the training set and
supplementary individuals) falling outside are classified as 'outliers'. The
value of \code{k} can be fixed by the user, or automatically selected to minimise
outliers in the training period and maximise and the detection of outliers in
the recent period.
}
\details{
Automatic model selection is used to determine the model best
fitting the training data from a list of user-provided models. First, all
models are fitted to the data. Second, models are selected using the
approach specified by the \code{method} argument. The default,
\url{evaluate_resampling}, uses cross-validation
(10-fold by default) and root mean squared error (RMSE) to assess model
fit. This approach is likely to select models with good predictive
abilities, but is computationally intensive. The alternative is using
\url{evaluate_aic}, which uses Akaike's Information Criteria to
assess model fit penalised by model complexity. This approach is fast, but
only measures model fit rather than predictive ability.
}
\examples{

if (require(cowplot) && require(tidyverse)) {
  # load data
  data(nhs_pathways_covid19)

  # select last 28 days
  first_date <- max(nhs_pathways_covid19$date, na.rm = TRUE) - 28
  pathways_recent <- nhs_pathways_covid19 \%>\%
    filter(date >= first_date)
  
  # define candidate models
  models <- list(
    regression = lm_model(count ~ day),
    poisson_constant = glm_model(count ~ 1, family = "poisson"),
    negbin_time = glm_nb_model(count ~ day),
    negbin_time_weekday = glm_nb_model(count ~ day + weekday)
  )

  # analyses on all data
  counts_overall <- pathways_recent \%>\%
    group_by(date, day, weekday) \%>\%
    summarise(count = sum(count))

  # results with automated detection of 'k'
  res_overall <- asmodee(counts_overall, models, method = evaluate_aic)
  res_overall
  plot(res_overall, "date")

  # results with fixed value of 'k' (7 days)
  res_overall_k7 <- asmodee(counts_overall, models, fixed_k = 7)
  plot(res_overall_k7, "date")

  # analyses by NHS regions
  counts_nhs_region <- pathways_recent \%>\%
    group_by(nhs_region, date, day, weekday) \%>\%
    summarise(count = sum(count)) \%>\%
    complete(date, fill = list(count = 0)) \%>\% 
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

}
}
\author{
Thibaut Jombart and Dirk Schumacher, with input from Michael Höhle,
Mark Jit, John Edmunds, Andre Charlett
}