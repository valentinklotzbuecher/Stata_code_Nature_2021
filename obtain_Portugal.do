
// Portugal,  SOS Voz Amiga


/*
global months "Jan Feb Mar Apr May Jun Jul Aug Set Oct Nov Dec"
global monthsX "Feb Mar Apr May Jun Jul Aug Set Oct Nov Dec"

foreach M in $months {
import excel ".\03_Data\Countries\Portugal\2019.xlsx",  firstrow clear sheet(`"`M'"')
gen month = `"`M'"'
gen year = 2019
save `".\03_Data\Countries\Portugal\SOSVozAmiga2019_`M'.dta"',  replace

}

use  ".\03_Data\Countries\Portugal\SOSVozAmiga2019_Jan.dta", clear
foreach M in $monthsX {
append using  `".\03_Data\Countries\Portugal\SOSVozAmiga2019_`M'.dta"'
}
save ".\03_Data\Countries\Portugal\SOSVozAmiga2019.dta"

foreach M in $months {
erase `".\03_Data\Countries\Portugal\SOSVozAmiga2019_`M'.dta"'
}


global months "January February March April May Jun"
global monthsX "February March April May Jun"

foreach M in $months {
import excel ".\03_Data\Countries\Portugal\sos statistics data jan-jun.xlsx",  firstrow clear sheet(`"`M'"')
gen month = `"`M'"'
gen year = 2020
save `".\03_Data\Countries\Portugal\SOSVozAmiga2020_`M'.dta"',  replace
}

use  ".\03_Data\Countries\Portugal\SOSVozAmiga2020_January.dta", clear
foreach M in $monthsX {
append using  `".\03_Data\Countries\Portugal\SOSVozAmiga2020_`M'.dta"'
}

save ".\03_Data\Countries\Portugal\SOSVozAmiga2020.dta",  replace


use  ".\03_Data\Countries\Portugal\SOSVozAmiga2019.dta", clear
append using ".\03_Data\Countries\Portugal\SOSVozAmiga2020.dta"

save ".\03_Data\Countries\Portugal\SOSVozAmiga.dta", replace

erase ".\03_Data\Countries\Portugal\SOSVozAmiga2019.dta"
erase ".\03_Data\Countries\Portugal\SOSVozAmiga2020.dta"
foreach M in $months {
erase `".\03_Data\Countries\Portugal\SOSVozAmiga2020_`M'.dta"'
}
*/


use "$rawdata\Countries\Portugal\SOSVozAmiga.dta", clear

gen day = trim(substr(DayandShift,5,2))

replace month = "Jan" if month == "January"
replace month = "Feb" if month == "February"
replace month = "Mar" if month == "March"
replace month = "Apr" if month == "April"
replace month = "Sep" if month == "Set"

gen ddate = date(day + month + string(year),"DMY")
drop if ddate == .

format ddate %td


gen phone = 1

gen female = .
replace female = 0 if Gender == "Masculino"
replace female = 1 if Gender == "Feminino"

gen male = .
replace male = 1 if Gender == "Masculino"
replace male = 0 if Gender == "Feminino"

