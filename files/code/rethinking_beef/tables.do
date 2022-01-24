********************************************************************************
* Preliminaries
********************************************************************************
* LZA, February 2018

* This file creates the export and import working dataset.

* Input files: daily swiss trade data
* Output files: tbd  

clear

* Setting working directory
global Project_dir = "\\Mac\iCloud\Data\customs_data"

global data_dir = "\\Mac\ExHD_LAZ\data" 
global do_dir = "$Project_dir\Do"
global pdf_dir = "$Project_dir\Figures" 
global tex_dir = "$Project_dir\Tex"

* Administration
set more off, permanently
set scheme s1color

* Data preparation
local t Import /* Import or Export */

global data_prep 1
global merge 0

if $data_prep == 1 {

* Merging datasets

use "$data_dir\Data_`t'_2012.dta", clear
append using "$data_dir\Data_`t'_2013.dta"
*append using "$data_dir\Data_`t'_2014.dta"
*append using "$data_dir\Data_`t'_2015.dta"
*append using "$data_dir\Data_`t'_2016.dta"
*append using "$data_dir\Data_`t'_2017.dta"

* Drop unused variables
drop hs_revision land_num ord_num veranlagnumm 

* Saving full dataset
save "$data_dir\full_`t'_data.dta", replace

* Dates
gen ddate = mdy(month,vera_day,year)
format ddate %td

gen wdate = wofd(ddate)
format wdate %tw

gen mdate = mofd(ddate)
format mdate %tm

drop year month vera_year vera_month vera_day 

* Keep beef products
gen beef = "live_cattle" if tari == 01022911 | tari == 01022919
replace beef = "fresh_meat" if tari >= 02011011 & tari <= 02013099
replace beef = "frozen_meat" if tari >= 02021011 & tari <= 02023099
replace beef = "salted_meat" if tari == 02102010 | tari == 02102090
replace beef = "preserved_meat" if tari == 16025011 | tari == 16025019

* Keep leguminous vegetables
gen legumes = "peas_af" if tari == 07131011
replace legumes = "peas" if (tari > 07131011 & tari <= 07131099) | (tari >= 07081010 & tari <= 07081019)
replace legumes = "chickpeas_af" if tari == 07132011
replace legumes = "chickpeas" if (tari > 07132011 & tari <= 07132099) | (tari >= 07081020 & tari <= 07081029)
replace legumes = "beans_af" if tari == 07133111
replace legumes = "beans" if (tari > 07133111 & tari <= 07133199) | (tari >= 07082010 & tari <= 07082099)
replace legumes = "lentils_af" if tari == 07134011
replace legumes = "lentils" if (tari > 07134011 & tari <= 07134099) | (tari >= 07089010 & tari <= 07089090)
replace legumes = "soya_af" if tari == 12019010 | tari == 12019021
replace legumes = "soya" if tari == 12019091 | tari == 12019099

keep if beef != "" | legumes != ""

save "$data_dir\working_data_`t'.dta", replace

}
*

if $merge == 1 {

use "$data_dir\working_data_Import.dta", clear

label define vkz_mode 2 "train" 3 "truck" 4 "plane" 8 "boat"
label values vkz_typ vkz_mode 

drop zoll_mng zoll_mng_code zoll_ans zoll_bet generalbew 

* Reshape IM
rename wert value_
rename eigenm volume_

drop eigenm_code zusatzm zusatzm_code schlsl zl_num dq_typ dq_num vkz_code dst_num d_total1 d_total2s d_energy wae_code 

collapse (sum) volume_ (mean) value_, by(tari plz isocode ddate wdate mdate legumes vkz)

reshape wide volume_ value_, i(tari plz isocode ddate wdate mdate legumes) j(vkz)

foreach v in volume_2 value_2 volume_3 value_3 volume_4 value_4 volume_5 value_5 volume_8 value_8 {

	rename `v' `v'_

}
*

reshape wide volume_2_ value_2_ volume_3_ value_3_ volume_4_ value_4_ volume_5_ value_5_ volume_8_ value_8_, i(tari plz isocode ddate wdate mdate) j(legumes) string

save "$data_dir\working_data_full.dta", replace

}
*

******************************************************************************
* Legumes analysis
use "$data_dir\working_data_Import.dta", clear

gen unit_value = wert/eigenm

