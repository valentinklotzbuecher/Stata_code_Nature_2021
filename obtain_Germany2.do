
import delimited using "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2019.csv", clear delimiter(";")

save "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2019.dta", replace



import delimited using "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_01.10.20 - 18.02.2021.csv", clear delimiter(";")

save "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2021.dta", replace

import delimited using "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_01-09-2020.csv", clear delimiter(";")
append using "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2019.dta"
append using "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2021.dta"

erase "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2019.dta"
erase "$rawdata\Countries\Germany\Nummer gegen Kummer\ET_Beratungen_2021.dta"



gen population = 83.02 	// million (2019)
gen country = "Germany"
gen helplinename = "Nummer gegen Kummer (Eltern)"

gen ddate = date(date_insert, "DMY")
format ddate %td

gen duration = time_dauer
gen hour = time_begin

gen female = 0 if ang_geschlecht != 3
replace female = 1 if ang_geschlecht == 2
gen male = 0 if ang_geschlecht != 3
replace male = 1 if ang_geschlecht == 1


gen firstcall = 0 if ang_anruftyp != 4
replace firstcall = 1 if ang_anruftyp == 1

gen repcall = 0 if ang_anruftyp != 4
replace repcall = 1 if ang_anruftyp == 2 | ang_anruftyp == 3

gen habitcall = 0 if ang_anruftyp != 4
replace habitcall = 1 if ang_anruftyp == 3


gen agegroup = ""
gen agemax = .
gen agemin = .

replace agegroup  = "unter 15" if ang_anruf_alter == 1
replace agegroup  = "15-19" if ang_anruf_alter == 2
replace agegroup  = "20-24" if ang_anruf_alter == 3
replace agegroup  = "25-29" if ang_anruf_alter == 4 
replace agegroup  = "30-34" if ang_anruf_alter == 5
replace agegroup  = "35-39" if ang_anruf_alter == 6
replace agegroup  = "40-44" if ang_anruf_alter == 7
replace agegroup  = "45-49" if ang_anruf_alter == 8
replace agegroup  = "50-54" if ang_anruf_alter == 9
replace agegroup  = "55-59" if ang_anruf_alter == 10
replace agegroup  = "60-64" if ang_anruf_alter == 11
replace agegroup  = "65-69" if ang_anruf_alter == 12
replace agegroup  = "70-74" if ang_anruf_alter == 13
replace agegroup  = "über 75" if ang_anruf_alter == 14

replace agemin  = 0 if ang_anruf_alter == 1
replace agemin  = 15 if ang_anruf_alter == 2
replace agemin  = 20 if ang_anruf_alter == 3
replace agemin  = 25 if ang_anruf_alter == 4 
replace agemin  = 30 if ang_anruf_alter == 5
replace agemin  = 35 if ang_anruf_alter == 6
replace agemin  = 40 if ang_anruf_alter == 7
replace agemin  = 45 if ang_anruf_alter == 8
replace agemin  = 50 if ang_anruf_alter == 9
replace agemin  = 55 if ang_anruf_alter == 10
replace agemin  = 60 if ang_anruf_alter == 11
replace agemin  = 65 if ang_anruf_alter == 12
replace agemin  = 70 if ang_anruf_alter == 13
replace agemin  = 75 if ang_anruf_alter == 14

replace agemax  = 14  if ang_anruf_alter == 1
replace agemax  = 19  if ang_anruf_alter == 2
replace agemax  = 24  if ang_anruf_alter == 3
replace agemax  = 29  if ang_anruf_alter == 4 
replace agemax  = 34  if ang_anruf_alter == 5
replace agemax  = 39  if ang_anruf_alter == 6
replace agemax  = 44  if ang_anruf_alter == 7
replace agemax  = 49  if ang_anruf_alter == 8
replace agemax  = 54  if ang_anruf_alter == 9
replace agemax  = 59  if ang_anruf_alter == 10
replace agemax  = 64  if ang_anruf_alter == 11
replace agemax  = 69  if ang_anruf_alter == 12
replace agemax  = 74  if ang_anruf_alter == 13
replace agemax  = 100  if ang_anruf_alter == 14

egen age = rowmean(agemax agemin)
 
gen migrant = . if ang_nationalitaet == 3
replace migrant = 1 if ang_nationalitaet == 1
replace migrant = 0 if ang_nationalitaet == 2

gen statecode = bundes_land_id
gen centercode = location_id

gen state = ""
replace state = "Baden-Württemberg" if statecode == 1
replace state = "Bayern" if statecode == 2
replace state = "Berlin" if statecode == 3
replace state = "Bremen" if statecode == 4
replace state = "Hamburg" if statecode == 5
replace state = "Hessen" if statecode == 6
replace state = "Mecklenburg-Vorpommern" if statecode == 7
replace state = "Niedersachsen" if statecode == 8
replace state = "Nordrhein-Westfalen" if statecode == 9
replace state = "Rheinland-Pfalz" if statecode == 10
replace state = "Sachsen" if statecode == 12
replace state = "Sachsen-Anhalt" if statecode == 13
replace state = "Schleswig-Holstein" if statecode == 14
replace state = "Saarland" if statecode == 15
replace state = "Brandenburg" if statecode == 16






