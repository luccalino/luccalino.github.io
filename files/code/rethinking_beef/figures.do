********************************************************************************
* Preliminaries
********************************************************************************
* LZA, February 2018

* This file creates export and import time series.

* Input files: daily swiss trade data
* Output files: tbd  

clear

* Setting working directory
global Project_dir = "\\Mac\iCloud\Data\customs_data"

global data_dir = "V:\data"
global do_dir = "$Project_dir\Do"
global pdf_dir = "$Project_dir\Figures" 
global tex_dir = "$Project_dir\Tex"

* Administration
set more off, permanently
set scheme s1color

/* Summary statistics
reg wert eigenm, vce(robust)

estpost sum ipay ipay_pnc iinc iinc_pnc avg_inc_nat_pers med_inc_nat_pers avg_wealth_nat_pers tax_nat_pers pop_density unemp_rate for_rate social_aid
esttab, replace noisily refcat(ipay "Main variables:" pop_density "Control Variables:", /// 
nolabel) cells("mean(label(Mean)fmt(%9.1f)) sd(label(St. Dev.)fmt(1)) min(label(Min.)fmt(1)) max(label(Max.)fmt(1)) count(label(N)fmt(0))") ///
label nomtitle nonumber noobs 
esttab using "$Project_dir\tex\summary_statistics.tex", ///
replace noisily refcat(ipay "\textbf{Dependent Variables:}" avg_inc_nat_pers "[1em] \textbf{Independent Variables:}" pop_density "[1em] \textbf{Control Variables:}", nolabel) ///
note("\scriptsize{Note: One municipality does not report numbers on tax rates as well as social aid collectors.}") ///
cells("mean(label(\textbf{Mean})fmt(1)) sd(label(\textbf{SD})fmt(1)) min(label(\textbf{Min.})fmt(1)) max(label(\textbf{Max.})fmt(1)) count(label(\textbf{N})fmt(0))") ///
label nomtitle nonumber noobs booktabs
*/

* Time series spices
use "$data_dir\working_data_Import.dta", replace

keep if spice != ""

gen unit_value = wert/eigenm

collapse (sum) eigenm (p50) unit_value, by(mdate spice)

rename eigenm volume_
rename unit_value unit_value_

reshape wide unit_value_ volume_, i(mdate) j(spice) string

tsset  mdate, monthly

graph twoway tsline unit_value_cucurma  
graph twoway tsline unit_value_anise 
graph twoway tsline unit_value_caraway
graph twoway tsline unit_value_cumin 
graph twoway tsline unit_value_ginger 
graph twoway tsline unit_value_other_spices 
graph twoway tsline unit_value_saffron 
graph twoway tsline volume_cucurma 
graph twoway tsline volume_anise 
graph twoway tsline volume_caraway
graph twoway tsline volume_cumin 
graph twoway tsline volume_ginger 
graph twoway tsline volume_other_spices 
graph twoway tsline volume_saffron 

* Origin shares spices
use "$data_dir\working_data_Import.dta", replace

keep if spice != ""

gen unit_value = wert/eigenm

collapse (sum) eigenm (p50) unit_value, by(isocode spice)

bysort spice: egen tot = sum(eigenm)
bysort spice: gen share = eigenm/tot*100
bysort spice: egen rank = rank(share)
bysort spice: egen max = max(rank)
bysort spice: gen range = max - 3
bysort spice: gen pod = 1 if rank >= range
keep if pod == 1

* Destination shares spices
use "$data_dir\working_data_Import.dta", replace

keep if spice == "cucurma"
keep if iso == "IN"

collapse (sum) eigenm, by(plz spice)

bysort plz spice: egen tot = sum(eigenm)
bysort spice: egen grand_tot = sum(eigenm)
gen share = tot/grand_tot
sort share


* Time series
use "\\Mac\iCloud\Data\customs_data\Data_by_Year\working_data_Import.dta", clear

gen unit_value = wert/eigenm

collapse (sum) eigenm (mean) unit_value wert, by(mdate type)

rename eigenm volume_
rename wert value_
rename unit_value unit_value_

