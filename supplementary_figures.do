

foreach C in GER1 GER2 GER3 GER4 FRA ITA NLD BEL ISR AUT PRT SVN CHN LUX LBN BIH HKG CHE HUN  FIN CZE {

use "$rawdata\merged_series.dta",  clear


keep if HCcode == "`C'"

replace helplinename = "Telefonseelsorge" if helplinename == "Telefonseelsorge Deutschland"
replace helplinename = "Telefonseelsorge" if helplinename == "Telefonseelsorge Österreich"
gen hlc = country + ", " + helplinename
local titletext = hlc[1]
display `"`titletext'"'

gen wave1 = 0
replace wave1 = 1 if stringencyindex > 65 & ddate < mdy(8,1,2020)
egen w1date1 = min(ddate) if wave1 == 1
egen w1date2 = max(ddate) if wave1 == 1

gen wave2 = 0
replace wave2 = 1 if stringencyindex > 65 & ddate > mdy(8,1,2020)
egen w2date1 = min(ddate) if wave2 == 1
egen w2date2 = max(ddate) if wave2 == 1

format w1date1 w1date2 w2date1 w2date2  %td
foreach V of varlist w1date1 w1date2 w2date1 w2date2 {
sort `V'
replace `V' = `V'[1]
}

sort ddate

replace MA7newcasesPOP = MA7newcasesPOP/10

quietly: sum MA7newcasesPOP , d
 scalar contmax = r(max)*1.5
 scalar contmin = r(min)*0.9
 scalar contlabmin = round(r(min),10)
 scalar contlabmax = round(r(max),10)
local contup = contmax 
local contlup = contlabmax 
local contlo = contmin 
local contllo = contlabmin 
display `contup' 
display `contlo'

cap drop barmin barmax
gen barmin = 0
gen barmax = 100

replace MA7newcasesPOP = 0 if MA7newcasesPOP<0

gen MA7contacts_femalemale = MA7contacts_female + MA7contacts_male

foreach V of varlist contacts_female_age1 contacts_female_age2 contacts_female_age3 contacts_male_age1 contacts_male_age2 contacts_male_age3 {
mvsumm `V', gen(MA7`V') stat(mean) window(7) force
}

drop if ddate > mdy(03,31,2021)
 keep if  year >= 2020
 


egen lastday = max(ddate) if helplinecontacts !=.
sort lastday
replace lastday = lastday[1]
format lastday %td
drop if ddate>lastday
sort ddate

# delimit ;
twoway  line MA7newcasesPOP ddate , lcolor(cranberry) lpattern(solid) yaxis(2) lwidth(medthick)
 || line stringencyindex ddate , lcolor(ebblue) lpattern(solid) lwidth(medthick)  yaxis(2)
	|| scatter helplinecontacts ddate , msymbol(o) mcolor(gs0)	msize(vsmall) yaxis(1)
 	|| line MA7helplinecontacts  ddate, lcolor(gs0) lpattern(solid) yaxis(1) lwidth(medthick)
		scheme(s2color) 
		legend(label(4 "Daily helpline calls (7-day moving average)") label(1  "Newly confirmed Covid-19 infections/million population")  label(2 "Government response stringency index")  order(4 2 1) cols(1)  pos(7) ring(1) colfirst size(medsmall)  colgap(30) region(lcolor(white))) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("Index score/cases rate", xoffset(0) axis(2) size(medsmall)) 
		ytitle("Daily calls", xoffset(0) axis(1) size(medsmall) color(gs0) )	
		ylabel(0(20)100, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(2) nogrid) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(medsmall) axis(1) nogrid) 
		yscale( axis(2) titlegap(0)) 	
		yscale( axis(1) titlegap(0))
		xtitle("", yoffset(-2)) 
 		xlabel( , labsize(medsmall) labcolor(gs0) format(%tdMon_CCYY)) 
		xsize(6) ysize(3);
# delimit cr
graph export ".\02_Project\Figures\Overview`C'.pdf", replace

