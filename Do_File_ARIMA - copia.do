*prepare your workspace
clear all
set more off
set seed 1234

*import yor database into stata
import excel "\\user\your store\LIBOR.xlsx", sheet("Sheet1") cellrange(A1:C244) firstrow

*set time for time series analysis
gen time=tm(2003m12)+_n-1
tsset time, monthly

*test for stationarity of the variable
*for p-values larger than the confidence bracket, there's enough proof to say that the variable is not stationary (it has unit root)
dfuller LIBOR, regress
pperron LIBOR, regress

*usually, the first order differentiation of the variable solves the non-stationarity problem
*differenciate until p-value are less than the confidence band (in this case, just once)
*this means that the I specification for the ARIMA takes the value of 1 (one diff)
dfuller D.LIBOR, regress
pperron D.LIBOR, regress

*to find the correct specification, you must have to graph autocorrelation (MA) and partial autocorrelation (AR)
*You have to control for lags that are taller than the confidence band values and make a possible specification candidates 
*in the example we have five lags por MA that fell beyond the gray band (the confidence band) and two lags for AR
corrgram D.LIBOR, lags(20)
ac D.LIBOR, lags(20)
pac D.LIBOR, lags(20)

*once you have your specification candidates, you have to choose the one that performs better in terms significance
*at this stage, controls under log-likelihood, AIC, BIC and sigmasq criteria for every specification 
arima LIBOR, noconstant arima(1,1,1)
estat ic
arima LIBOR, noconstant arima(1,1,2)
estat ic
arima LIBOR, noconstant arima(1,1,3)
estat ic
arima LIBOR, noconstant arima(1,1,5)
estat ic
arima LIBOR, noconstant arima(1,1,4)
estat ic
arima LIBOR, noconstant arima(2,1,1)
estat ic
arima LIBOR, noconstant arima(2,1,2)
estat ic
arima LIBOR, noconstant arima(2,1,3)
estat ic
arima LIBOR, noconstant arima(2,1,4)
estat ic
arima LIBOR, noconstant arima(2,1,5)
estat ic

*under this specification-choose criteria, the ARIMA (1,1,1) have better performance for our example
arima LIBOR, noconstant arima(1,1,1)
estat ic

*stability of the ARIMA (1,1,1)
*first we have to cuantify our error term
predict error1, resid
summarize error1

*above done, graph the error against the median of the summarize error output (in this case 0.0068108)
*theory stays that, if the parameters capts well portion of movement of the variable, the error cannot be beyond +-0.2 on the y axis
tsline error1, yline(0.0068108)

*Next perform the portmanteau test
wntestq error1

*finally but nontheless, perform the unit circle test
*all parameters need to fall inside the unit circle
estat aroots

*estimate for 12 months beyond
tsappend, add(12)
predict fLIBOR1, y dynamic(m(2023m11))
label variable fLIBOR1 "Forecasted LIBOR"
*graph the estimation against the observed data
tsline LIBOR fLIBOR1

*estimate outputs
arima LIBOR, noconstant arima(1,1,1)
browse