sum  ang_kinder_leben_anruf ang_soz_fam_stand ang_soz_finanzen ang_kinder_anzahl ang_kinder_maenlich ang_kinder_m_alter_1 ang_kinder_m_alter_2 ang_kinder_m_alter_3 ang_kinder_m_alter_4 ang_kinder_m_alter_5 ang_kinder_m_alter_6 ang_kinder_m_alter_7 ang_kinder_m_alter_8 ang_kinder_m_alter_9 ang_kinder_weiblich ang_kinder_w_alter_1 ang_kinder_w_alter_2 ang_kinder_w_alter_3 ang_kinder_w_alter_4 ang_kinder_w_alter_5 ang_kinder_w_alter_6 ang_kinder_w_alter_7 ang_kinder_w_alter_8 ang_kinder_w_alter_9

gen relation2child = ang_soz_bezug_kind
lab def reltions 1 "Parents" 2 "Foster parents" 3 "Partners of parent" 4 "Grandparents" 5 "Other relatives" 6 "Friends" 7 "Neighbors" 8 "Teachers" 9 "Other"
lab val relation2child reltions
* tab relation2child if year == 2020	// checked with official 2020 ET statistics


egen a_e_prob_sum = rowtotal(a_e_prob_*)
sum a_e_prob_* if year == 2020 & a_e_prob_sum>0		// checked with fig.5.2.1 in ET stats


lab var a_e_prob_1 "Eltern-Kind-Bezieh"
lab var a_e_prob_2 "Überforderung/Hilflosigkeit" 
lab var a_e_prob_3 "ausgebrannt" 
lab var a_e_prob_4  "Selbstvertrauen/Unsicherheit" 
lab var a_e_prob_5 "soz. Isolation/Einsamkeit" 
lab var a_e_prob_6 "körperl. Probleme" 
lab var a_e_prob_7 "psych. Probleme" 
lab var a_e_prob_8 "Suchtprobleme" 
lab var a_e_prob_9  "fehlende Unterstütung Partner/in" 
lab var a_e_prob_10 "Trennung/Scheidung" 
lab var a_e_prob_11 "häusliche Gewalt" 
lab var a_e_prob_12 "Armutsproblematik" 
lab var a_e_prob_13 "Arbeitslosigkeit" 
lab var a_e_prob_14  "Betreuung Kinder" 
lab var a_e_prob_15 "Fremdunterbr. der Kinder" 
lab var a_e_prob_16 "Verlust Angehörige" 
lab var a_e_prob_17 "Schwangerschaft" 
lab var a_e_prob_18 "Probleme Haushalt" 
lab var a_e_prob_19 "Sonstige eigene P."
                 

* Topcs based on problems of caller!
gen violence = (a_e_prob_11 == 1)
tab violence if year == 2020 & a_e_prob_sum>0		// checked with fig.5.2.1 in ET stats

gen lonely = (a_e_prob_5 == 1)
tab lonely if year == 2020 & a_e_prob_sum>0		

gen physhealth = (a_e_prob_6 == 1)
tab physhealth if year == 2020 & a_e_prob_sum>0	

gen addiction = (a_e_prob_8 == 1)
tab addiction if year == 2020 & a_e_prob_sum>0	

gen T_econ = (a_e_prob_12  == 1 | a_e_prob_13 == 1)
tab T_econ if year == 2020 & a_e_prob_sum>0		

gen T_social = (a_e_prob_1  == 1 | a_e_prob_9  == 1 | a_e_prob_10  == 1 | a_e_prob_14 == 1 |  a_e_prob_15 == 1)
tab T_social if year == 2020 & a_e_prob_sum>0	


egen b_prob_sum = rowtotal(b_prob_*)
sum b_prob_* if year == 2020 & b_prob_sum>0		// checked with fig.5.2.5 in ET stats

lab var b_prob_1 "Selbstvertrau./Ängstlichkeit"
lab var b_prob_2  "Lügen"
lab var b_prob_3  "Hygiene/Sauberkeit"
lab var b_prob_4  "ADS/Konzentrationsschw."
lab var b_prob_5  "Schlafstörung"
lab var b_prob_7   "psych. Probleme"
lab var b_prob_8  "Drogen(-sucht)"
lab var b_prob_9  "Essstörung"
lab var b_prob_10 "Selbstverletzung"
lab var b_prob_11  "Krankheit, Behinderung"
lab var b_prob_20  "Sonstige Gesundheit"

gen child_addiction = (b_prob_8 == 1)
tab child_addiction if year == 2020 & b_prob_sum>0	// checked with fig.5.2.5 in ET stats



egen b_gewalt_sum = rowtotal(b_gewalt_*)
sum b_gewalt_* if year == 2020 & b_gewalt_sum>0		// checked with fig.5.2.7 in ET stats