gen region = "EU" if iso == "DE" | iso == "FR" | iso == "AT" ///
| iso == "BE" | iso == "CZ" | iso == "DK" | iso == "EE" ///
| iso == "ES" | iso == "GR" | iso == "IT" | iso == "LT" ///
| iso == "NL" | iso == "PL" | iso == "PT" | iso == "SI"
replace region = "UK" if iso == "UK" | iso == "IE"
replace region = "Americas" if iso == "US" | iso == "UY" ///
| iso == "CA" | iso == "BR" | iso == "AR" | iso == "CL" ///
| iso == "MX"
replace region = "Oceania" if iso == "AU" | iso == "NZ"
replace region = "Other" if region == ""

collapse (sum) eigenm, by(legumes region)

drop if legumes == "" 

gen type = legumes
replace legumes = "Beans for human consumption" if legumes == "beans"
replace legumes = "Beans for animal feeding" if legumes == "beans_af"
replace legumes = "Peas for human consumption" if legumes == "peas"
replace legumes = "Peas for animal feeding" if legumes == "peas_af"
replace legumes = "Soya for human consumption" if legumes == "soya"
replace legumes = "Soya for animal feeding" if legumes == "soya_af"
replace legumes = "Chickpeas for human consumption" if legumes == "chickpeas"
replace legumes = "Chickpeas for animal feeding" if legumes == "chickpeas_af"
replace legumes = "Lentils for human consumption" if legumes == "lentils"
replace legumes = "Lentils for animal feeding" if legumes == "lentils_af"

gen leg_type = "peas" if legumes == "Peas for human consumption" | legumes == "Peas for animal feeding"
replace leg_type = "beans" if legumes == "Beans for human consumption" | legumes == "Beans for animal feeding"
replace leg_type = "soya" if legumes == "Soya for human consumption" | legumes == "Soya for animal feeding"
replace leg_type = "chickpeas" if legumes == "Chickpeas for human consumption" | legumes == "Chickpeas for animal feeding"
replace leg_type = "lentils" if legumes == "Lentils for human consumption" | legumes == "Lentils for animal feeding"

reshape wide eigenm, i(legumes type leg_type) j(region) string

foreach v in eigenmAmericas eigenmEU eigenmOceania eigenmOther {

	replace `v' = 0 if `v' == .
	
}
*
gen total = (eigenmAmericas + eigenmEU + eigenmOceania + eigenmOther)/1000
order total, after(legumes)
bysort leg_type: egen total_p_type = sum(total)
gen sh_p_type = total/total_p_type*100 
order sh_p_type, after(total)
gen sh_EU = eigenmEU/(total*1000)*100
gen sh_Oceania = eigenmOceania/(total*1000)*100
gen sh_Other = eigenmOther/(total*1000)*100
gen sh_Americas = eigenmAmericas/(total*1000)*100

foreach v in total sh_p_type sh_EU sh_Oceania sh_Other sh_Americas {

	format `v' %8.1f
	
}
*

listtab legumes total sh_p_type sh_EU sh_Oceania sh_Other sh_Americas using "$tex_dir/animal_feed.tex", ///
    rstyle(tabular) replace ///
    head("\begin{tabular}{lrrrrrr}" ///
    "\toprule" ///
	"&\multicolumn{2}{c}{\textbf{Overall imports}} & \multicolumn{4}{c}{\textbf{Regional shares (\%)}} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-7}" ///
    "\textbf{Legume type} & \textbf{Tons} & \textbf{\%} & \textbf{EU} & \textbf{Oceania} & \textbf{Others} & \textbf{Americas} \\" ///
    "\midrule") ///
    foot("\bottomrule" "\multicolumn{7}{l}{\begin{minipage}{13cm} \vspace{0.1cm} \scriptsize Notes: Data is for 2012 and 2013 from the Swiss Customs Agency. There are no imports recorded from the UK as well as chickpeas and lentils for animal feed. \end{minipage}}" "\end{tabular}")

merge m:1 isocode using "\\Mac\iCloud\Data\customs_data\ISO_country_codes\isocode_country.dta"
keep if _merge == 3
drop _merge

drop if leg_type == "beans"

bysort iso: egen tot_country = sum(eigenm)
sort tot_cou

drop if share_leg < 1

keep share_leg country type tot_country

sort tot_country 

keep if tot_country >= 1014

egen rank = group(tot_country)
replace rank = 11 - rank
drop tot_country

reshape wide share_leg, i(rank country) j(type) string

foreach v in share_legpeas share_legpeas_af share_legsoya share_legsoya_af {

	replace `v' = 0 if `v' == .

}
*	

