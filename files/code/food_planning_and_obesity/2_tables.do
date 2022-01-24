********************************************************************************************************************
* Shopping styles and BMI relationships
********************************************************************************************************************
* Administration
set more off, permanently
set scheme s1color

* TOC
global summary_statistics 0
global energy_sugar 0
global regressions 1

* Setting working directory
global Project_dir = "\\Mac\iCloud\Data\foodAPS"

global raw_dir = "$Project_dir\raw"
global dta_dir = "$Project_dir\dta"
global do_dir = "$Project_dir\do"
global pdf_dir = "$Project_dir\figures" 
global tex_dir = "$Project_dir\tex"

* Loading data
use "$dta_dir\working_dataset_fah.dta", clear

* Recoding bmi variable
gen obesity = 0
replace obesity = 1 if bmi >= 30
label variable obesity "Obese (BMI >= 30)"
tab obesity

* Main explanatory variables
tab grocerylistfreq
drop if grocerylistfreq < 0

* Broad categories
label define gro_list 1 "Shops with grocery list: Never" 2 "\textbf{Explanatory variables} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Shops with grocery list: Seldom" 3 "\hspace{2mm} Shops with grocery list: Sometimes" 4 "\hspace{2mm} Shops with grocery list: Most of the time" 5 "\hspace{2mm} Shops with grocery list: Almost always"
label values grocerylistfreq gro_list

/* Narrow categories
gen swgl = 0
replace swgl = 1 if grocerylistfreq == 1
replace swgl = 2 if grocerylistfreq == 5

label define gro_list 0 "Others" 1 "Shops with grocery list: Never" 2 "Shops with grocery list: Almost alwaysMostly" 
label values swgl gro_list
*/

tab primstoretravelmode

tab cash

gen payment = 0
replace payment = 1 if cash == 1
replace payment = 2 if creditcard == 1
replace payment = 3 if check == 1
replace payment = 3 if giftcard == 1

label define pay_type 0 "Other" 1 "Cash" 2 "Creditcard" 3 "Check" 4 "Giftcard"
label values payment pay_type

tab RACECAT_R

gen race = 1 if RACECAT_R == 1
replace race = 2 if RACECAT_R == 2
replace race = 3 if RACECAT_R == 3
replace race = 4 if RACECAT_R == 4
replace race = 5 if race == .
tab race

label define rcat 1 "White" 2 "\textbf{Ethnicity} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Black" 3 "\hspace{2mm} American Indian/Alaska Native" 4 "\hspace{2mm} Asian" 5 "\hspace{2mm} Other ethnicity" 
label values race rcat

* Control variables
gen female = 0 if sex == 1
replace female = 1 if sex == 2
label variable female "\textbf{Individual controls} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Female"
tab female

gen car_pc = vehiclenum/(hhsize*10)
tab car_pc
replace car_pc = 0 if car_pc < 0
label variable car_pc "\hspace{2mm} Number of vehicles per capita/10" 

tab RACECAT 

tab tobacco
replace tobacco = 0 if tobacco == .r | tobacco == .d
label variable tobacco "\hspace{2mm} Smoker"
tab tobacco

tab vegetarian 
label variable vegetarian "\hspace{2mm} Vegetarian"

tab inchhavg_r
replace inchhavg_r = inchhavg_r/1000 /* Adjustment for nicer coefficients */
label variable inchhavg_r "\hspace{2mm} Avg. monthly household income (in 1'000 US\textdollar)"

tab hhsize
label variable hhsize "\textbf{Household controls} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} HH size"

tab AGE_R
label variable AGE_R "\hspace{2mm} Age"
gen AGE_R_2 = AGE_R^2/100
label variable AGE_R_2 "\hspace{2mm} Age^2/100"
tab AGE_R_2

tab educcat

gen educ = 2 if educcat == 3 | educcat == 4
replace educ = 3 if educcat == 5 | educcat == 6
replace educ = 1 if educcat == 1 | educcat == 2 | educ == .
tab educ

label define ecat 0 "Other" 1 "\textbf{Education} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} School, no degree" 2 "\hspace{2mm} High school degree" 3 "\hspace{2mm} University degree" 
label values educ ecat