lab var  b_gewalt_1  "Aggressionen"
lab var  b_gewalt_2  "Wut (-anfälle)"
lab var  b_gewalt_3  "psych. Gewalt"
lab var  b_gewalt_4  "körpl. Gewalt"
lab var  b_gewalt_5  "häusliche Gewalt"
lab var  b_gewalt_6  "Vernachlässigt"
lab var  b_gewalt_8  "Baby schütteln"
lab var  b_gewalt_9  "Suizidgedank./-versuch"
lab var  b_gewalt_10 "sexuelle Übergriffe"
lab var  b_gewalt_11 "sexueller Missbrauch"
lab var  b_gewalt_20 "Sonstige Gewalt"

gen child_violence = (b_prob_3 == 1 | b_prob_4== 1 | b_prob_5 == 1 | b_prob_8 == 1 | b_prob_10 == 1 | b_prob_11 == 1 | b_prob_20 == 1 )

gen child_suicide = (b_prob_9 == 1)


replace addiction = 1 if child_addiction == 1

gen suicide = child_suicide

replace violence = 1 if child_violence == 1





gen coronacall = 0 if ddate>mdy(3,31,2020)
replace coronacall = 1 if zb_3_yes ==1
 
tab coronacall if year == 2020





drop migrant centercode a_e_prob_sum b_prob_sum b_gewalt_sum

keep population-suicide


save "$rawdata\Countries\Germany\Nummer gegen Kummer\ET.dta", replace




* Kinder/Jugendtelefon:




usespss "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_beratungen_2019.sav", clear

gen _Nid = _n
 save "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019SPSS.dta", replace

import delimited using "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019.csv", clear delimiter(";")
gen ddate = date(date_insert, "YMD")
format ddate %td

gen _Nid = _n
merge 1:1 _Nid using "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019SPSS.dta", nogen

lab values ang_a_geschlecht SEX

decode KJTNR, gen(center)

save "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019.dta", replace


import delimited using "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT-Beratungen_01-09-2020.csv", clear delimiter(";")
gen ddate = date(date_insert, "YMD")
format ddate %td
save "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2020.dta", replace

import delimited using "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_01.10.20 - 18.02.2021.csv", clear delimiter(";")
gen ddate = date(date_insert, "DMY")
format ddate %td
save "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2021.dta", replace

append using "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019.dta"
append using "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2020.dta"


erase "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019.dta"
erase "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2020.dta"
erase "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2021.dta"
erase "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_Beratungen_2019SPSS.dta"


save "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_beratungen_RAW.dta", replace


//
 use "$rawdata\Countries\Germany\Nummer gegen Kummer\KJT_beratungen_RAW.dta", clear


 

gen helplinename = "Nummer gegen Kummer (Kinder/Jugend)"


gen population = 83.02 	// million (2019)
gen country = "Germany"

decode BL, gen(state)

bysort bundes_land_id location_id (BL): carryforward center, replace
bysort bundes_land_id location_id (BL): carryforward state, replace

gen duration = time_dauer
gen hour = time_begin
gen female = 0 if ang_a_geschlecht != 4
replace female = 1 if ang_a_geschlecht == 1		//  !!!!!!!!!!!!!!!!!!
gen male = 0 if ang_a_geschlecht != 4
replace male = 1 if ang_a_geschlecht == 2		//  !!!!!!!!!!!!!!!!!!
gen diverse = 0 if ang_a_geschlecht != 4
replace diverse = 1 if ang_a_geschlecht == 3

gen agegroup = string(ang_a_alter)
replace agegroup  = "<8" if ang_a_alter == 1
replace agegroup  = ">25" if ang_a_alter == 111
replace agegroup  = agegroup + " (estimated)" if ang_a_alter_angegeben == 1

gen age = ang_a_alter
replace age = .  if ang_a_alter == 1
replace age   = . if ang_a_alter == 111
gen agemax = age
replace agemax   = 7 if ang_a_alter == 1
gen agemin = age
replace agemin   = 26 if ang_a_alter == 111


/* Daueranrufer*in
Daueranrufer*innen sind den meisten von Ihnen bekannt. Wenn der Gesprächspartner Ihnen persönlich (oder auch aus der Supervision durch Gespräche mit anderen Berater*innen aus dem Team) bekannt ist, markieren Sie das bitte hier. „Unbekannt" ist hier im Sinne von „vielleicht" gemeint
*/
tab ang_a_daueranrufer, m

gen repcall = 0 if ang_a_daueranrufer == 2
replace repcall = 1 if ang_a_daueranrufer == 1


gen migrant = .
replace migrant = 0 if migrationhinter != 3
replace migrant = 1 if migrationhinter == 1

gen suddenstop = 0 if gespr_ende  == 2
replace suddenstop= 1 if gespr_ende  == 1

gen dropped = 0 if gespr_ende_opt  == 0
replace dropped= 1 if gespr_ende_opt  == 2
replace dropped= 0 if gespr_ende_opt  == 1





* Caller info general
* Info on person callers are concerned/worried about
gen concern_other = 0
replace concern_other = 1 if ang_a_sorge == 1

gen concern_female = 0 if ang_a_s_geschlecht != 4 & ang_a_s_geschlecht != 0
replace concern_female = 1 if ang_a_s_geschlecht == 2
gen concern_male = 0 if ang_a_s_geschlecht != 4 & ang_a_s_geschlecht != 0
replace concern_male = 1 if ang_a_s_geschlecht == 1

