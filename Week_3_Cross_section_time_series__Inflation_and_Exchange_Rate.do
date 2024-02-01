
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


*** first model
reg Inflation l.Inflation l2.Inflation ERvar l.ERvar l2.ERvar 
estat ic
predict u_hat, e 
xtline u_hat
reg u_hat l.u_hat l.Inflation l2.Inflation ERvar l.ERvar l2.ERvar 


****************
drop u_hat
reg Inflation l.Inflation l2.Inflation l3.Inflation ERvar l.ERvar l2.ERvar l3.ERvar
estat ic
predict u_hat, residuals
xtline u_hat

reg u_hat l.u_hat l.Inflation l2.Inflation l3.Inflation ERvar l.ERvar l2.ERvar l3.ERvar
twoway (scatter u_hat l.Inflation)  (lfit u_hat l.Inflation)

actest u_hat
xtcd2 u_hat
hettest u_hat
****************************** define particular dslopes for Argentina and Argentina during currency restrictions


generate ERArg = ERvar*Argentina
generate ERRest = 0
replace ERRest = 1 if data > tm(2019m11) & Country == 1



gen  ERArg_Restrictions = ERRest*ERvar


reg Inflation l.Inflation l2.Inflation ERvar l.ERvar l2.ERvar  ERArg l.ERArg l2.ERArg  ERArg_Restrictions l.ERArg_Restrictions l2.ERArg_Restrictions
estat ic


predict u_hat2, residuals
xtline u_hat2

reg u_hat2 l.u_hat2  l.Inflation l2.Inflation ERvar l.ERvar l2.ERvar  ERArg l.ERArg l2.ERArg  ERArg_Restrictions l.ERArg_Restrictions l2.ERArg_Restriction

*** pruned model with interactions

reg Inflation l.Inflation l2.Inflation  ERArg l.ERArg l2.ERArg  ERArg_Restrictions l.ERArg_Restrictions
estat ic


drop u_hat2

predict u_hat2, residuals
xtline u_hat2

reg u_hat2 l.u_hat2   l.Inflation l2.Inflation  ERArg l.ERArg l2.ERArg  ERArg_Restrictions l.ERArg_Restrictions


** Generating marginal effects plot

drop ERcat
gen ERcat = 2
replace ERcat = 1 if ERvar < .0131467  - .0414874
replace ERcat = 3 if ERvar > .0131467 + .0414874

ERvar ERRest
reg Inflation ERvar ERRest  ERArg_Restrictions

drop MV conb conse a upper lower
generate MV=ERRest

matrix b=e(b)
matrix V=e(V)
 
scalar b1=b[1,1]
scalar b2=b[1,2]
scalar b3=b[1,3]

scalar varb1=V[1,1]
scalar varb2=V[2,2] 
scalar varb3=V[3,3]

scalar covb1b3=V[1,3] 
scalar covb2b3=V[2,3]

scalar list b1 b2 b3 varb1 varb2 varb3 covb1b3 covb2b3

* This calculates the marginal effect of X on Y:
gen conb=b1+b3*MV

* This calculates the standard error of the estimate of the effect that we just calculated:
gen conse=sqrt(varb1+varb3*(MV^2)+2*covb1b3*MV) 

* This generates the upper and lower bounds although these should be modified according to the
* number of degrees of freedom if you do not have as many as we have in this model:
gen a=1.96*conse
 
gen upper=conb+a
 
gen lower=conb-a

* Now for the graph:

sort MV
graph twoway rarea upper lower MV /*
*/    || line conb   MV /*
*/    ||   ,   /*
*/             legend(col(1) order(1 2) label(1 "95% Confidence Interval")  /*
*/                                      label(2 "Marginal Effect of X")) /*
*/             yline(0, lcolor(black))   /*
*/             title("Marginal Effect of Cambio on Y As Z Changes") /*
*/             subtitle(" " "Dependent Variable: Y" " ", size(3)) /*
*/             xtitle(Restriciones) /*
*/             ytitle("Marginal Effect of X", size(3)) 

margins ERcat##Argentina, dydx(Argentina)
marginsplot, yline(0)

line conb   MV 