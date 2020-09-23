
version 0.2.0 (23 September 2020)
----------------------------

### Fixes

* fixed an issue in argument names coming from an API change in
  `ciTools::add_pi`



version 0.1.0 (10 June 2020)
----------------------------

This is the first release of the package, after renaming from a temporary name
*epichange*. Some elements of the API may change, but core functionalities are
available and documented. 


### Main features

* `asmodee`: implements the Automatic Selection of Models and Outlier DEtection
for Epidemics

* `evaluate_models`: a function to compare different models using
cross-validation or goodness-of-fit criteria

* `select_model`: a function to select the
best-fitting/best-predicting model from a range of user-specified
models

* `detect_changepoint`: a function to detect the points at which
recent data deviate from previous temporal trends using a fitted
model and data

* `detect_outliers`: a function to identify outliers using a fitted
model and data


