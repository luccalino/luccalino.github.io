* Obesity data
clear

insheet using "\\Mac\iCloud\Data\obesity_data\raw\xmart.csv"

rename v1 country

rename v2 both2016
rename v3 male2016
rename v4 female2016
rename v5 both2015
rename v6 male2015
rename v7 female2015
rename v8 both2014
rename v9 male2014
rename v10 female2014
rename v11 both2013
rename v12 male2013
rename v13 female2013
rename v14 both2012
rename v15 male2012
rename v16 female2012
rename v17 both2011
rename v18 male2011
rename v19 female2011
rename v20 both2010
rename v21 male2010
rename v22 female2010
rename v23 both2009
rename v24 male2009
rename v25 female2009
rename v26 both2008
rename v27 male2008
rename v28 female2008
rename v29 both2007
rename v30 male2007
rename v31 female2007
rename v32 both2006
rename v33 male2006
rename v34 female2006
rename v35 both2005
rename v36 male2005
rename v37 female2005
rename v38 both2004
rename v39 male2004
rename v40 female2004
rename v41 both2003
rename v42 male2003
rename v43 female2003
rename v44 both2002
rename v45 male2002
rename v46 female2002
rename v47 both2001
rename v48 male2001
rename v49 female2001
rename v50 both2000
rename v51 male2000
rename v52 female2000
rename v53 both1999
rename v54 male1999
rename v55 female1999
rename v56 both1998
rename v57 male1998
rename v58 female1998
rename v59 both1997
rename v60 male1997
rename v61 female1997
rename v62 both1996
rename v63 male1996
rename v64 female1996
rename v65 both1995
rename v66 male1995
rename v67 female1995
rename v68 both1994
rename v69 male1994
rename v70 female1994
rename v71 both1993
rename v72 male1993
rename v73 female1993
rename v74 both1992
rename v75 male1992
rename v76 female1992
rename v77 both1991
rename v78 male1991
rename v79 female1991
rename v80 both1990
rename v81 male1990
rename v82 female1990
rename v83 both1989
rename v84 male1989
rename v85 female1989
rename v86 both1988
rename v87 male1988
rename v88 female1988
rename v89 both1987
rename v90 male1987
rename v91 female1987
rename v92 both1986
rename v93 male1986
rename v94 female1986
rename v95 both1985
rename v96 male1985
rename v97 female1985
rename v98 both1984
rename v99 male1984
rename v100 female1984
rename v101 both1983
rename v102 male1983
rename v103 female1983
rename v104 both1982
rename v105 male1982
rename v106 female1982
rename v107 both1981
rename v108 male1981
rename v109 female1981
rename v110 both1980
rename v111 male1980
rename v112 female1980
rename v113 both1979
rename v114 male1979
rename v115 female1979
rename v116 both1978
rename v117 male1978
rename v118 female1978
rename v119 both1977
rename v120 male1977
rename v121 female1977
rename v122 both1976
rename v123 male1976
rename v124 female1976
rename v125 both1975
rename v126 male1975
rename v127 female1975

drop if country == "" | country == "Country"

reshape long both male female, i(country) j(year) string

destring year, replace

* Both
rename both both_est

replace both_est = subinstr(both_est, "]", "",.) 
replace both_est = subinstr(both_est, "[", "",.) 
replace both_est = subinstr(both_est, "-", " ",.) 

split both_est, p(" ")

rename both_est both_string_group
rename both_est1 both_est
rename both_est2 both_min
rename both_est3 both_max

* Male
rename male male_est

replace male_est = subinstr(male_est, "]", "",.) 
replace male_est = subinstr(male_est, "[", "",.) 
replace male_est = subinstr(male_est, "-", " ",.) 

split male_est, p(" ")

rename male_est male_string_group
rename male_est1 male_est
rename male_est2 male_min
rename male_est3 male_max

* Female
rename female female_est

replace female_est = subinstr(female_est, "]", "",.) 
replace female_est = subinstr(female_est, "[", "",.) 
replace female_est = subinstr(female_est, "-", " ",.) 

split female_est, p(" ")

rename female_est female_string_group
rename female_est1 female_est
rename female_est2 female_min
rename female_est3 female_max

drop both_string_group male_string_group female_string_group 

foreach v in both_est both_min both_max male_est male_min male_max female_est female_min female_max {

	destring `v', replace force

}
*

keep if country == "United States of America"

set scheme s1color

tsset  year, yearly

dydx both_est year, generate(dy)

graph twoway ///
	(tsline female_est, lcolor(red) ttitle("") tlabel(, labsize(vsmall) angle(45)) ylabel(,grid gstyle(dot) labsize(vsmall))) ///
	(tsline both_est, lcolor(black)) ///
	(tsline male_est, lcolor(blue) tline(2012, lp(shortdash) lc(black)) ttick(1975(5)2016) tlabel(1975(5)2015) tlabel(2012 "Sample" , add) ///
	ytitle("Percentage of individuals with BMI>=30", size(vsmall)) ytick(10(5)40) ylabel(10(5)40) ///	
	legend(label(1 "Women") label(2 "Both") label(3 "Men") size(vsmall) rows(1)) ///
	note("Note: Data of the crude obesity estimates is from the World Health Organization. The dashed vertical line refers to the sample period.", size(vsmall))) 
graph export "//Mac/iCloud/Data/foodAPS/tex/obesity_time_series.pdf", as(pdf) replace
