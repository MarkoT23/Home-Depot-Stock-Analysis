library(forecast)
library(tseries)
library(quantmod)
library(fGarch)

#Stock data for Home Depot (HD)
getSymbols("HD", from ="2020-01-01", to = "2024-01-01")
hd_data <- Cl(HD)
plot(hd_data, main="Adjusted Closing Price of Home Depot", ylab="Price", xlab="Date")

#ADF test to check for stationarity
adf_test_result <- adf.test(hd_data)
print(adf_test_result)

#Lowess Smoothing
lw <- lowess(time(hd_data), hd_data, f = 2/3)
plot(time(hd_data), hd_data, main = "Lowess Smoothing", ylab = "Adjusted Closing Price", xlab = "Time")
lines(lw, col = "red")

#Moving Average Smoothing (50-period window)
MoA50 <- filter(hd_data, filter = rep(1/50, 50), sides = 2)
lines(time(hd_data), MoA50, col = "blue", lty = 2)

#Fit a 2nd order polynomial trend model
time_var <- as.numeric(time(hd_data))
trend_model <- lm(hd_data ~ time_var + I(time_var^2))
summary(trend_model)
plot(time(hd_data), hd_data, main = "Data with Fitted Trend", ylab = "Adjusted Closing Price", xlab = "Time")
lines(time(hd_data), fitted(trend_model), col = "blue", lwd = 2)

#Residuals from the trend model
residuals <- ts(residuals(trend_model), frequency = frequency(hd_data))

#Test for stationarity of the residual series
plot.ts(residuals, main="Residuals from Trend Model")
adf_test_residuals <- adf.test(residuals)
print(adf_test_residuals)

#Check ACF and PACF for ARMA model order
acf(residuals) #Check ACF for AR component
pacf(residuals) #Check PACF for MA component

#Use a grid search to find the optimal ARMA model
best.order <- c(0, 0, 0)
best.aic <- Inf
for (i in 0:2) {
  for (j in 0:2) {
    fit.aic <- AIC(arima(residuals, order = c(i, 0, j)))
    if (fit.aic < best.aic) {
      best.order <- c(i, 0, j)
      best.arma <- arima(residuals, order = best.order)
      best.aic <- fit.aic
    }
  }
}

print(best.order)
print(best.aic)

#Fit ARMA model with best order
arma_model <- Arima(residuals, order = best.order)  #Use the best order found
arma_forecast <- forecast(arma_model, h = 10)
print(arma_forecast)

#Combine trend and ARMA forecasts
trend_forecast <- predict(trend_model, newdata = data.frame(time_var = max(time_var) + 1:10))
combined_forecast <- trend_forecast + arma_forecast$mean

#Plot the forecasted data
#Convert the data in Zoo object into a vector
test <- coredata(hd_data)

#Create a time sequence for the x-axis
time <- seq(as.Date('2020-01-01'), as.Date('2024-01-01'), by = "days")

#Plot the actual data
plot(time[1:length(test)], test, 
     xlim = range(time), 
     ylim = range(c(test, combined_forecast)), 
     main = "Data with Fitted Trend and Forecast", 
     ylab = "Adjusted Closing Price", 
     xlab = "Time", 
     lwd = 2, 
     type = 'l')

#Add the forecasted values
forecast_time <- seq(time[length(test)] + 1, by = "days", length.out = length(combined_forecast))
lines(forecast_time, combined_forecast, col = "purple", lwd = 2)
combined_upper <- trend_forecast + arma_forecast$upper[,2]
combined_lower <- trend_forecast + arma_forecast$lower[,2]
lines(forecast_time, combined_upper, col = "purple", lwd = 2, lty = 2)
lines(forecast_time, combined_lower, col = "purple", lwd = 2, lty = 2)

#Legend creator
legend("bottomright", legend = c("Home Depot Closing Price", "Forecast", "Upper CI", "Lower CI"), 
       col = c("black", "purple", "purple", "purple"), 
       lty = c(1, 1, 2, 2), 
       lwd = 2)

#Alternative GARCH analysis

#Calculate log returns
returns <- diff(log(hd_data)) * 100  #Calculate log returns
returns <- na.omit(returns)  #Remove NA values

#Fit a GARCH(1,1) model
garch_model <- garchFit(~ garch(1, 1), data = returns, trace = FALSE)

#Display the summary of the model
summary(garch_model)

#Forecasting the next 10 days
garch_forecast <- predict(garch_model, n.ahead = 10)

#Print GARCH forecasted values
print(garch_forecast)