lab var contacts_fears "(i) Fears (incl. of infection)"
lab var contacts_lonely "(ii) Loneliness"
lab var contacts_suicide "(iii) Suicide"
lab var contacts_addiction "(iv) Addiction"
lab var contacts_violence "(v) Violence"
lab var contacts_physhealth "(vi) Physical health"
lab var contacts_T_econ "(vii) Livelihood"
lab var contacts_T_social "(viii) Relationships"

foreach T in fears lonely suicide addiction violence physhealth T_econ T_social {

local titletext: variable label contacts_`T'

# delimit ;
twoway line MA7contacts_`T'  ddate, lcolor(gs0) lpattern(solid) yaxis(1) lwidth(medthin)
		scheme(s2color) 
		legend(off) 
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		title("{bf:`titletext'}", size(vsmall) color(gs0) pos(11) ring(1) span justification(left)) 
		ytitle("")	
		ylabel(, labcolor(gs0) angle(horizontal) labsize(vsmall) axis(1) nogrid) 
		yscale(axis(1) titlegap(0))
		xtitle("", yoffset(-2)) 
 		xlabel( , labsize(vsmall) labcolor(gs0) format(%tdm)) 
		xsize(6) ysize(3) fxsize(100)
		name(gr`T', replace);
# delimit cr
}
graph combine grfears grlonely grsuicide graddiction grviolence grphyshealth grT_econ grT_social, ///
		title("{bf:b) Daily calls by topic (seven-day moving average)}", size(vsmall) color(gs0) pos(11) ring(1) span justification(left)) ///
			xsize(10) ysize(9)	cols(2)  graphregion(color(white) margin(zero)) imargin(medsmall) iscale(0.9) name(grx1, replace) fysize(120)

gen zero = 0

gen cgroup1 = MA7contacts_female_age1
gen cgroup2 = cgroup1 + MA7contacts_female_age2
gen cgroup3 = cgroup2 + MA7contacts_female_age3
gen cgroup4 = cgroup3 + MA7contacts_male_age1
gen cgroup5 = cgroup4 + MA7contacts_male_age2
gen cgroup6 = cgroup5 + MA7contacts_male_age3

# delimit ;
twoway rbar   cgroup6 MA7helplinecontacts ddate, color(ebg) fintensity(100) yaxis(1) lwidth(medthin)
		|| rbar zero cgroup1  ddate, color(dkorange*0.7) fintensity(100) yaxis(1) lwidth(medthin)
		|| rbar cgroup1 cgroup2  ddate, color(dkorange) fintensity(100) yaxis(1) lwidth(medthin)
		|| rbar cgroup2 cgroup3  ddate, color(dkorange*1.3) fintensity(100) yaxis(1) lwidth(medthin)
		|| rbar cgroup3 cgroup4  ddate, color(blue*0.7) fintensity(100) yaxis(1) lwidth(medthin)
		|| rbar cgroup4 cgroup5  ddate, color(blue*1) fintensity(100) yaxis(1) lwidth(medthin)
		|| rbar cgroup5 cgroup6  ddate, color(blue*1.5) fintensity(100) yaxis(1) lwidth(medthin)
		scheme(s2color) legend(label(1 "Unknown") label(2 "0-30") label(3 "30-60") label(4 "60+     Female") label(5 "0-30") label(6 "30-60") label(7 "60+      Male") cols(1)  size(vsmall) pos(2) ring(1) rowgap(0) region(lcolor(white)) order(1 7 6 5 4 3 2))
		graphregion(color(white)) plotregion(color(white)  margin(small)) bgcolor(white) 
		ytitle("")	
		title("{bf:a) Daily calls by age and sex of caller (seven-day moving average)}", size(vsmall) color(gs0) pos(11) ring(1) span justification(left)) 
		ylabel(, labcolor(gs0) angle(horizontal) labsize(vsmall) axis(1) nogrid) 
		yscale(axis(1) titlegap(0))
		xtitle("", yoffset(-2)) 
 		xlabel( , labsize(vsmall) labcolor(gs0) format(%tdMon_YY)) 
		 xsize(10) ysize(5) fysize(40)
		name(gr_female, replace);
# delimit cr


graph combine gr_female grx1, 	cols(1)  graphregion(color(white) margin(small)) imargin(small) iscale(0.9) 	xsize(10) ysize(12)
graph export ".\02_Project\Figures\comb_`C'.pdf", replace


}