tab region
tab daynum

gen inc_pc = inchhavg_r/hhsize
label variable inc_pc "\textbf{Household controls} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Avg. monthly income per capita (in 1'000 US\textdollar)"

*hist inc_pc

xtile pct = inc_pc, n(2)
tab pct, gen(inc_quartile)

gen above_pg = 0
replace above_pg = 1 if pctpovguidehh_r >= 100 & pctpovguidehh_r < 200
replace above_pg = 2 if pctpovguidehh_r >= 200

tab above_pg

tab primstoresnaptype

tabstat obesity, stats(mean) by(above_pg)

* Summary statistics
if $summary_statistics == 1 {

gen swgl_never = 0
replace swgl_never = 1 if grocerylistfreq == 1
label variable swgl_never "\hspace{2mm} Shops with grocery list: Never"
gen swgl_seldom = 0
replace swgl_seldom = 1 if grocerylistfreq == 2
label variable swgl_seldom "\hspace{2mm} Shops with grocery list: Seldom"
gen swgl_sometimes = 0
replace swgl_sometimes = 1 if grocerylistfreq == 3
label variable swgl_sometimes "\hspace{2mm} Shops with grocery list: Sometimes"
gen swgl_mott = 0
replace swgl_mott = 1 if grocerylistfreq == 4
label variable swgl_mott "\hspace{2mm} Shops with grocery list: Most of the time"
gen swgl_aa = 0
replace swgl_aa = 1 if grocerylistfreq == 5
label variable swgl_aa "\hspace{2mm} Shops with grocery list: Almost always"

tabstat obesity swgl_never swgl_seldom swgl_sometimes swgl_mott swgl_aa, by(pct) stats(mean p50)

label variable female "\hspace{2mm} Female"
label variable inc_pc "\hspace{2mm} Avg. monthly income per capita (in 1'000 US\textdollar)"
label variable hhsize "\hspace{2mm} Household size (in persons)"


gen white = 0
replace white = 1 if RACECAT_R == 1
label variable white "\hspace{2mm} White"
gen black = 0
replace black = 1 if RACECAT_R == 2
label variable black "\hspace{2mm} Black"
gen asian = 0
replace asian = 1 if RACECAT_R == 4
label variable asian "\hspace{2mm} Asian"
gen other = 0
replace other = 1 if RACECAT_R == 5 | RACECAT_R == 6 | RACECAT_R == 3
label variable other "\hspace{2mm} Other ethnicity"

gen school = 1 if educcat == 1 | educcat == 2
replace school = 0 if school == .
label variable school "\hspace{2mm} School, no degree"
gen high_school = 1 if educcat == 3 | educcat == 4
replace high_school = 0 if high_school == .
label variable high_school "\hspace{2mm} High school degree"
gen uni = 1 if educcat == 5 | educcat == 6
replace uni = 0 if uni == .
label variable uni "\hspace{2mm} University degree"
gen other_educ = 1 if school == 0 & high_school == 0 & uni == 0
replace other_educ = 0 if other_educ == .
label variable other_educ "\hspace{2mm} Other education"

label variable obesity "\hspace{2mm} Obese (BMI >= 30)"

reg obesity swgl_never swgl_seldom swgl_sometimes swgl_mott swgl_aa female tobacco vegetarian AGE_R white black asian other other_educ school high_school uni inchhavg_r inc_pc hhsize car_pc, vce(cluster hhnum)

estpost sum obesity swgl_never swgl_seldom swgl_sometimes swgl_mott swgl_aa female tobacco vegetarian AGE_R white black asian other school high_school uni inchhavg_r inc_pc hhsize car_pc
esttab, replace noisily refcat(obesity "Dependant variable:" swgl_never "Explanatory variables:", /// 
nolabel) cells("mean(label(Mean)fmt(%9.1f)) sd(label(St. Dev.)fmt(1)) min(label(Min.)fmt(1)) max(label(Max.)fmt(1)) count(label(N)fmt(%12.0gc))") ///
label nomtitle nonumber noobs 
esttab using "//Mac/iCloud/Data/foodAPS/tex/summary_statistics.tex", ///
replace noisily refcat(obesity "\textbf{Dependent variable:}" swgl_never "[1em] \textbf{Explanatory variables:}" female "[1em] \textbf{Individual controls:}" white "[1em] \textbf{Ethnicity:}"  school "[1em] \textbf{Education:}" inchhavg_r "[1em] \textbf{Household controls:}", nolabel) ///
cells("mean(label(\textbf{Mean})fmt(2)) sd(label(\textbf{SD})fmt(2)) min(label(\textbf{Min.})fmt(1)) max(label(\textbf{Max.})fmt(1)) count(label(\textbf{N})fmt(%12.0gc))") ///
label nomtitle nonumber noobs booktabs

}
*