listtab rank country share_legpeas share_legsoya share_legpeas_af share_legsoya_af using "$tex_dir/animal_feed_origins.tex", ///
    rstyle(tabular) replace ///
    head("\begin{tabular}{llrrrr}" ///
    "\toprule" ///
	"& & \multicolumn{2}{c}{\textbf{Human consumption}} & \multicolumn{2}{c}{\textbf{Animal feed}} \\ \cmidrule(lr){3-4} \cmidrule(lr){5-6}" ///
    "& \textbf{Country} & \textbf{Peas (\%)} & \textbf{Soya (\%)} & \textbf{Peas (\%)} & \textbf{Soya (\%)} \\" ///
    "\midrule") ///
    foot("\bottomrule" "\multicolumn{6}{l}{\begin{minipage}{10cm} \vspace{0.1cm} \scriptsize Notes: Data is for 2012 and 2013 from the Swiss Customs Agency. \end{minipage}}" "\end{tabular}")










 
* Analysis by product type
use "$data_dir\working_data_Import.dta", clear

label define vkz_mode 2 "train" 3 "truck" 4 "plane" 8 "boat"
label values vkz_typ vkz_mode 

drop zoll_mng zoll_mng_code zoll_ans zoll_bet generalbew 

* Reshape IM
rename wert value_
rename eigenm volume_

drop eigenm_code zusatzm zusatzm_code schlsl zl_num dq_typ dq_num vkz_code dst_num d_total1 d_total2s d_energy wae_code 

gen unit_value_ = value_/volume_

drop if beef == ""

merge m:1 isocode using "\\Mac\iCloud\Data\customs_data\ISO_country_codes\isocode_country.dta"

gen region = "EU" if iso == "DE" | iso == "FR" | iso == "AT" ///
| iso == "BE" | iso == "CZ" | iso == "DK" | iso == "EE" ///
| iso == "ES" | iso == "GR" | iso == "IT" | iso == "LT" ///
| iso == "NL" | iso == "PL" | iso == "PT" | iso == "SI"
replace region = "UK" if iso == "UK" | iso == "IE"
replace region = "Americas" if iso == "US" | iso == "UY" ///
| iso == "CA" | iso == "BR" | iso == "AR" | iso == "CL" ///
| iso == "MX"
replace region = "Oceania" if iso == "AU" | iso == "NZ"
replace region = "Other" if region == ""

collapse (sum) volume_ (median) unit_value_, by(beef region)
replace beef = "Live cattle" if beef == "live_cattle" 
replace beef = "Fresh or chilled meat" if beef == "fresh_meat"
replace beef = "Frozen meat" if beef == "frozen_meat" 
replace beef = "Salted meat" if beef == "salted_meat" 
replace beef = "Preserved meat" if beef == "preserved_meat" 

drop if beef == ""
bysort beef: egen tot_imp = sum(volume_)
gen share = volume_/tot_imp*100

replace volume_ = volume_/1000 

drop tot_imp

foreach v in volume_ unit_value_ share {

	format `v' %8.1f

} 
*
drop unit

reshape wide share volume_, i(beef) j(region) string

foreach v in volume_Americas shareAmericas volume_EU shareEU volume_Oceania shareOceania volume_Other shareOther volume_UK shareUK {

	replace `v' = 0 if `v' == .
	
}
*

gen tot_vol = volume_Americas + volume_EU + volume_Oceania + volume_Other + volume_UK 

gsort - tot_vol

egen over_imp = sum(tot_vol)
gen ov_share = tot_vol/over_imp*100

format tot_vol %8.1f
format ov_share %8.1f
 
egen rank = group(ov_share)
replace rank = 6 - rank
gsort + rank

listtab rank beef tot_vol ov_share shareEU shareUK shareAmericas shareOceania shareOther using "$tex_dir/import_volumes.tex", ///
    rstyle(tabular) replace ///
    head("\begin{tabular}{llrrrrrrr}" ///
    "\toprule" ///
	"& &\multicolumn{2}{c}{\textbf{Overall imports}} & \multicolumn{5}{c}{\textbf{Regional shares (\%)}} \\ \cmidrule(lr){3-4} \cmidrule(lr){5-9}" ///
    "& \textbf{Beef type} & \textbf{Tons} & \textbf{\%} & \textbf{EU} & \textbf{UK} & \textbf{Americas} & \textbf{Oceania} & \textbf{Others} \\" ///
    "\midrule") ///
    foot("\bottomrule" "\multicolumn{9}{l}{\begin{minipage}{13.5cm} \vspace{0.1cm} \scriptsize Notes: Data is for 2012 and 2013 from the Swiss Customs Agency. \textit{EU} refers to the countries of the European Union as per 2013, \textit{UK} to the United Kingdom and Ireland, \textit{Americas} to countries from North, Central and South America, \textit{Oceania} to Australia and New Zealand and \textit{Others} to the remainder.  \end{minipage}}" "\end{tabular}")