gen concern_agegroup = string(ang_a_s_alter) if ang_a_s_alter != 0
replace concern_agegroup  = "<8" if ang_a_s_alter == 1
replace concern_agegroup  = ">25" if ang_a_s_alter == 111
replace concern_agegroup  = concern_agegroup + " (estimated)" if ang_a_s_alter_angegeben == 2

gen concern_age = ang_a_s_alter
replace concern_age = .  if ang_a_s_alter == 0
replace concern_age = .  if ang_a_s_alter == 1
replace concern_age   = . if ang_a_s_alter == 111
gen concern_agemax = concern_age
replace concern_agemax   = 7 if ang_a_s_alter == 1
gen concern_agemin = concern_age
replace concern_agemin   = 26 if ang_a_s_alter == 111


gen ptwith_self = 0 
replace ptwith_self = 1 if anruf_thema_problem == 1
gen ptwith_youngp = 0 
replace ptwith_youngp = 1 if anruf_thema_problem == 2
gen ptwith_adultp = 0 
replace ptwith_adultp = 1 if anruf_thema_problem == 3
 
gen ptwith_y_siblings = 0 
replace ptwith_y_siblings = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 1
gen ptwith_y_bestfriend = 0 
replace ptwith_y_bestfriend = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 2
gen ptwith_y_partner = 0 
replace ptwith_y_partner = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 3
gen ptwith_y_friends = 0 
replace ptwith_y_friends = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 4
gen ptwith_y_classmate = 0 
replace ptwith_y_classmate = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 5
gen ptwith_y_online = 0 
replace ptwith_y_online = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 6
gen ptwith_y_other = 0 
replace ptwith_y_other = 1 if anruf_thema_problem == 2 & anruf_thema_problem_opt == 7

gen ptwith_a_parents = 0 
replace ptwith_a_parents = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 1
gen ptwith_a_father = 0 
replace ptwith_a_father = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 2
gen ptwith_a_mother = 0 
replace ptwith_a_mother = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 3
gen ptwith_a_prntpartner = 0 
replace ptwith_a_prntpartner = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 4
gen ptwith_a_family = 0 
replace ptwith_a_family = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 5
gen ptwith_a_teacher = 0 
replace ptwith_a_teacher = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 6
gen ptwith_a_other = 0 
replace ptwith_a_other = 1 if anruf_thema_problem == 3 & anruf_thema_problem_opt == 7

gen problemwith = "" 
replace problemwith = "Self" if anruf_thema_problem == 1
replace problemwith = "Children/minors" if anruf_thema_problem == 2
replace problemwith = "Adults" if anruf_thema_problem == 3

gen problemwith_detail = "" 
replace problemwith_detail = "Siblings" if  ptwith_y_siblings == 1
replace problemwith_detail = "Best friend" if  ptwith_y_bestfriend == 1
replace problemwith_detail = "Partner" if ptwith_y_partner  == 1
replace problemwith_detail = "Friends" if ptwith_y_friends  == 1
replace problemwith_detail = "Classmates" if ptwith_y_classmate  == 1
replace problemwith_detail = "Online" if ptwith_y_online  == 1
replace problemwith_detail = "Other children/minors" if ptwith_y_other  == 1
replace problemwith_detail = "Parents" if ptwith_a_parents  == 1
replace problemwith_detail = "Father " if ptwith_a_father  == 1
replace problemwith_detail = "Mother " if ptwith_a_mother  == 1
replace problemwith_detail = "Partner of parent" if ptwith_a_prntpartner  == 1
replace problemwith_detail = "Family " if ptwith_a_family  == 1
replace problemwith_detail = "Teacher" if ptwith_a_teacher  == 1
replace problemwith_detail = "Other adults" if ptwith_a_other  == 1

foreach J of numlist 1/15 {
	replace gewalt_`J' = gewalt_`J'/`J'
	replace sucht_`J' = sucht_`J'/`J'
}

*sum gewalt_1  gewalt_2 gewalt_3 gewalt_4 gewalt_5 gewalt_6 gewalt_7 gewalt_8 gewalt_9 gewalt_10 gewalt_11 gewalt_12 gewalt_13 gewalt_14 gewalt_15  ETG6X1-ETG6X15 sumth6 val6 if year(ddate) == 2019

egen violsum = rowtotal(gewalt_1 gewalt_2 gewalt_3 gewalt_4 gewalt_5 gewalt_6 gewalt_7 gewalt_8 gewalt_9 gewalt_10 gewalt_11 gewalt_12 gewalt_13 gewalt_14 gewalt_15 )

gen t_viol_psych = (gewalt_1 ==1)
lab var t_viol_psych "Psychological violence"
gen t_viol_phys = (gewalt_2 ==1)
lab var t_viol_phys "Physical violence"
gen t_viol_sex = (gewalt_3 ==1 | gewalt_5 ==1 | gewalt_11 ==1)
lab var t_viol_sex "Sexual violence"
gen t_viol_other = (violsum > 0 & t_viol_psych == 0 & t_viol_phys == 0 & t_viol_sex == 0)
lab var t_viol_other "Other violence"