* Regressions
if $regressions == 1 {

*keep if primstoresnaptype == "SM" | primstoresnaptype == "SS"

* Label variables
label define gro_list_reg 1 "Shops with grocery list: Never" 2 "\textbf{Explanatory variables} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Shops with grocery list: Seldom" 3 "\hspace{2mm} Shops with grocery list: Sometimes" 4 "\hspace{2mm} Shops with grocery list: Most of the time" 5 "\hspace{2mm} Shops with grocery list: Almost always"
label values grocerylistfreq gro_list_reg

label variable female "\textbf{Individual controls} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Female"
label variable vegetarian "\hspace{2mm} Vegetarian"
label variable tobacco "\hspace{2mm} Smoker"
label variable AGE_R "\hspace{2mm} Age"
label variable AGE_R_2 "\hspace{2mm} Age$^2$/100"

label define ecat_reg 1 "\hspace{2mm} School, no degree" 2 "\textbf{Education} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} High school degree" 3 "\hspace{2mm} University degree" 
label values educ ecat_reg

label define rcat_reg 1 "White" 2 "\textbf{Ethnicity} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} Black" 3 "\hspace{2mm} American Indian/Alaska Native" 4 "\hspace{2mm} Asian" 5 "\hspace{2mm} Other ethnicity" 6 "\hspace{2mm} Multiple ethnicities"
label values RACECAT_R rcat_reg

label variable hhsize "\textbf{Household controls} &&&&& \\ \vspace{1mm} \\ \hspace{2mm} HH size"
label variable inchhavg_r "\hspace{2mm} HH income (in 1'000 US\textdollar)"
label variable car_pc "\hspace{2mm} Number of vehicles per capita/10" 

* Shopping list use
eststo m0: logit obesity i.grocerylistfreq, vce(cluster hhnum) 
eststo m00: margins, dydx(*) post
estadd local place "No"

eststo m1: logit obesity i.grocerylistfreq i.region, vce(cluster hhnum)
eststo m11: margins, dydx(*) post
estadd local place "Yes"

eststo m2: logit obesity i.grocerylistfreq female vegetarian tobacco AGE_R AGE_R_2 i.educ i.region, vce(cluster hhnum)
eststo m22: margins, dydx(*) post
estadd local place "Yes"

eststo m3: logit obesity i.grocerylistfreq female vegetarian tobacco AGE_R AGE_R_2 i.educ i.race i.region, vce(cluster hhnum)
eststo m33: margins, dydx(*) post
estadd local place "Yes"

eststo m4: logit obesity i.grocerylistfreq female vegetarian tobacco AGE_R AGE_R_2 i.educ i.race hhsize inchhavg_r car_pc i.region, vce(cluster hhnum)
eststo m44: margins, dydx(*) post
estadd local place "Yes"

esttab m11 m22 m33 m44 using "//Mac/iCloud/Data/foodAPS/tex/logit_reg_list.tex", ///
b(3) se(3) stats(place N, label("Census region dummy") fmt(0 %12.0gc)) ///
compress nodepvars nonumbers mtitles("(1)" "(2)" "(3)" "(4)" "(5)") ///
varwidth(12) booktabs modelwidth(12) nonotes addnotes("\scriptsize{Clustered standard errors at household level in parentheses. The coefficients report average marginal effects.}" "\scriptsize{\textit{Shops with grocery list: Never} is dropped due to multicollinearity and is the reference group.}" /// 
"\scriptsize{\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)}") ///
label obslast se replace drop(1.educ 1.race *.region 1.grocerylistfreq) ///
mgroups("\textbf{Dependent variable: Obesity dummy (BMI$>=$30)}", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) 

* Shopping list use per income group
global mode "p25 p50 p75 p100"

foreach group in 0 1 2 {

gettoken (global)left (global)mode: (global)mode

eststo m0_`group': logit obesity i.grocerylistfreq if above_pg == `group', vce(cluster hhnum) 
eststo m00_`group': margins, dydx(*) post
estadd local place "No"

eststo m1_`group': logit obesity i.grocerylistfreq i.region if above_pg == `group', vce(cluster hhnum)
eststo m11_`group': margins, dydx(*) post
estadd local place "Yes"

eststo m2_`group': logit obesity i.grocerylistfreq female vegetarian tobacco AGE_R AGE_R_2 i.educ i.region if above_pg == `group', vce(cluster hhnum)
eststo m22_`group': margins, dydx(*) post
estadd local place "Yes"

eststo m3_`group': logit obesity i.grocerylistfreq female vegetarian tobacco AGE_R AGE_R_2 i.educ i.race i.region if above_pg == `group', vce(cluster hhnum)
eststo m33_`group': margins, dydx(*) post
estadd local place "Yes"

eststo m4_`group': logit obesity i.grocerylistfreq female vegetarian tobacco AGE_R AGE_R_2 i.educ i.race hhsize inchhavg_r car_pc i.region if above_pg == `group', vce(cluster hhnum)
eststo m44_`group': margins, dydx(*) post
estadd local place "Yes"

}
*

esttab m00_1 m22_1 m44_1 m00_2 m22_2 m44_2 using "//Mac/iCloud/Data/foodAPS/tex/logit_reg_list_pct.tex", ///
b(3) se(3) stats(place N, label("Census region dummy") fmt(0 %12.0gc)) ///
compress nodepvars nonumbers mtitles("(1)" "(2)" "(3)" "(4)" "(5)") ///
varwidth(12) booktabs modelwidth(12) nonotes addnotes("\scriptsize{Clustered standard errors at household level in parentheses. The coefficients report average marginal effects.}" "\scriptsize{\textit{Shops with grocery list: Never} is dropped due to multicollinearity and is the reference group.}" /// 
"\scriptsize{\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)}") ///
label obslast se replace drop(1.educ 1.race *.region 1.grocerylistfreq) ///
mgroups("\textbf{Dependent variable: Obesity dummy (BMI$>=$30)}", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) 

* Output everything in one table
esttab m11 m22 m33 m44 m44_0 m44_1 m44_2 using "//Mac/iCloud/Data/foodAPS/tex/logit_reg_list_one_table.tex", ///
b(3) se(3) stats(place N, label("Census region dummy") fmt(0 %12.0gc)) ///
compress nodepvars nonumbers mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
varwidth(12) booktabs modelwidth(12) nonotes addnotes("\begin{minipage}{15.9cm} \vspace{0.1cm} \scriptsize Notes: Clustered standard errors at household level are in parentheses. The coefficients report average marginal effects. \textit{Shops with grocery list: Never} is dropped due to multicollinearity and is the reference group. Similarly, \textit{School, no degree} and \textit{White} are dropped and are the respective base levels. \sym{*} \(p<0.1\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\). \end{minipage}") ///
label obslast se replace drop(1.educ 1.race *.region 1.grocerylistfreq) star(* 0.10 ** 0.05 *** 0.01) ///
mgroups("\textbf{Dependent variable: Obesity dummy (BMI$>=$30)}", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span} &\multicolumn{4}{c}{Full sample}&\multicolumn{1}{c}{Poor}&\multicolumn{1}{c}{Low inc.}&\multicolumn{1}{c}{High inc.}\\ \cmidrule(lr){2-5}\cmidrule(lr){6-6}\cmidrule(lr){7-7}\cmidrule(lr){8-8})) 



/* Payment method
eststo m0: reg bmi i.payment, vce(cluster whogotpnum)
*eststo m00: margins, dydx(*) post
estadd local place "No"
estadd local race "No"
estadd local educ "No"

eststo m1: reg bmi i.payment i.region, vce(cluster whogotpnum)
*eststo m11: margins, dydx(*) post
estadd local place "Yes"
estadd local race "No"
estadd local educ "No"

eststo m2: reg bmi i.payment female tobacco AGE_R i.educcat tobacco vegetarian i.region, vce(cluster whogotpnum)
*eststo m22: margins, dydx(*) post
estadd local place "Yes"
estadd local race "No"
estadd local educ "Yes"

eststo m3: reg bmi i.payment female tobacco AGE_R i.educcat tobacco vegetarian i.RACECAT_R i.region, vce(cluster whogotpnum)
*eststo m33: margins, dydx(*) post
estadd local place "Yes"
estadd local race "Yes"
estadd local educ "Yes"

eststo m4: reg bmi i.payment female tobacco AGE_R i.educcat tobacco vegetarian i.RACECAT_R inchhavg_r hhsize i.region, vce(cluster whogotpnum)
*eststo m44: margins, dydx(*) post
estadd local place "Yes"
estadd local race "Yes"
estadd local educ "Yes"

esttab m0 m1 m2 m3 m4 using "//Mac/iCloud/Data/foodAPS/tex/logit_reg_payment.tex", ///
b(3) se(3) stats(place educ race N, label("Census region dummy" "Education dummy" "Ethnicity dummy") fmt(0 0 0 %12.0gc)) ///
compress nodepvars nonumbers mtitles("(1)" "(2)" "(3)" "(4)" "(5)") ///
varwidth(12) booktabs modelwidth(12) nonotes addnotes("\scriptsize{Clustered standard errors at individual level in parentheses. The coefficients report average marginal effects.}" "\scriptsize{\textit{Shops with grocery list: Never} is dropped due to multicollinearity and is the reference group.}" /// 
"\scriptsize{\sym{*} \(p<0.05\), \sym{**} \(p<0.01\), \sym{***} \(p<0.001\)}") ///
label obslast se replace drop(*.region 0.payment *.educcat *.RACECAT_R) ///
mgroups("\textbf{Dependent variable: Obesity dummy (BMI$>=$30)}", pattern(1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) 
*/

}
*

* Energy and sugar table
if $energy_sugar == 1 {
 
*** Extend to ITEM level data
merge 1:m hhnum eventid using "\\Mac\iCloud\Data\foodAPS\raw\faps_fahitem_puf.dta"
keep if _merge == 3
drop _merge

* Merge with NUTRITION level data
merge 1:1 hhnum eventid itemnum using "\\Mac\iCloud\Data\foodAPS\raw\faps_fahnutrients.dta"
keep if _merge == 3
drop _merge

* Prepare data
gen energy_med = energy
gen totsug_med = totsug
gen totsod_med = sodium

collapse (mean) energy totsug (median) energy_med totsug_med, by(grocerylistfreq)

foreach v in energy totsug energy_med totsug_med {

	format `v' %8.1f

}
*

label define gro_list1 1 "Shops with grocery list: Never" 2 "Shops with grocery list: Seldom" 3 "Shops with grocery list: Sometimes" 4 "Shops with grocery list: Most of the time" 5 "Shops with grocery list: Almost always"
label values grocerylistfreq gro_list1

listtab grocerylistfreq energy totsug energy_med totsug_med using "//Mac/iCloud/Data/foodAPS/tex/energy_sugar.tex", ///
    rstyle(tabular) replace ///
    head("\begin{tabular}{lrrrr}" ///
    "\toprule" ///
    "& \multicolumn{2}{c}{\textbf{Means}} & \multicolumn{2}{c}{\textbf{Medians}} \\" ///
    "\cmidrule(lr){2-3} \cmidrule(lr){4-5}" ///
    " & Energy (kcal) & Total sugar (g) & Energy (kcal) & Total sugar (g) \\" ///
    "\midrule") ///
    foot("\bottomrule" "\multicolumn{5}{l}{\begin{minipage}{15.2cm} \vspace{0.1cm} \scriptsize Notes: Numbers refer to 100g servings. Means (or medians) refer to the average (or midpoint) of the energy or sugar levels of all the purchased items per list use frequency group. The data is explained in section \ref{data}. \end{minipage}}" "\end{tabular}")

}		
*

