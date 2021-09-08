
import excel "$rawdata\Countries\Lebanon\Embrace_Variables_2019-2020_for german swiss team.xlsx",  firstrow clear

gen ddate = round(Date_of_Call)
format ddate %td

gen male = 1 if Caller_Sex == "Male"
replace male = 0 if Caller_Sex == "Female"
gen female = 1 if Caller_Sex == "Female"
replace female = 0 if Caller_Sex == "Male"

foreach V of varlist Caller_Employment_Status_Fulltim-Caller_Employment_Status_Retired Type_of_Call_* CallerDOB_YEAR Caller_Age Caller_Children Caller_Children_Living_With Caller_Living_With_* { 
replace `V' = . if `V' == 999
replace `V' = . if `V' == 666
}

foreach V of varlist Caller_Marital_Status Caller_Nationality Caller_Region Caller_District Caller_Current_Highest_Education Caller_Current_Education_Grade_Y   {
replace `V' = "" if `V' == "999"
replace `V' = "" if `V' == "666"
}

rename Caller_Age age
rename Caller_Region region
rename Caller_District district
rename Caller_Children childnum
rename Caller_Children_Living_With childnumhh
rename Caller_Marital_Status maritalstatus

gen durationh = substr(Call_Duration_System,1,2)
gen durationm = substr(Call_Duration_System,4,2)
destring duration*, replace
gen duration = durationm + 60*durationh 
drop durationm durationh

gen callerIDstring = substr(Unique_ID,1,7) 
encode callerIDstring, gen(callerID)

rename Caller_Employment_Status_Fulltim fulltstudent
rename Caller_Employment_Status_Parttim parttstudent
rename Caller_Employment_Status_Employe fulltemployed
rename AN parttemployed
rename AO employed_freelancer
rename Caller_Employment_Status_Unemplo unemployed
rename Caller_Employment_Status_Unablet disability
rename Caller_Employment_Status_Homemak homeworker
rename Caller_Employment_Status_Retired retired

gen married = 0 if maritalstatus != ""
replace married = 1 if maritalstatus == "Married"

   // Type_of_Call_4_Third_Party_Calle Type_of_Call_5_Third_Party_Invol Type_of_Call_6_Third_Party_Bysta Type_of_Call_7_Someone_Bereaved_ Type_of_Call_8_Looking_for_Refer Type_of_Call_9_Frequent_Caller Type_of_Call_10_Prank_Caller Type_of_Call_11_Concers_about_Co Type_of_Call_12_Socioeconomic_Co Call_Attempt Unique_ID Date_of_Call Call_Duration_System CallerDOB_YEAR Caller_Age Caller_Sex Caller_Sexual_Orientation Caller_Nationality Caller_Country Caller_Region Caller_District Caller_Children Caller_Children_Living_With    

rename Caller_Current_Highest_Education degree 
replace degree = "" if degree == "No data"
rename Caller_Current_Education_Grade_Y gradeyear
replace gradeyear = "" if gradeyear == "No data"


rename Type_of_Call_3_Attempt_in_Progre suicide_attempt

rename Type_of_Call_2_Suicide_Ideation_ suicide
replace suicide = 1 if suicide_attempt == 1 

rename Caller_Nationality nationality


gen empstatusknown = 0
replace empstatusknown = 1 if fulltemployed  == 1 | parttemployed  == 1 | employed_freelancer == 1 | fulltstudent  == 1 | parttstudent  == 1 | unemployed  == 1 | disability  == 1 | homeworker  == 1 | retired == 1 

gen employed = 0 if empstatusknown == 1
replace employed = 1 if  fulltemployed  == 1 | parttemployed  == 1 | employed_freelancer == 1 

gen education = 0 if empstatusknown == 1
replace education = 1 if  fulltstudent  == 1 | parttstudent  == 1 


rename Caller_Living_With_Alone living_alone
rename Caller_Living_With_Family 		living_family 
rename Caller_Living_With_Roommate 	living_shared 
rename Caller_Living_With_Partner 		living_partner 
rename Caller_Living_With_NuclearFami 	living_nucfamily 
rename Caller_Living_With_ExtendedFam 	living_extfamily
rename Caller_Living_With_Homeless 	living_homeless 



gen repcall = Type_of_Call_9_Frequent_Caller
gen firstcall = 1- repcall

gen coronacall = Type_of_Call_11_Concers_about_Co


drop if Type_of_Call_10_Prank_Caller == 1

drop Caller_Country Caller_Sexual_Orientation Call_Attempt Unique_ID Date_of_Call Call_Duration_System CallerDOB_YEAR Type_of_Call_10_Prank_Caller Type_of_Call_4_Third_Party_Calle  Type_of_Call_5_Third_Party_Invol Type_of_Call_6_Third_Party_Bysta Type_of_Call_8_Looking_for_Refer Type_of_Call_9_Frequent_Caller  Type_of_Call_11_Concers_about_Co Type_of_Call_12_Socioeconomic_Co Type_of_Call_7_Someone_Bereaved_


rename  Type_of_Call_1_Emotional_Distres stressemot

gen country = "Lebanon"
gen population = 6.849


keep stressemot-age retired-population

gen age_min = age
gen age_max = age


gen helplinename = "Embrace"

gen phone =1
gen chat = 0

save `"$rawdata\Countries\Lebanon\LBNcontacts.dta"',  replace

use `"$rawdata\Countries\Lebanon\LBNcontacts.dta"', clear