foreach J of numlist 1/10 {
	replace sonst_pers_themen_`J' = sonst_pers_themen_`J'/`J'
}

gen t_psysoc_body = (sonst_pers_themen_1 ==1)
lab var t_psysoc_body "Body/appearance"
gen t_psysoc_diesease = (sonst_pers_themen_2 ==1)
lab var t_psysoc_diesease "Disease/disability"
gen t_psysoc_grief = (sonst_pers_themen_3 ==1)
lab var t_psysoc_grief "Grief/loss"
gen t_psysoc_lonely = (sonst_pers_themen_4 ==1)
lab var t_psysoc_lonely "Loneliness"
gen t_psysoc_bored = (sonst_pers_themen_5 ==1)
lab var t_psysoc_bored "Boredom"
gen t_psysoc_leisure = (sonst_pers_themen_6 ==1)
lab var t_psysoc_leisure "Leisure/hobbies"
gen t_psysoc_fear = (sonst_pers_themen_7 ==1)
lab var t_psysoc_fear "Fear/anxiety"
gen t_psysoc_conf = (sonst_pers_themen_8 ==1)
lab var t_psysoc_conf "Confidence"
gen t_psysoc_ident = (sonst_pers_themen_9 ==1)
lab var t_psysoc_ident "Identity"
gen t_psysoc_psychprob = (sonst_pers_themen_10 ==1)
lab var t_psysoc_psychprob "Psychological problems"


egen tsum = rowtotal(t_psysoc_body-t_psysoc_psychprob)

tab t_psysoc_body if year(ddate) == 2020 & tsum >0
sum t_psysoc_body-t_psysoc_psychprob if year(ddate) == 2020 & tsum >0


lab var user_m_w "NgK staff sex"
lab val user_m_w MITSEX

gen user_female = 0 if user_m_w == 2
replace user_female = 1 if user_m_w == 1
lab var user_female "Female NgK staff"

egen addicsum = rowtotal(sucht_1 sucht_2 sucht_3  sucht_6 sucht_7 sucht_8 sucht_9 sucht_10 sucht_11 sucht_12 sucht_13 sucht_14 sucht_15)


*sum sucht_* ETG9X1 ETG9X2 ETG9X3 ETG9X4 ETG9X5 ETG9X6 ETG9X7 ETG9X8 ETG9X9 ETG9X10 ETG9X11 ETG9X12 ETG9X13 ETG9X14 ETG9X15 if year(ddate) == 2019 

gen t_add_drugs = (sucht_1 ==1)
lab var t_add_drugs "Drugs/drug addiction"
gen t_add_alc = (sucht_2 ==1)
lab var t_add_alc "Alcohol"
gen t_add_tobac = (sucht_3 ==1)
lab var t_add_tobac "Tobacco"
gen t_add_selfharm = (sucht_5 ==1)
lab var t_add_selfharm "Self harm"
gen t_add_suic = (sucht_6 ==1)
lab var t_add_suic "Suicide"
gen t_add_obese = (sucht_12 ==1)
lab var t_add_obese "Obesity"
gen t_add_anorex = (sucht_11 ==1)
lab var t_add_anorex "Anorexia"


foreach J of numlist 1/15 {
	replace probl_familie_`J' = probl_familie_`J'/`J'
}

*sum probl_familie_* ETG3X15 ETG4X1 ETG4X2 ETG4X3 ETG4X4 ETG4X5 ETG4X6 ETG4X7 ETG4X8 ETG4X9 ETG4X10 ETG4X11 ETG4X12 ETG4X13 ETG4X14 ETG4X15 if year(ddate) == 2019 
egen fsum = rowtotal(probl_familie_*)

gen t_fam_rules = (probl_familie_1 ==1)
lab var t_fam_rules "Rules/restrictions/opinions"
gen t_fam_childpar = (probl_familie_2 ==1)
lab var t_fam_childpar "Child-parent relations"
gen t_fam_siblgns = (probl_familie_3 ==1)
lab var t_fam_siblgns "Problems with siblings"
gen t_fam_supp = (probl_familie_4 ==1)
lab var t_fam_supp "Support"
gen t_fam_parconf = (probl_familie_5 ==1)
lab var t_fam_parconf "Conflicts of parents/separation/divorce"
gen t_fam_loss = (probl_familie_6 ==1)
lab var t_fam_loss "Grief/loss in family"
gen t_fam_health = (probl_familie_7 ==1)
lab var t_fam_health "Addiction/mental/pysical health of relatives"
gen t_fam_povrty = (probl_familie_8 ==1)
lab var t_fam_povrty "Poverty"
gen t_fam_exhousng = (probl_familie_9 ==1)
lab var t_fam_exhousng "External housing"
gen t_fam_care = (probl_familie_11 ==1)
lab var t_fam_care "Caring for relatives"
gen t_fam_other = (probl_familie_15 ==1)
lab var t_fam_other "Other family issues"

tab t_fam_health  if year(ddate) == 2020 & fsum > 0	// compare to 2020 NgK statistics -- identical

