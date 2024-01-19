 ** first, we import the data
 
clear
import excel "C:\Users\fcslab18\Downloads\Week1_Dataset_Inflation.xlsx", sheet("Planilha1") firstrow clear

** we define and set the temporal variable
replace Time = ym(year,month)
format Time %tm
tsset Time

** we label the variables
 label variable CPI   "Consumer price index" 
 label variable TCO   "Official exchange rate" 
 label variable CCL   "Stock market exchange rate"
 label variable MB  "Monetary base" 
 label variable TCOvar   "Official exchange rate var." 
 label variable CCL   "Stock market exchange rate var."
 label variable MB  "Monetary base var." 
 
 ** here, we visualize the variables
 tsline Inflation, yline(0) title("Inflation")
 tsline CPI, yline(0)
 tsline TCO, yline(0)
 tsline MB, yline(0)
 
 ** If we plot together the official and stock market exchange rate, we see that from 2020 they start to diverge. That's because
 
 twoway tsline  TCO || tsline CCL
 twoway tsline  TCO if year < 2020 || tsline CCL if year < 2020, yline(0) 
 twoway tsline  TCO if year > 2019 || tsline CCL if year > 2019, yline(0) 
 twoway tsline  TCOvar || tsline CCLvar  || tsline Inflation
 twoway tsline  TCOvar || tsline MBvar  || tsline Inflation
 * Therefore, we generate a dummy that indicates whether the country has currency restrictions
 generate ExcRestrictions = year > 2019
 
 *I drop the last line because it is an atypical situation (unprecedented depreciation of the currency). 
drop in 84
drop in 83
drop in 1

twoway tsline  TCOvar || tsline CCLvar  || tsline Inflation




***************************************************************
*********** ARIMA over dependent variable *********************
***************************************************************

*** first, we take out the trend of d.Inflation
regress Inflation Time 
predict yhat, xb
gen Inflaton_woTrend = Inflation - yhat
 
*** We check that it is stationary. So, inflation is I(1) 
dfuller  Inflaton_woTrend, regress
twoway tsline Inflaton_woTrend || tsline Inflation

*** plot correlograms 

corrgram Inflaton_woTrend

** we conclude that we have a "detrended" ARIMA 1 0 0 
arima Inflaton_woTrend, arima(1,0,0) 
predict  Inflaton_woTrend_resid, residuals
corrgram Inflaton_woTrend_resid
tsline Inflaton_woTrend_resid

** calculate AIC and BIC
estat ic


** lets compare with other models 
arima Inflaton_woTrend, arima(1,0,1) 
estat ic

arima Inflaton_woTrend, arima(2,0,0) 
estat ic

arima Inflaton_woTrend, arima(1,0,1) 
estat ic


***MODEL 1 *************************
*************************************
*** Dickey fuller test **************
************************************

 dfuller Inflation, regress
 dfuller Inflation, drift regress
 dfuller Inflation, trend regress 
 *controlling by time it is stationary if we take a critical value of 10%. That imply that we should include time in regression
 
 

 dfuller TCOvar, regress
 dfuller CCLvar, regress
 dfuller MBvar, regress
* They all seem to be stationary.


 * we define the following model and start pruning
 
 regress Inflation CCLvar TCOvar MBvar l.Inflation ExcRestrictions Time 
 regress Inflation CCLvar TCOvar l.Inflation ExcRestrictions Time 
 regress Inflation TCOvar l.Inflation ExcRestrictions Time 
 
 
 *** we analyse residuals and everything seems to be ok.
 dwstat
 predict residues1, residuals
 
 tsline residues1
 corrgram residues1


 ***MODEL 2 *************************
*************************************
*** Dickey fuller test **************
************************************
 
 
 ** we take logarithms of the variables that are not perc. variations
 generate LogCPI = log(CPI)
 generate LogTCO = log(TCO)
 generate LogCCL = log(CCL)
 generate LogMB = log(MB)

dfuller LogCPI, regress
dfuller LogCPI, drift regress
dfuller LogCPI, trend regress

dfuller d.LogCPI, regress
dfuller d.LogCPI, drift regress
dfuller d.LogCPI, trend regress

** seems to be stationary only after taking one dif. and controlling by trend. Thats why we should include time in the regression
	

 dfuller d.LogTCO, regress
  dfuller d.LogMB, regress
  dfuller d.LogCCL, regress
 
** they are all stationary after taking one dif.

* we define the following model and start pruning
 regress d.LogCPI d.LogTCO d.LogCCL d.LogMB Time L.d.LogCPI ExcRestrictions
 regress d.LogCPI d.LogTCO d.LogCCL Time L.d.LogCPI ExcRestrictions
 regress d.LogCPI d.LogTCO Time L.d.LogCPI ExcRestrictions

** the results are consistent with the previous model