reshape wide unit_value_ volume_ value_, i(mdate) j(type) string

tsset  mdate, monthly

graph twoway tsline unit_value_Avocado 


graph twoway ///
	(line uv wdate, lcolor(edkblue) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) 
	
	///
	tline(12aug2017, lc(red)) tlabel(12aug2017 "Interruption", add labsize(*.75)) tline(02oct2017, lc(green)) tlabel(02oct2017 "Re-opening", add) ///
	title("`l': Train")), ///
saving("$Project_dir\4_pdf\time_series\daily\countries\ts_`type'_`l'_rail_`g'_daily", replace)

* Stacked time series exotic fruits
use "\\Mac\iCloud\Data\customs_data\DataImportbyYear\working_import_data.dta", clear

gen unit_val_ = wert/eigenm
drop if unit_val_ == .

collapse (sum) eigenm (mean) unit_val_, by(mdate ex)

drop if exo == ""

replace eigenm = eigenm/1000
rename eigenm volume_

reshape wide volume_ unit_val_, i(mdate) j(exo) string

gen yr = yofd(dofm(mdate))
gen mnth = mofd(dofm(mdate))

gen T = string(mnth, "%tmCY-m") 
labmask mdate, values(T) 

/*graph bar volume_Avocados volume_Bananas volume_Grapefruit volume_Lemons volume_Mandarins ///
	  volume_Oranges, over(mdate, label(labsize(tiny) angle(90) alt)) ///
	  bar(1, color(dkgreen)) bar(2, color(gold)) bar(3, color(sandb)) bar(4, color(yellow)) bar(5, color(orange_red)) bar(6, color(orange)) ///
	  ytitle("in Tons") stack ///
	  title("Exotic fruit imports") legend(label(1 "Avocados") label(2 "Bananas") label(3 "Grapefruits") label(4 "Lemons") label(5 "Mandarins") ///
	  label(6 "Oranges") size(vsmall) rows(2)) 
*/	  

tsset  mdate, monthly