* Analysis by country of origin and importation mode
use "$data_dir\working_data_full.dta", clear

preserve

use "$data_dir\working_data_Import.dta", clear

gen  unit_value = wert/eigenm

gen region = "EU" if iso == "DE" | iso == "FR" | iso == "AT" ///
| iso == "BE" | iso == "CZ" | iso == "DK" | iso == "EE" ///
| iso == "ES" | iso == "GR" | iso == "IT" | iso == "LT" ///
| iso == "NL" | iso == "PL" | iso == "PT" | iso == "SI"
replace region = "UK" if iso == "UK" | iso == "IE"
replace region = "Americas" if iso == "US" | iso == "UY" ///
| iso == "CA" | iso == "BR" | iso == "AR" | iso == "CL" ///
| iso == "MX"
replace region = "Oceania" if iso == "AU" | iso == "NZ"
replace region = "Other" if region == ""

collapse (median) unit_value, by(region)


save "$data_dir\unit_value_iso.dta", replace

restore

foreach v in volume_2_fresh_meat value_2_fresh_meat volume_3_fresh_meat value_3_fresh_meat volume_4_fresh_meat value_4_fresh_meat volume_5_fresh_meat value_5_fresh_meat volume_8_fresh_meat value_8_fresh_meat {

	replace `v' = 0 if `v' == .

} 
*

gen region = "EU" if iso == "DE" | iso == "FR" | iso == "AT" ///
| iso == "BE" | iso == "CZ" | iso == "DK" | iso == "EE" ///
| iso == "ES" | iso == "GR" | iso == "IT" | iso == "LT" ///
| iso == "NL" | iso == "PL" | iso == "PT" | iso == "SI"
replace region = "UK" if iso == "UK" | iso == "IE"
replace region = "Americas" if iso == "US" | iso == "UY" ///
| iso == "CA" | iso == "BR" | iso == "AR" | iso == "CL" ///
| iso == "MX"
replace region = "Oceania" if iso == "AU" | iso == "NZ"
replace region = "Other" if region == ""

collapse (sum) volume_2_fresh_meat volume_3_fresh_meat volume_4_fresh_meat volume_5_fresh_meat volume_8_fresh_meat, by(region) 

gen tot_fresh_beef_imp = volume_2_fresh_meat + volume_3_fresh_meat + volume_4_fresh_meat + volume_5_fresh_meat + volume_8_fresh_meat 

bysort region: egen tot_vol = sum(tot_fresh_beef_imp)
egen otot_vol = sum(tot_fresh_beef_imp) 
gen share = tot_vol/otot_vol*100

* Train 2
bysort region: egen tot_vol_train = sum(volume_2_fresh_meat) 
gen share_train = tot_vol_train/tot_vol*100

* Truck 3
bysort region: egen tot_vol_truck = sum(volume_3_fresh_meat) 
gen share_truck = tot_vol_truck/tot_vol*100

* Plane 4
bysort region: egen tot_vol_plane = sum(volume_4_fresh_meat)
gen share_plane = tot_vol_plane/tot_vol*100

* Boat 8
bysort region: egen tot_vol_boat = sum(volume_8_fresh_meat) 
gen share_boat = tot_vol_boat/tot_vol*100

gsort - share

keep region share*

*merge 1:1 isocode using "\\Mac\iCloud\Data\customs_data\ISO_country_codes\isocode_country.dta"

*keep if _merge == 3
*drop _merge
gsort - share

merge 1:1 region using "$data_dir\unit_value_iso.dta"

*drop _merge

format share* unit_value %8.1f

egen test_tot = sum(share) 
egen rank = group(share)
replace rank = 6 - rank
gsort + rank

listtab rank region unit_value share_truck share_plane share_train share_boat using "$tex_dir/import_shares.tex", ///
    rstyle(tabular) replace ///
    head("\begin{tabular}{llrrrrrr}" ///
    "\toprule" ///
	"&&& \multicolumn{5}{c}{\textbf{Transportation shares (\%)}} \\  \cmidrule(lr){4-8}" ///
    "&\textbf{Region} & \textbf{Import price (CHF/kg)} & \textbf{Truck} & \textbf{Plane} & \textbf{Train} & \textbf{Boat} \\" ///
    "\midrule") ///
    foot("\bottomrule" "\multicolumn{8}{l}{\begin{minipage}{11cm} \vspace{0.1cm} \scriptsize Notes: Data is for 2012 and 2013 from the Swiss Customs Agency. Import price is the median price in CHF per kg of imported fresh or chilled beef. Truck, plane, train and boat are divisions of the import volume by the respective transportation mode. \end{minipage}}" "\end{tabular}")









