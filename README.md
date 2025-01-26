# Home-Depot-Stock-Analysis
### NOTICE: The following work is the original creation of Marko Tyhansky and is not permitted for use without consent of original author.
A time series analysis of Home Depot stock implementing the Box-Jenkins method using R. Topics covered include but are not limited to:
### 1. Model Identification: 
Check stationarity of the time series.
Differencing the series (if needed) to achieve stationarity.
Identify potential values for the AR (p), MA (q), and differencing (d) components using tools like:
Autocorrelation Function (ACF).
Partial Autocorrelation Function (PACF).
### 2. Parameter Estimation
Select initial model parameters (p, d, q).
Estimate coefficients for AR and MA components.
Use methods such as:
Maximum Likelihood Estimation (MLE).
Least Squares Method.
Optimize model fit using criteria like:
Akaike Information Criterion (AIC).
Bayesian Information Criterion (BIC).
### 3. Diagnostic Checking
Check residuals for randomness (white noise).
Perform statistical tests like:
Ljung-Box Test for independence.
Examine residuals using:
ACF of residuals.
Histogram or Q-Q plot for normality.
Refine the model if diagnostics reveal inadequacies.
### 4. Forecasting
Generate forecasts using the final model.
Calculate confidence intervals for predictions.
Evaluate forecast accuracy with metrics like:
Mean Absolute Error (MAE).
Mean Squared Error (MSE).
