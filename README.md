# CDLoanForecasting
Create forecasts for 12 branches of a Cooperative
June 01, 2016 Univariate Time Series Forecasting by Thomas Pfeiffer

# Introduction: goal of the mission
"El requerimiento consiste  en sacar un listado histórico desde enero de 2009 a junio de 2016 de los ítems que se muestran en la primera fila, para todas las agencias y el total general.Necesitaríamos que se haga con este formato para poder trabajar las proyecciones del 2017. Muchas Gracias"

# Forecasts for FY 2017 are needed for the balance of CDs and Loans basded on historical data.
Since the forecast requested is 18 periods in the future, it was acknowledged that the forecasts will be inaccurate. A basic ARIMA model is what was previously used to forecast for 2016, and management has requested an ARIMA model for 2017 as well. 

The historical data is from 10-31-2012 to 6-30-2016, and includes monthly data of 45 periods. The data exhibits a trend, and because of the limited data, a seasonal component cannot be determined. Therefore it seems that a time series model with trend is most appropriate.

Cross validation is a great way to select appropriate models, but because of the limited data and the growth shifts of the data, cross validation will not be used to select a model, and instead arima and exponential smoothing models will be combined to create forecasts.