gen duration = subinstr(Duration,"-","",.)
replace duration = subinstr(duration,"~","",.)
replace duration = subinstr(duration,"-","",.)
replace duration = subinstr(duration,"\","",.)
replace duration = subinstr(duration,"_","",.)
replace duration = subinstr(duration,",","",.)
replace duration = subinstr(duration,"m","",.)
replace duration = subinstr(duration,"i","",.)
replace duration = "0.5" if duration == "30 seg"
replace duration = "0.25" if duration == "15 seg"
replace duration = substr(duration,3,.) if substr(duration,1,2) == "1h"  
replace duration = substr(duration,3,.) if substr(duration,1,2) == "2h"  

replace duration = "" if substr(duration,3,1) == ":"  ///
				| duration == "16h50"  ///
				| duration == "17h13"  ///
				| duration == "17h51"  ///
				| duration == "18h34" ///
				| duration == "20h41" ///
				| duration == "." 
				
destring duration, replace
replace duration = duration + 60 if substr(Duration,1,2) == "1h"  
replace duration = duration + 120 if substr(Duration,1,2) == "2h"  

lab var duration "Duration (min)"


gen age_0_18   = (Age == "≤ 18" | Age == "14")
gen age_19_35  = (Age == "[18;35]")
gen age_36_45  = (Age == "[36;45]")
gen age_46_55  = (Age == "[46;55]" | Age == "49")
gen age_56_65  = (Age == "[56;65]" | Age == "56/65")
gen age_65plus = (Age == "≥ 65 anos" | Age == ">65" | Age == "69")

lab var age_0_18  	  "Age: 0-18"
lab var age_19_35     "Age: 19-35"
lab var age_36_45     "Age: 36-45"
lab var age_46_55     "Age: 46-55"
lab var age_56_65     "Age: 56-65"
lab var age_65plus     "Age: 66 and older"



foreach V of varlist age* {
replace `V' = . if Age == "s/ informaç"
replace `V' = . if Age == "s/ informação"
replace `V' = . if Age == "Feminino"
replace `V' = . if Age == "-"
}

gen age_min =      0 if age_0_18    == 1
replace age_min = 19 if age_19_35   == 1
replace age_min = 36 if age_36_45   == 1
replace age_min = 46 if age_46_55   == 1
replace age_min = 56 if age_56_65   == 1
replace age_min = 65 if age_65plus  == 1

gen age_max =     18 if age_0_18    == 1
replace age_max = 35 if age_19_35   == 1
replace age_max = 45 if age_36_45   == 1
replace age_max = 55 if age_46_55   == 1
replace age_max = 65 if age_56_65   == 1
replace age_max = 100 if age_65plus  == 1

tab Type 
replace Type = "" if Type == "-"
replace Type = "" if Type == "-"

gen firstcall = 0 if Type != ""
replace firstcall = 1 if lower(Type) == "primeira vez"
gen repcall =  0 if Type != ""
replace repcall = 1 if Type == "Habitual"
replace repcall = 1 if Type == "Repetida"
gen habitcall =  0 if Type != ""
replace habitcall = 1 if Type == "Habitual"




tab Subjectsplacedinthecalls

gen suicide = 0 if Subjectsplacedinthecalls != ""
gen suicidal_thoughts = 0 if Subjectsplacedinthecalls != ""
gen suicidal_attempt = 0 if Subjectsplacedinthecalls != ""
gen suicidal_plan = 0 if Subjectsplacedinthecalls != ""
gen lonely = 0 if Subjectsplacedinthecalls != ""
gen fears = 0 if Subjectsplacedinthecalls != ""
gen violence = 0 if Subjectsplacedinthecalls != ""
gen physhealth = 0 if Subjectsplacedinthecalls != ""
gen mentalhealth = 0 if Subjectsplacedinthecalls != ""
gen sex = 0 if Subjectsplacedinthecalls != ""
gen addiction = 0 if Subjectsplacedinthecalls != ""
gen grief = 0 if Subjectsplacedinthecalls != ""
gen depressed = 0 if Subjectsplacedinthecalls != ""
gen T_social = 0 if Subjectsplacedinthecalls != ""
gen T_econ = 0 if Subjectsplacedinthecalls != ""
gen T_mental = 0 if Subjectsplacedinthecalls != ""

gen topic1 = Subjectsplacedinthecalls
gen topic2 = H
gen topic3 = I

forvalues J=1/3 {
replace suicide = 1 if substr(topic`J',1,1) == "5"
replace suicidal_thoughts = 1 if substr(topic`J',1,3) == "5.1"
replace suicidal_plan = 1 if substr(topic`J',1,3) == "5.2"
replace suicidal_attempt  = 1 if substr(topic`J',1,3) == "5.3"

replace violence = 1 if substr(topic`J',1,3) == "2.3"

replace addiction = 1 if substr(topic`J',1,3) == "4.2"
replace lonely = 1 if substr(topic`J',1,3) == "3.1"
replace fears = 1 if substr(topic`J',1,3) == "3.2"

replace physhealth = 1 if substr(topic`J',1,3) == "4.4"

replace mentalhealth = 1 if substr(topic`J',1,3) == "4.3"
replace grief = 1 if substr(topic`J',1,3) == "3.3"
replace sex = 1 if substr(topic`J',1,3) == "3.4"
replace depressed = 1 if substr(topic`J',1,3) == "4.1"

replace T_social = 1 if substr(topic`J',1,2) == "2." &  substr(topic`J',1,3) != "2.3"
replace T_econ   = 1 if substr(topic`J',1,2) == "1."
}


gen country = "Portugal"

gen population = 10.28

gen helplinename = "S.O.S. Voz Amiga"

gen hour = substr(Hour,1,2)
replace hour = substr(hour,1,1) if substr(hour,2,1) == "h"
replace hour = "0" if hour == "00"
replace hour = "20" if hour == "2O"
destring hour, replace ignore("-")
replace hour = . if hour > 23

		keep ddate-duration  firstcall-helplinename hour age*



save "$rawdata\Countries\Portugal\PRTcontacts.dta",  replace

use "$rawdata\Countries\Portugal\PRTcontacts.dta",  clear






