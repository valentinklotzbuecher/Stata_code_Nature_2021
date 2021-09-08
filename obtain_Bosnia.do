


import excel "$rawdata\Countries\Bosnia Herz\Kopie von Blue phones data.xlsx", firstrow clear 


rename date ddate 
format ddate %td

rename min duration
replace duration = . if phone == 0

rename days mailduration

rename loneliness lonely 

destring female male, replace

rename coronainfo coronacall

rename Sexuality sex

gen addiction = (alcohol == 1 | drugaddiction == 1)

gen agegroup = ""
foreach V in age_0_9 age_10_14 age_15_19 age_20_29 age_30_39 age_40_49 age_50_59 age_60_69 age_70_79 {
replace agegroup = "`V'" if `V' == 1
}
replace agegroup = subinstr(agegroup,"age_","",.)
replace agegroup = subinstr(agegroup,"_","-",.)

gen agemin = substr(agegroup,1,2)
replace agemin = subinstr(agemin,"-","",.)
gen agemax = substr(agegroup,-2,2)
replace agemax = subinstr(agemax,"-","",.)
destring agemax agemin, replace
egen age = rowmean(agemin agemax)

drop ID

sort ddate

gen country = "Bosnia"


gen helplinename = "Plavi Telefon"

gen population = 3.324




drop I age_0_9 age_10_14 age_15_19 age_20_29 age_30_39 age_40_49 age_50_59 age_60_69 age_70_79

save "$rawdata\Countries\Bosnia Herz\Bosnia_contacts", replace