/////////////////////////////

foreach J of numlist 1/15 {
	replace partner_u_liebe_`J' = partner_u_liebe_`J'/`J'
}
egen lsum = rowtotal(partner_u_liebe_*)
*sum partner_u_liebe_* ETG2X1-ETG2X15 if year(ddate) == 2019 


gen t_love_crush = (partner_u_liebe_1 ==1)
lab var t_love_crush "Crush/in love"
gen t_love_contwish = (partner_u_liebe_2 ==1)
lab var t_love_contwish "Looking for contact"
gen t_love_heart = (partner_u_liebe_3 ==1)
lab var t_love_heart "Heartache"
gen t_love_parship = (partner_u_liebe_4 ==1)
lab var t_love_parship "Forming relationship"
gen t_love_relconf = (partner_u_liebe_5 ==1)
lab var t_love_relconf "Conflict in relationship"
gen t_love_jealous = (partner_u_liebe_6 ==1)
lab var t_love_jealous "Jealousy"
gen t_love_separat = (partner_u_liebe_7 ==1)
lab var t_love_separat "Separation (wish)"
gen t_love_left = (partner_u_liebe_8 ==1)
lab var t_love_left "Left by partner"
gen t_love_distrel = (partner_u_liebe_15 ==1)
lab var t_love_distrel "Distance relationship"
gen t_love_infid = (partner_u_liebe_10 ==1)
lab var t_love_infid "Affairs/infidelity"
gen t_love_other = (partner_u_liebe_11 ==1)
lab var t_love_other "Other relationship/love issues"
/////////////////////////////

foreach J of numlist 1/15 {
	replace clique_freund_peer_`J' = clique_freund_peer_`J'/`J'
}
egen csum = rowtotal(clique_freund_peer_*)
*sum clique_freund_peer_* ETG3X1-ETG3X15 if year(ddate) == 2019 

gen t_peer_frndsearch = (clique_freund_peer_1 ==1)
lab var t_peer_frndsearch "Looking for friend(s)"
gen t_peer_conf = (clique_freund_peer_2 ==1)
lab var t_peer_conf "Conflict with friends"
gen t_peer_comp = (clique_freund_peer_3 ==1)
lab var t_peer_comp "Competition/envy"
gen t_peer_loyal = (clique_freund_peer_4 ==1)
lab var t_peer_loyal "Loyalty"
gen t_peer_outsdr = (clique_freund_peer_5 ==1)
lab var t_peer_outsdr "Outsider"
gen t_peer_mobb = (clique_freund_peer_6 ==1)
lab var t_peer_mobb "Mobbing/exclusion by peers"
gen t_peer_loss = (clique_freund_peer_7 ==1)
lab var t_peer_loss "Loss of friends (moving etc.)"
gen t_peer_statsym = (clique_freund_peer_10 ==1)
lab var t_peer_statsym "Status symbols"
gen t_peer_prssre = (clique_freund_peer_11 ==1)
lab var t_peer_prssre "Peer pressure"
gen t_peer_dare = (clique_freund_peer_12 ==1)
lab var t_peer_dare "Dare/test of courage"
gen t_peer_other = (clique_freund_peer_15 ==1)
lab var t_peer_other "Other peer issues"

tab t_peer_statsym  if year(ddate) == 2020 & csum > 0	// compare to 2020 NgK statistics -- identical

/////////////////////////////

foreach J of numlist 1/15 {
	replace sexualitaet_`J' = sexualitaet_`J'/`J'
	replace eigene_lebenssituation_`J' = eigene_lebenssituation_`J'/`J'
	replace schule_ausbildung_`J' = schule_ausbildung_`J'/`J' 
}
*sum sexualitaet_* ETG5X1 ETG5X2 ETG5X3 ETG5X4 ETG5X5 ETG5X6 ETG5X7 ETG5X8 ETG5X9 ETG5X10 ETG5X11 ETG5X12 ETG5X13 ETG5X14 ETG5X15 if year(ddate) == 2019 

gen t_sex_info = (sexualitaet_1 ==1)
lab var t_sex_info "Body/development/sexuality information"
gen t_sex_contrcptn = (sexualitaet_2 ==1)
lab var t_sex_contrcptn "Contraception"
gen t_sex_ftime = (sexualitaet_3 ==1)
lab var t_sex_ftime "The first time"
gen t_sex_preg = (sexualitaet_4 ==1)
lab var t_sex_preg "Pregnancy"
gen t_sex_orient = (sexualitaet_5 ==1)
lab var t_sex_orient "Sexual orientation"
gen t_sex_mast = (sexualitaet_6 ==1)
lab var t_sex_mast "Masturbation"
gen t_sex_pract = (sexualitaet_7 ==1)
lab var t_sex_pract "Sexual practices"
gen t_sex_risk = (sexualitaet_8 ==1)
lab var t_sex_risk "Risks (HIV/STDs/prevention)"
gen t_sex_phant = (sexualitaet_10 ==1)
lab var t_sex_phant "Sexual phantasies"
gen t_sex_abort = (sexualitaet_11 ==1)
lab var t_sex_abort "Abortion"
gen t_sex_other = (sexualitaet_15 ==1)
lab var t_sex_other "Other sex-related issues"

