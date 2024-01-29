
* We import the data

clear

import excel "C:\Users\fcslab18\Downloads\DatasetInflationCrossSection.xls", sheet("FRED Graph") firstrow

keep if Time < 84

generate LCPI = log(CPI)
generate LER = log(ER)


***  we label the countries. 
label define countrylabel 1 "Argentina" 2 "Brazil" 3 "Chile" 4 "Colombia"
label value Country countrylabel


tab Country


*** we generate the dummies
tabulate Country, generate(c)

rename c1 Argentina
rename c2 Brazil
rename c3 Chile
rename c4 Colombia

numdate mo data  = Date, pattern(YM)

**** We visualize our data

xtset Country data

histogram Inflation, by(Country)
xtline Inflation, overlay
xtline Inflation if Argentina < 1, overlay


histogram ERvar, by(Country)
xtline ERvar, overlay

twoway scatter  Inflation ERvar, colorvar(Country) colordiscrete  zlabel(, valuelabel)coloruseplegend   

twoway scatter  Inflation ERvar if Argentina <1, colorvar(Country) colordiscrete  zlabel(, valuelabel)coloruseplegend   



****** We visualize the logarithms of original variables 


histogram LCPI, by(Country)
xtline LCPI, overlay

generate DifLCPI = d.LCPI
generate DifLER = d.LER

histogram DifLCPI, by(Country)
xtline DifLCPI, overlay

histogram DifLER, by(Country)
xtline DifLER, overlay


twoway scatter  DifLCPI DifLER, colorvar(Country) colordiscrete  zlabel(, valuelabel)coloruseplegend   
twoway scatter  DifLCPI DifLER if Argentina< 1, colorvar(Country) colordiscrete  zlabel(, valuelabel)coloruseplegend   

***** Summaries
xtsum Inflation
xtsum ERvar
xtsum DifLCPI
xtsum DifLER


***** We will make different unit root tests. Its important to note that they will differ in their null hypothesis.


***** Levin Lin Chu Test. H0: every series within panels contain a unit root.

xtunitroot llc Inflation
xtunitroot llc ERvar
xtunitroot llc Inflation, lags(4)
xtunitroot llc ERvar, lags(4)
* Breitung unit-root test with 4 lags to prewhiten the series; 
*H0: Panels contain unit roots

xtunitroot breitung Inflation, lags(4)
xtunitroot breitung ERvar, lags(4)
*Im–Pesaran–Shin unit-root test for the demeaned series y.
*H0: All panels contain unit roots         
*Ha: Some panels are stationary

xtunitroot ips Inflation, demean
xtunitroot ips ERvar, demean


**** Harris Travaliz.  H0: Panels contain unit roots   
xtunitroot ht Inflation
xtunitroot ht Inflation, trend
xtunitroot ht ERvar
xtunitroot ht ERvar, trend
*Philips–Perron unit-root test of y with 1 lag for prewhitening
*H0: All panels contain unit roots          
*Ha: At least one panel is stationary   

xtunitroot fisher Inflation, pperron lags(1)
xtunitroot fisher ERvar, pperron lags(1)

*** Hadri Lagrange multiplier.  H0: All panels are stationary  
 
xtunitroot hadri Inflation,trend kernel(bartlett)
xtunitroot hadri ERvar,trend kernel(bartlett)



********************************************
*** Lets exclude Argentina 
keep if Argentina <1


***** We will make different unit root tests. Its important to note that they will differ in their null hypothesis.
***** Levin Lin Chu Test. H0: every series within panels contain a unit root.

xtunitroot llc Inflation
xtunitroot llc ERvar
xtunitroot llc Inflation, lags(4)
xtunitroot llc ERvar, lags(4)
* Breitung unit-root test with 4 lags to prewhiten the series; 
*H0: Panels contain unit roots

xtunitroot breitung Inflation, lags(4)
xtunitroot breitung ERvar, lags(4)
*Im–Pesaran–Shin unit-root test for the demeaned series y.
*H0: All panels contain unit roots         
*Ha: Some panels are stationary

xtunitroot ips Inflation, demean
xtunitroot ips ERvar, demean


**** Harris Travaliz.  H0: Panels contain unit roots   
xtunitroot ht Inflation
xtunitroot ht Inflation, trend
xtunitroot ht ERvar
xtunitroot ht ERvar, trend
*Philips–Perron unit-root test of y with 1 lag for prewhitening
*H0: All panels contain unit roots          
*Ha: At least one panel is stationary   

xtunitroot fisher Inflation, pperron lags(1)
xtunitroot fisher ERvar, pperron lags(1)

*** Hadri Lagrange multiplier.  H0: All panels are stationary  
 
xtunitroot hadri Inflation,trend kernel(bartlett)
xtunitroot hadri ERvar,trend kernel(bartlett)









