# CDLoanForecasting
Create forecasts for 12 branches of a Cooperative
June 01, 2016 Univariate Time Series Forecasting by Thomas Pfeiffer

## Introduction: goal of the mission
"El requerimiento consiste  en sacar un listado histórico desde enero de 2009 a junio de 2016 de los ítems que se muestran en la primera fila, para todas las agencias y el total general.Necesitaríamos que se haga con este formato para poder trabajar las proyecciones del 2017. Muchas Gracias"

## Forecasts for FY 2017 are needed for the balance of CDs and Loans basded on historical data.
Since the forecast requested is 18 periods in the future, it was acknowledged that the forecasts will be inaccurate. A basic ARIMA model is what was previously used to forecast for 2016, and management has requested an ARIMA model for 2017 as well. 

The historical data is from 10-31-2012 to 6-30-2016, and includes monthly data of 45 periods. The data exhibits a trend, and because of the limited data, a seasonal component cannot be determined. Therefore it seems that a time series model with trend is most appropriate.

Cross validation is a great way to select appropriate models, but because of the limited data and the growth shifts of the data, cross validation will not be used to select a model, and instead arima and exponential smoothing models will be combined to create forecasts. Cross validation can be done with the holdout method or K-fold cross validation.

### ARIMA
Use ARIMA when the primary component of this year's data is last year's data. The ARIMA process uses regression/correlation statistics to identify the stochastic patterns in the data. 
Once we have a stationary time series, we must ask two questions:
#1. is it an AR or MA process?
  AR(1) model is represented by a spike in autocorrelation followed by a gradual decrease
  In MA models, the autocorrelation quickly drops off, not gradually like the AR model
#2. what order of AR or MA process do we need to use?
  #AR(1) formulation: x(t) = alpha * x(t-1) + error(t)
  #MA formulation: x(t) = beta * error(t-1) + error(t)

#MAKE DATA STATIONARY
#Differencing is commonly the process of subtracting all data points from the previous: y(t) - y(t-1). A stationary time series is one whose statistical properties such as mean, variance, etc. are constant over time. The mean can not change over time (trend), the variance can not change over time (spread)
Unit root tests for stationarity: KPSS, Augmented Dickey-Fuller, Phillips-Perron