egen ssum = rowtotal(sexualitaet_*)

*tab t_sex_preg  if year(ddate) == 2020 & ssum > 0	// compare to 2020 NgK statistics -- identical

egen livsum = rowtotal(eigene_lebenssituation_*)

*sum eigene_lebenssituation_* ETG7* if year(ddate) == 2019 

gen t_livsit_runawy = (eigene_lebenssituation_1 ==1)
lab var t_livsit_runawy "Runaway/street children"
gen t_livsit_law = (eigene_lebenssituation_2 ==1)
lab var t_livsit_law "Conflict with law/authorities"
gen t_livsit_radicl = (eigene_lebenssituation_4 ==1)
lab var t_livsit_radicl "Radicalism/extremism"
gen t_livsit_envir = (eigene_lebenssituation_5 ==1)
lab var t_livsit_envir "Living situation/environment"
gen t_livsit_opport = (eigene_lebenssituation_7 ==1)
lab var t_livsit_opport "Education/work opportunities"
gen t_livsit_fearfut = (eigene_lebenssituation_8 ==1)
lab var t_livsit_fearfut "Fear of future"
gen t_livsit_relig = (eigene_lebenssituation_11 ==1)
lab var t_livsit_relig "Religion"
gen t_livsit_racism = (eigene_lebenssituation_12 ==1)
lab var t_livsit_racism "Racism/xenophobia"
gen t_livsit_asylm = (eigene_lebenssituation_13 ==1)
lab var t_livsit_asylm "Asylum/refugees"
gen t_livsit_safinet = (eigene_lebenssituation_14 ==1)
lab var t_livsit_safinet "Safer Internet"
gen t_livsit_other = (eigene_lebenssituation_15 ==1)
lab var t_livsit_other "Other living sit. issues"

egen schsum = rowtotal(schule_ausbildung_*)
  
*sum schule_ausbildung_* ETG8* if year(ddate) == 2019 

gen t_school_grades = (schule_ausbildung_1 ==1)
lab var t_school_grades "Bad grades"
gen t_school_teachr = (schule_ausbildung_2 ==1)
lab var t_school_teachr "Problems with teachers"
gen t_school_clssmts = (schule_ausbildung_3 ==1)
lab var t_school_clssmts "Conflict with classmates"
gen t_school_mobb = (schule_ausbildung_4 ==1)
lab var t_school_mobb "Mobbing/exclusion"
gen t_school_overld = (schule_ausbildung_7 ==1)
lab var t_school_overld "Overload/pressure to perform"
gen t_school_learn = (schule_ausbildung_8 ==1)
lab var t_school_learn "Learning difficulties"
gen t_school_work = (schule_ausbildung_9 ==1)
lab var t_school_work "Problems in apprenticeship/at work"
gen t_school_skip = (schule_ausbildung_10 ==1)
lab var t_school_skip "Truancy/skipping school"
gen t_school_swtch = (schule_ausbildung_11 ==1)
lab var t_school_swtch "School switch"
gen t_school_fearfail = (schule_ausbildung_12 ==1)
lab var t_school_fearfail "Fears of failure"
gen t_school_other = (schule_ausbildung_15 ==1)
lab var t_school_other "Other school problems"

tab t_school_overld  if year(ddate) == 2020 & schsum > 0	// compare to 2020 NgK statistics -- identical


** Broad topics:
gen t_addiction = (addicsum>0 & addicsum!=.)

gen t_school = (schsum>0 & schsum!=.)

gen t_livsit = (livsum>0 & livsum!=.)

gen t_fam =  (fsum>0 & fsum!=.)

gen t_love =  (lsum>0 & lsum!=.)

gen t_peer =  (csum>0 & csum!=.)

gen t_psysoc =  (tsum>0 & tsum!=.)

gen t_sex =  (ssum>0 & ssum!=.)

gen t_viol =  (violsum>0 & violsum!=.)

sum t_addiction t_school t_livsit t_fam t_love t_peer t_psysoc t_sex t_viol

lab var t_school "School and education"
lab var t_addiction "Addiction and harmful behavior"
lab var t_livsit "Living situation and socio-political topics"
lab var t_fam "Problems in Family"
lab var t_love "Love and relationship"
lab var t_sex "Sexuality"
lab var t_psysoc "Psycho-social topics and health"
lab var t_peer "Friends and peer group"
lab var t_viol "Violence and abuse"


/////////////////////////////

gen coronacall = 0 if ddate>mdy(3,31,2020)
replace coronacall = 1 if zb_3_yes ==1
 
gen corona_lonely = 0 if ddate>mdy(3,31,2020)
replace corona_lonely = 1 if zb_3_1 ==1
 
gen corona_domviol = 0 if ddate>mdy(3,31,2020)
replace corona_domviol = 1 if zb_3_2 ==2

gen corona_famlyconfl = 0 if ddate>mdy(3,31,2020)
replace corona_famlyconfl = 1 if zb_3_3 ==3