graph twoway ///
	(tsline unit_val_Avocados, lcolor(forest_green) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline unit_val_Bananas, lcolor(gold)) ///
	(tsline unit_val_Figs, lcolor(purple)) ///
	(tsline unit_val_Dates, lcolor(sienna)) ///	
	(tsline unit_val_Pineapples, lcolor(stone)) ///	
	(tsline unit_val_Mangos, lcolor(sandb)) ///
	(tsline unit_val_Grapefruit, lcolor(pink)) ///	
	(tsline unit_val_Oranges, lcolor(orange) tlabel(2012m1 2012m6 2012m12 2013m6 2013m12 2014m6 2014m12 ///
	2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("") ytitle("Unit values (CHF/kg)") ///
	legend(label(1 "Avocados") label(2 "Bananas") label(3 "Figs") label(4 "Dates") label(5 "Pineapples") label(6 "Mangos") ///
	label(7 "Grapefruits") label(8 "Oranges") size(vsmall) rows(2)) ///
	title("Mean unit values of exotic fruit imports")) 
graph export "//Mac/iCloud/Data/customs_data/Figures/mean_unit_values_exotic_fruit_imports.pdf", as(pdf) replace	  

***********************************************************************************************************	
* Stacked time wine
use "\\Mac\iCloud\Data\customs_data\DataImportbyYear\working_import_data.dta", clear

gen unit_val_ = wert/eigenm
drop if unit_val_ == .

collapse (sum) eigenm (median) unit_val_, by(wdate wine)

drop if wine == ""

replace eigenm = eigenm/1000
rename eigenm volume_

reshape wide unit_val_ volume_, i(wdate) j(wine) string

gen yr = yofd(dofm(mdate))
gen mnth = mofd(dofm(mdate))

gen T = string(mnth, "%tmCY-m") 
labmask mdate, values(T) 

graph bar volume_Red_small volume_White_small volume_Sparkling, ///
	  over(mdate, label(labsize(tiny) angle(90) alt)) ///
	  bar(1, color(cranberry) lcolor(black)) bar(2, color(bluishgray) lcolor(black)) bar(3, color(sandb) lcolor(black)) ///
	  ytitle("in 1000L") stack ///
	  title("Wine imports in small containers") legend(label(1 "Red wine") label(2 "White wine") label(3 "Sparkling wine") ///
	  size(vsmall) rows(1)) 
graph export "//Mac/iCloud/Data/customs_data/Figures/wine_imports_volumes.pdf", as(pdf) replace 

tsset  wdate, weekly

graph twoway ///
	(tsline unit_val_Red_small, lcolor(cranberry) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline unit_val_White_small, lcolor(bluishgray))(tsline unit_val_Sparkling, lcolor(sandb) tlabel(2012w01 2012w25 2012w52 ///
	2013w25 2013w52 2014w25 2014w52	2015w25 2015w52 2016w25 2016w52 2017w25 2017w52) xtitle("") ytitle("Unit values (CHF/Liter)") ///
	legend(label(1 "Red wine") label(2 "White wine") label(3 "Sparkling wine") size(vsmall) rows(1)) ///
	title("Median weekly unit values of Swiss wine imports")) 
graph export "//Mac/iCloud/Data/customs_data/Figures/median_weekly_unit_values_wine_imports.pdf", as(pdf) replace


graph twoway ///
	(tsline volume_Red_small, lcolor(cranberry) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline volume_White_small, lcolor(bluishgray))(tsline volume_Sparkling, lcolor(sandb) tlabel(2012w01 2012w25 2012w52 ///
	2013w25 2013w52 2014w25 2014w52	2015w25 2015w52 2016w25 2016w52 2017w25 2017w52) xtitle("") ytitle("Volume (in 1000L)") ///
	legend(label(1 "Red wine") label(2 "White wine") label(3 "Sparkling wine") size(vsmall) rows(1)) ///
	title("Median weekly volume of Swiss wine imports")) 
graph export "//Mac/iCloud/Data/customs_data/Figures/median_weekly_volume_wine_imports.pdf", as(pdf) replace

use "\\Mac\iCloud\Data\customs_data\DataImportbyYear\working_import_data.dta", clear

gen unit_val_ = wert/eigenm
drop if unit_val_ == .

keep if wine_type != ""

collapse (sum) eigenm, by(wine_type mdate iso)

keep if wine_type == "Red_small" | wine_type == "White_small" | wine_type == "Sparkling"

bysort iso: egen total_prod = sum(eigenm)

tabstat total_prod, stats(min p5 p10 p25 p50 p75 p90 p95 max)

keep if wine_type == "Sparkling"

drop total_prod

gen yr = yofd(dofm(mdate))
gen mnth = mofd(dofm(mdate))

gen T = string(mnth, "%tmCY-m") 
labmask mdate, values(T) 

drop yr mnth T 

reshape wide eigenm, i(mdate wine_type) j(isocode) string

graph bar eigenmAD eigenmAM eigenmAR eigenmBG eigenmBR eigenmCA eigenmCL eigenmCN eigenmCU ///
		  eigenmCY eigenmCZ eigenmDK eigenmDO eigenmEC eigenmEG eigenmFI eigenmGB eigenmGE ///
		  eigenmGI eigenmGR eigenmHK eigenmHR eigenmHU eigenmID eigenmIE eigenmIL eigenmIN eigenmIR eigenmJP ///
		  eigenmKR eigenmKZ eigenmLT eigenmLU eigenmLV eigenmMD eigenmMG eigenmMT eigenmMX eigenmNL eigenmNZ eigenmPE ///
		  eigenmPF eigenmPH eigenmPK eigenmPL eigenmQA eigenmRO eigenmRS eigenmRU eigenmSA eigenmSE eigenmSG ///
		  eigenmSI eigenmSK eigenmTH eigenmTR eigenmTW eigenmUA eigenmUS eigenmUY eigenmZA, over(mdate, label(labsize(tiny) angle(90) alt)) stack 
		  ///
		  legend(size(small))
 
graph bar eigenmAT eigenmAU eigenmBE  ///
		  eigenmDE eigenmES eigenmFR ///
		  eigenmIT ///
		  eigenmPT, over(mdate, label(labsize(tiny) angle(90) alt)) stack legend(size(small))
  
***********************************************************************************************************	

* Stacked time coffee
use "\\Mac\iCloud\Data\customs_data\DataImportbyYear\working_import_data.dta", clear

gen unit_val_ = wert/eigenm
drop if unit_val_ == .

collapse (sum) eigenm (mean) unit_val_, by(mdate coffee)

drop if coffee == ""

replace eigenm = eigenm/1000
rename eigenm volume_

reshape wide unit_val_ volume_, i(mdate) j(coffee) string

gen yr = yofd(dofm(mdate))
gen mnth = mofd(dofm(mdate))

gen T = string(mnth, "%tmCY-m") 
labmask mdate, values(T) 

/*graph bar volume_Red_small volume_White_small volume_Sparkling, ///
	  over(mdate, label(labsize(tiny) angle(90) alt)) ///
	  bar(1, color(cranberry) lcolor(black)) bar(2, color(bluishgray) lcolor(black)) bar(3, color(sandb) lcolor(black)) ///
	  ytitle("in 1000L") stack ///
	  title("Wine imports in small containers") legend(label(1 "Red wine") label(2 "White wine") label(3 "Sparkling wine") ///
	  size(vsmall) rows(1)) 
graph export "//Mac/iCloud/Data/customs_data/Figures/wine_imports_volumes.pdf", as(pdf) replace 
*/

tsset  mdate, monthly

graph twoway ///
	(tsline unit_val_unroasted_decaf, lcolor(olive_teal) lpattern(dash) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline unit_val_unroasted, lcolor(olive_teal) lpattern(solid)) ///
	(tsline unit_val_roasted_decaf, lcolor(sienna) lpattern(dash)) ///
	(tsline unit_val_roasted, lcolor(sienna) lpattern(solid) tlabel(2012m1 2012m6 2012m12 2013m6 2013m12 2014m6 2014m12 ///
	2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("") ytitle("Unit values (CHF/kg)") ///
	legend(label(1 "Unroasted/decaffinated") label(2 "Unroasted/caffinated") label(3 "Roasted/decaffinated") label(4 "Roasted/caffinated" )size(vsmall) rows(2)) ///
	title("Mean unit values of Swiss coffee imports")) 
graph export "//Mac/iCloud/Data/customs_data/Figures/mean_unit_values_coffee_imports.pdf", as(pdf) replace
	

* Geoplots wine
use "\\Mac\iCloud\Data\customs_data\DataImportbyYear\working_import_data.dta", clear

gen unit_val_ = wert/eigenm
drop if unit_val_ == .
replace eigenm = eigenm/1000

collapse (sum) eigenm (mean) unit_val_, by(iso wine)

rename eigenm volume_

drop if wine == ""

reshape wide volume_ unit_val_, i(isocode) j(wine_type) string

rename isocode iso_a2

merge 1:m iso_a2 using "\\Mac\iCloud\Data\customs_data\World_map_data\worlddata.dta" 
sort _merge
drop if _merge == 1

gen red_to_white = volume_Red_small/volume_White_small 

tabstat red_to_white, stats(min p5 p10 p25 p50 p75 p90 p95 max)

local schemes blues greens grays oranges purples reds heat heat2 ///
    terrain terrain2 viridis plasma redblue
local palettes
foreach scheme of local schemes {
    local palettes `palettes' hcl, `scheme' /
}
colorpalette, title("HCL sequential") plabels(`schemes') ///
    gropts(ysize(5.5) scale(.73)): `palettes'

spmap red_to_white if admin!="Antarctica" using "\\Mac\iCloud\Data\customs_data\World_map_data\worldcoor.dta", id(id) fcolor(Reds) ///
	  clnumber(9) clbreaks(0.016 .09 0.799 1.63 3.928 9.58 21 51.361 676.6) legend(on size(*0.7) cols(1)) name(red, replace) 


tabstat volume_Red_small, stats(min p5 p10 p25 p50 p75 p90 p95 max)

spmap volume_Red_small if admin!="Antarctica" using "\\Mac\iCloud\Data\customs_data\World_map_data\worldcoor.dta", id(id) fcolor(Reds) ///
	  clnumber(9) clbreaks(0 0.001 0.002 0.009 0.152 8.748 105.124 3836.846 12378.02 193489.3) legend(on size(*0.7) cols(1)) name(red, replace) 

tabstat volume_White_small, stats(min p5 p10 p25 p50 p75 p90 p95 max)
	  
spmap volume_White_small if admin!="Antarctica" using "\\Mac\iCloud\Data\customs_data\World_map_data\worldcoor.dta", id(id) fcolor(Oranges) ///
	  clnumber(9) clbreaks(0 0.001 0.009 0.013 0.104 2.809 34.251 1925.467 8346.04 42381.12) legend(on size(*0.7) cols(1)) name(white, replace)

tabstat volume_Sparkling, stats(min p5 p10 p25 p50 p75 p90 p95 max)	  
	  
spmap volume_Sparkling if admin!="Antarctica" using "\\Mac\iCloud\Data\customs_data\World_map_data\worldcoor.dta", id(id) fcolor(Greens) ///
	  clnumber(8) clbreaks(0 0.001 0.005 0.059 0.734 18.071 269.676 4818.741 58277.42) legend(on size(*0.7) cols(1)) name(sparkling, replace)

graph combine red white sparkling, cols(1) 
graph export "//Mac/iCloud/Data/customs_data/Figures/geoplot_volume_origin.pdf", as(pdf) replace

*********************************************************************************
set scheme s1color

*** Avocado ***
clear

insheet using "\\Mac\iCloud\Data\customs_data\Google_data\avocado_mango.csv", comma

foreach t of num 2/5 {

	destring v`t', replace force

}
*

rename v1 date
rename v2 avocado_CH
rename v3 mango_CH
rename v4 avocado_WD
rename v5 mango_WD

drop if avocado_CH == .

gen mdate = monthly(date, "YM")
format mdate %tm

tsset mdate

graph twoway ///
	(tsline avocado_CH, lcolor(navy) ytitle("") xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline avocado_WD, ytitle("") ylabel(, labsize(vsmall)) lcolor(olive_teal) tlabel(2012m1 2012m6 2012m12 ///
	2013m6 2013m12 2014m6 2014m12	2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("") ///
	legend(label(1 "Switzerland") label(2 "World") size(vsmall) rows(1)) ///
	tline(2015m8, lc(red)) tlabel(2015m8 "Publishing of ESF", add labsize(*.75))) 
	/// title("Avocado: Monthly google searches") name(gs_avocado, replace)) 
graph export "Z:\Dropbox\Projects\customs_data\figures\monthly_google_searches_avocado.pdf", as(pdf) replace	
	
graph twoway ///
	(tsline mango_CH, lcolor(navy) ytitle("") xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline mango_WD, ytitle("") ylabel(, labsize(vsmall)) lcolor(olive_teal) tlabel(2012m1 2012m6 2012m12 ///
	2013m6 2013m12 2014m6 2014m12	2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("") ///
	legend(label(1 "Switzerland (lhs)") label(2 "World (rhs)") size(vsmall) rows(1)) ///
	title("Mango: Monthly google searches")) 	

*********************************************************************************
* Time series
use "\\Mac\iCloud\Data\customs_data\Data_by_Year\working_data_Import.dta", clear

keep if exotic_fruit_type == "Avocados" | exotic_fruit_type == "Mangos"

gen unit_value = wert/eigenm
replace eigenm=eigenm/1000

collapse (median) unit_value (sum) eigenm, by(mdate ex)

reshape wide unit_value eigenm, i(mdate) j(ex) string
 
tsset mdate

graph twoway ///
	(tsline unit_valueAvocados, yaxis(1) lcolor(navy) ytitle("", axis(1)) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline eigenmAvocados, yaxis(2) ytitle("", axis(2)) ylabel(, axis(2) labsize(vsmall)) lcolor(olive_teal) tlabel(2012m1 2012m6 2012m12 ///
	2013m6 2013m12 2014m6 2014m12	2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("") ///
	legend(label(1 "Price (CHF/kg, lhs)") label(2 "Volume (tons, rhs)") size(vsmall) rows(1)) /// 
	tline(2015m8, lc(red)) tlabel(2015m8 "Publishing of ESF", add labsize(*.75))) 
	/// title("Avocado: Monthly import prices and volumes") name(pv_avocado, replace)) 
graph export "Z:\Dropbox\Projects\customs_data\figures\monthly_prices_volumes_avocado.pdf", as(pdf) replace

graph twoway ///
	(tsline unit_valueMangos, yaxis(1) lcolor(navy) ytitle("", axis(1)) xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline eigenmMangos, yaxis(2) ytitle("", axis(2)) ylabel(, axis(2) labsize(vsmall)) lcolor(olive_teal) tlabel(2012m1 2012m6 2012m12 ///
	2013m6 2013m12 2014m6 2014m12	2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("") ///
	legend(label(1 "Import price (CHF/kg, lhs)") label(2 "Import volume (tons, rhs)") size(vsmall) rows(1)) ///
	title("Mango: Monthly import prices and volumes")) 
graph export "Z:\Dropbox\Projects\customs_data\figures\monhtly_prices_volume_mango.pdf", as(pdf) replace

restore

graph combine gs_avocado pv_avocado, cols(1)

* Producer countries
preserve

use "\\Mac\iCloud\Data\customs_data\Data_by_Year\working_data_Import.dta", clear

keep if exotic_fruit_type == "Avocados" /*| exotic_fruit_type == "Mangos" */

gen unit_value = wert/eigenm
replace unit_value = round(unit_value, 0.01)
replace eigenm=eigenm/1000
replace eigenm = round(eigenm, 0.01)

collapse (median) unit_value (sum) eigenm, by(iso)

rename isocode iso_a2

merge 1:m iso_a2 using "\\Mac\iCloud\Data\customs_data\World_map_data\worlddata.dta" 
drop if _merge == 1
drop _merge

tabstat eigenm, stats(min p10 p25 p50 p75 p90 max)

spmap eigenm if admin!="Antarctica" using "\\Mac\iCloud\Data\customs_data\World_map_data\worldcoor.dta", id(id) fcolor(Greens) ///
	  clnumber(6) clbreaks(0 0.02 0.08 2.965 63.665 1975.61 19527.07) legend(on cols(1) title("Import volume (tons)", size(small))) name(volume, replace) 

tabstat unit_value, stats(min p10 p25 p50 p75 p90 max)

spmap unit_value if admin!="Antarctica" using "\\Mac\iCloud\Data\customs_data\World_map_data\worldcoor.dta", id(id) fcolor(Blues) ///
	  clnumber(6) clbreaks(0 2 3.095 3.775 4.5775 7.05 14.4) legend(on cols(1) title("Import price (CHF/kg)", size(small))) name(price, replace) 

graph combine volume price, cols(1)
graph export "//Mac/iCloud/Data/customs_data/Figures/avocado/geoplot_price_volume.pdf", as(pdf) replace

restore

* Destination municipalities
preserve

clear
insheet using "\\Mac\iCloud\Data\customs_data\BFS_data\PLZ_to_BFS\PLZ4-Table 1.csv", comma
rename plz4 plz
save "\\Mac\iCloud\Data\customs_data\BFS_data\PLZ_to_BFS\PLZ4-BFS", replace

restore

preserve

use "\\Mac\iCloud\Data\customs_data\Data_by_Year\working_data_Import.dta", clear

keep if exotic_fruit_type == "Avocados" /*| exotic_fruit_type == "Mangos" */

collapse (sum) eigenm, by(plz)

egen total_imp = sum(eigenm)
gen share = eigenm/total_imp
sort share

joinby plz using "\\Mac\iCloud\Data\customs_data\BFS_data\PLZ_to_BFS\PLZ4-BFS"

replace eigenm=eigenm/1000*_in_gde/100

collapse (sum) eigenm, by(gdenr gdenamk)

egen total_imp = sum(eigenm)
gen share = eigenm/total_imp
sort share

restore








* Origination percentages
use "\\Mac\iCloud\Data\customs_data\Data_by_Year\working_data_Import.dta", clear

keep if exotic_fruit_type == "Avocados" 

gen unit_value = wert/eigenm
replace unit_value = round(unit_value, 0.01)
replace eigenm=eigenm/1000
replace eigenm = round(eigenm, 0.01)

collapse (median) unit_value (sum) eigenm, by(iso)

egen total_import = sum(eigenm)
bysort iso: egen tot_country_imp = sum(eigenm)
gen import_share = round(tot_country_imp/total_import*100,0.01)

*bysort vkz: egen total_per_type = sum(eigenm)

*bysort vkz: egen vkz_total_import = sum(eigenm)
*gen vkz_import_share = eigenm/vkz_total_import*100

sort import_share

replace iso = "Others" if import_share < 0.8

collapse (sum) import_share (mean) unit_value, by(iso)

sort import_share

egen test = sum(import_share)

* Producer prices
clear

insheet using "\\Mac\iCloud\Data\customs_data\FAO_data\FAOSTAT_data_1-11-2019.csv", comma

gen month = 1 if months == "January"
replace month = 2 if months == "February"
replace month = 3 if months == "March"
replace month = 4 if months == "April"
replace month = 5 if months == "May"
replace month = 6 if months == "June"
replace month = 7 if months == "July"
replace month = 8 if months == "August"
replace month = 9 if months == "September"
replace month = 10 if months == "October"
replace month = 11 if months == "November"
replace month = 12 if months == "December"

tostring year, replace

egen sdate = concat(year month), punct(-)

gen mdate = monthly(sdate, "YM")
format mdate %tm

rename area country

drop domaincode domain areacode elementcode element itemcode monthscode flag flagdescription month sdate yearcode year months item unit

replace value = value/1000

replace country = "BR" if country == "Brazil"
replace country = "CL" if country == "Chile"
replace country = "CO" if country == "Colombia"
replace country = "DO" if country == "Dominican Republic"
replace country = "IL" if country == "Israel"
replace country = "KE" if country == "Kenya"
replace country = "ME" if country == "Mexico"
replace country = "MA" if country == "Morocco"
replace country = "ZA" if country == "South Africa"
replace country = "ES" if country == "Spain"
replace country = "PE" if country == "Peru"

reshape wide value, i(mdate) j(country) string

tsset mdate

graph twoway (tsline valueCL)
graph twoway (tsline valueCO)
graph twoway (tsline valueDO)
graph twoway (tsline valueIL)
graph twoway (tsline valueKE)
graph twoway (tsline valueZA)
graph twoway (tsline valueES)
graph twoway (tsline valuePE)

* FX data
clear

import excel "\\Mac\iCloud\Data\customs_data\FX_SNB\snb-chart-data-devwkieffinerech-en-all-20190109_0900-20190109_0900.xlsx", sheet("devwkieffinerech")

rename D overall_real

destring overall_real, replace force

drop if overall_real == . 

gen mdate = monthly(A, "YM")
format mdate %tm

drop A B C E

tsset mdate

drop if mdate < tm(2012m1)
drop if mdate > tm(2017m12)

* Readjust index
levelsof overall_real if mdate == tm(2012m1), local(base)
replace overall_real = overall_real/`base'*100

graph twoway ///
	(tsline overall_real, lcolor(navy) ytitle("Real effective FX rate") xlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall)) ///
	tlabel(2012m1 2012m6 2012m12 2013m6 2013m12 2014m6 2014m12 2015m6 2015m12 2016m6 2016m12 2017m6 2017m12) xtitle("")) 
graph export "Z:\Dropbox\Projects\customs_data\figures\fx_rate.pdf", as(pdf) replace	
	














