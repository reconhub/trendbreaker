model <- glm_model(mpg ~ 1, gaussian())
fit <- model$train(mtcars)
fit$predict(mtcars)


model1 <- glm_model(hp ~ 1 + cyl, gaussian())
model2 <- lm_model(hp ~ 1)
model3 <- glm_nb_model(hp ~ 1 + cyl)
model$train(mtcars)$predict(mtcars)
evaluation_resampling(model1, mtcars)
evaluation_resampling(model2, mtcars)
evaluation_resampling(model3, mtcars)
evaluation_aic(model1, mtcars)
evaluation_aic(model2, mtcars)
evaluation_aic(model3, mtcars)



# monitor(model, data)

# monitor(model3, new_data) =>

# monitor on many time series

# functions to evaluate the monitoring system