gen corona_bored = 0 if ddate>mdy(3,31,2020)
replace corona_bored = 1 if zb_3_4 ==4

gen corona_psychstablty = 0 if ddate>mdy(3,31,2020)
replace corona_psychstablty = 1 if zb_3_5 ==5

gen corona_school = 0 if ddate>mdy(3,31,2020)
replace corona_school = 1 if zb_3_6 ==6

gen corona_worrdothers = 0 if ddate>mdy(3,31,2020)
replace corona_worrdothers = 1 if zb_3_7 ==7

gen corona_fearinfect = 0 if ddate>mdy(3,31,2020)
replace corona_fearinfect = 1 if zb_3_8 ==8

gen corona_fearloss = 0 if ddate>mdy(3,31,2020)
replace corona_fearloss = 1 if zb_3_9 ==9

gen corona_insecurty = 0 if ddate>mdy(3,31,2020)
replace corona_insecurty = 1 if zb_3_10 ==10

gen corona_anger = 0 if ddate>mdy(3,31,2020)
replace corona_anger = 1 if zb_3_11 ==11

gen corona_fearfuture = 0 if ddate>mdy(3,31,2020)
replace corona_fearfuture = 1 if zb_3_12 ==12

 lab var ddate "Date (daily)"
lab var center "Helpline center (city/county)"
lab var jbj "'Jugend berät Jugend'"
lab var age "Approx. age"
lab var agegroup "Age group of caller"
lab var duration "Call duration (min)"
lab var hour "Time of call (hour)"
lab var user_id "NgK staff ID"
lab var female "Female"
lab var male "Male"
lab var diverse "Diverse"
lab var repcall "Frequent caller"


lab var coronacall "COVID-19 pandemic related"
lab var corona_lonely "Pandemic - loneliness"
lab var corona_domviol "Pandemic - domestic violence"
lab var corona_famlyconfl "Pandemic - family conflicts"
lab var corona_school "Pandemic - school/learning"
lab var corona_insecurty "Pandemic - insecurity"
lab var corona_anger "Pandemic - anger"
lab var corona_bored "Pandemic - boredom"
lab var corona_psychstablty "Pandemic - psych. stability"
lab var corona_worrdothers "Pandemic - worry about others"
lab var corona_fearinfect "Pandemic - fear of infection"
lab var corona_fearloss "Pandemic - fear of loss"
lab var corona_fearfuture "Pandemic - fear of future"
 lab var migrant "Migration background"
 lab var suddenstop "Conversation ended abruptly"  
 lab var dropped "Dropped by caller" 
 lab var concern_other "Worried about another person"
 lab var concern_female "Worried about: female"
 lab var concern_male "Worried about: male"
 lab var concern_agegroup "Worried about: age group"
 lab var concern_age "Worried about: approx. age"
 lab var problemwith "Problem with others (broad)"
 lab var problemwith_detail "Problem with others (detail)"

order helplinename ddate location_id center bundes_land_id state user_id user_female jbj duration hour female-repcall migrant-corona_fearfuture

drop id-TrauDich
*drop ptwith_self-ptwith_a_other
 
 
 egen topisknown = rowtotal(t_addiction t_school t_livsit t_fam t_love t_peer t_psysoc t_sex)
 replace topisknown = (topisknown!=0)
 
 
 

rename state Bundesland
bysort bundes_land_id : carryforward Bundesland, replace

 
 
gen suicide = t_add_suic


gen fears = t_psysoc_fear

gen lonely =  t_psysoc_lonely


gen physhealth = t_psysoc_diesease
replace physhealth = 1 if t_fam_health == 1 

gen addiction = (t_add_drugs == 1 | t_add_alc == 1 | t_add_tobac == 1 )

gen violence = ( violsum>0 )

gen T_social = (t_fam_rules == 1 | t_fam_childpar == 1 | t_fam_siblgns == 1 | t_fam_supp == 1 | t_fam_parconf == 1 | t_fam_care == 1 | t_fam_other == 1 | t_love  == 1 | t_peer  == 1 )

gen T_econ = (t_fam_povrty==1 | t_livsit_envir == 1)

drop location_id bundes_land_id user_id user_female jbj concern* problemwith* fsum-schsum  t_* ptwith_* 
drop corona_* migrant
drop  suddenstop dropped

drop  violsum tsum addicsum  
sort ddate

 save "$rawdata\Countries\Germany\Nummer gegen Kummer\NgK_KJB.dta", replace

 




* Merge the two helplines:



use "$rawdata\Countries\Germany\Nummer gegen Kummer\ET.dta", clear


append using "$rawdata\Countries\Germany\Nummer gegen Kummer\NgK_KJB.dta"

gen phone = 1
gen chat = 0

save "$rawdata\Countries\Germany\Nummer gegen Kummer\GER2contacts.dta", replace


erase "$rawdata\Countries\Germany\Nummer gegen Kummer\NgK_KJB.dta"
erase "$rawdata\Countries\Germany\Nummer gegen Kummer\ET.dta"



use "$rawdata\Countries\Germany\Nummer gegen Kummer\GER2contacts.dta", clear









