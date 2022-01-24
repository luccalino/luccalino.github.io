********************************************************************************************************************
* Mergeing Food at home (FAH) datasets together
********************************************************************************************************************

* Administration
set more off, permanently
set scheme s1color

* Setting working directory
global Project_dir = "\\Mac\iCloud\Data\foodAPS"

global raw_dir = "$Project_dir\raw"
global dta_dir = "$Project_dir\dta"
global do_dir = "$Project_dir\do"
global pdf_dir = "$Project_dir\figures" 
global tex_dir = "$Project_dir\tex"

* Load HH level data
use "$raw_dir\faps_household_puf.dta", clear

tab hhsize /* 4826 HH's. HH size distribution mostly within 4 members. */

tabstat inchhavg_r, stats(mean p50)
 
* Merge with IND level data
merge 1:m hhnum using "$raw_dir\faps_individual_puf.dta"
drop _merge

tab bmi
drop if bmi == .e | bmi == .v | bmi == . /* 1'147 individuals do not report bmi */

/* 13'170 individuals of which 25% are suffering from obesity. */

* Merge with FAH (Food From Home) event level data
rename pnum whogotpnum
merge 1:m hhnum whogotpnum using "$raw_dir\faps_fahevent_puf.dta"

/* 335 obs not merged due to neglections in previous step (no bmi). 7'574 not merged due to missing shopping activity. */

tab RELATION_R if _merge == 1
keep if _merge == 3
drop _merge

tab whogotpnum /* Most ind shop once (85%, 12% twice and 2% three times). */

/* Merge with ITEM level data
merge 1:m hhnum eventid using "\\Mac\iCloud\Data\foodAPS\raw\faps_fahitem_puf.dta"
keep if _merge == 3
drop _merge

* Merge with NUTRITION level data
merge 1:1 hhnum eventid itemnum using "\\Mac\iCloud\Data\foodAPS\raw\faps_fahnutrients.dta"
drop _merge
*/

* Order important variables
order hhnum whogotpnum eventid, first /* itemnum itemdesc */

tabstat inchhavg_r, stats(mean p50)

* Save merged dataset
save "$dta_dir\working_dataset_fah.dta", replace

********************************************************************************************************************