/* Obesity by shopping list use and income level
collapse (mean) obesity, by(grocerylistfreq above_pg)

sort above_pg groc

foreach v in obesity {

	format `v' %8.2f

}
*

rename obesity obesity_

reshape wide obesity_, i(grocerylistfreq) j(above)

graph twoway (connected obesity_0 grocerylistfreq, ylabel(,grid gstyle(dot) labsize(vsmall))) ///
			 (connected obesity_1 grocerylistfreq) ///
			 (connected obesity_2 grocerylistfreq, legend(label(1 "Poor") label(2 "Low inc.") label(3 "High inc.") size(vsmall) rows(1)))


graph twoway ///
	(tsline female_est, lcolor(red) ttitle("") tlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline both_est, lcolor(black)) ///
	(tsline male_est, lcolor(blue) tline(2012, lp(shortdash) lc(black)) ttick(1975(5)2016) tlabel(1975(5)2015) tlabel(2012 "Sample" , add) ///
	ytitle("Percentage of individuals with BMI>=30", size(vsmall)) ytick(10(5)40) ylabel(10(5)40) ///	
	legend(label(1 "Women") label(2 "Both") label(3 "Men") size(vsmall) rows(1)) ///
	note("Note: Data of the crude obesity estimates is from the World Health Organization. The dashed vertical line refers to the sample period.", size(vsmall))) 
graph export "//Mac/iCloud/Data/foodAPS/tex/obesity_time_series.pdf", as(pdf) replace

/* Table calories and sugars
label variable energy "Energy (kcal), per 100g"	
label variable totsug "Total sugars (g), per 100g"	
label variable v_total "Total veggies (cup eq. per 100g)"

estpost tabstat energy totsug, statistics(mean p50) by(grocerylistfreq)

esttab using "//Mac/iCloud/Data/foodAPS/tex/calorie_sugar.tex", replace ///
cells("energy(label(\textbf{Energy (kcal per 100g)}) fmt(1)) totsug(label(\textbf{Total sugar (g per 100g)}) fmt(1))") ///
noobs nomtitle nonumber compress nogaps note("\tiny{Note: tbd.}") ///
eqlabels(`e(labels)') varwidth(20) booktabs


/*

tab primstoretravelmode
tab PLACEDIST_S
PLACEDIST_D
PLACEDIST_W

PLACESNAPTYPE

grocerylistfreq

primstoretravelmode








preserve

collapse (median) energy totsug totfat, by(date)

gen wdate = wofd(date)
format wdate %tw

collapse (median) energy totsug totfat, by(wdate)

tsset wdate

graph twoway (tsline energy, yaxis(1)) ///
			 (tsline totsug, yaxis(2))

restore

* Distance regressions
gen car_pc = vehiclenum/hhsize
drop if placedist_d == .

reg placedist_d car_pc inchhavg_r bmi female i.RACECAT, vce(robust)
reg placetime_d car_pc inchhavg_r bmi female i.RACECAT, vce(robust)

reg placedist_w car_pc inchhavg_r bmi female i.RACECAT, vce(robust)
reg bmi c.car_pc##c.placedist_d inchhavg_r female i.RACECAT i.region, vce(robust)



* Test regression

gen female = 0 if sex == 1
replace female = 1 if sex == 2

* Recoding ethnicity
drop if RACECAT == - 998

reg totsug cash check creditcard debitcard female i.RACECAT AGE_R inchhavg_r, vce(robust)

probit anydieting energy

hist add_sugar


reg totsug i.RACECAT bmi AGE_R inchhavg_r, vce(robust)

reg protein i.RACECAT bmi AGE_R inchhavg_r, vce(robust)

drop if grocerylistfreq < 0

reg totfat i.grocerylistfreq i.RACECAT bmi AGE_R inchhavg_r i.vegetarian, vce(robust)

reg v_total i.grocerylistfreq i.RACECAT bmi AGE_R inchhavg_r i.vegetarian, vce(robust)

reg bmi bmi AGE_R inchhavg_r i.vegetarian, vce(robust)











