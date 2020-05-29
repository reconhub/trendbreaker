# build model, train & predict
model <- glm_model(mpg ~ 1, gaussian())
fit <- model$train(mtcars)
fit$predict(mtcars)


# evaluate different models
model1 <- glm_model(hp ~ 1 + cyl, gaussian())
model2 <- lm_model(hp ~ 1)
model3 <- glm_nb_model(hp ~ 1 + cyl)

evaluate_resampling(model1, mtcars)
evaluate_resampling(model2, mtcars)
evaluate_resampling(model3, mtcars)
evaluate_aic(model1, mtcars)
evaluate_aic(model2, mtcars)
evaluate_aic(model3, mtcars)

x_mtcars <- mtcars
names(x_mtcars) <- paste0("x_", names(mtcars))
models <- list(null = model2, glm_gaussian = model1, glm_negbin = model3)
evaluate_models(models, mtcars)
evaluate_models(models, x_mtcars, hp = x_hp, cyl = x_cyl)

# find best model
select_model(models, mtcars, evaluate_aic)
best_model <- select_model(models, mtcars, evaluate_aic)$model

# detect outliers
detect_outliers(model1$train(mtcars), x_mtcars, hp = x_hp, cyl = x_cyl)
detect_outliers(best_model$train(mtcars), tail(mtcars, 3))

# general wrapper: detect trend and k, identify outliers
epichange(models, mtcars)
epichange(models, x_mtcars, hp = x_hp, cyl = x_cyl, method = evaluate_aic)
