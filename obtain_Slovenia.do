
import excel "$rawdata\Countries\Slovenia\Kopie von Association Confidential phone Samarijan - helpline data for 2019 and 2020 - SI & ENG - 22 1 2021.xlsx", sheet("Calls export for 2019 and 2020")   clear 

gen ddate = date(C,"MDY")
format ddate %td

gen female = 0 if F == "1"
replace female = 1 if F == "2"
gen male = 0 if F == "2"
replace male = 1 if F == "1"

gen agegroup =  "Up to 18 years" if G == "1"
replace agegroup = "From 19 to 30 years" if G == "2"
replace agegroup = "From 31 to 45 years" if G == "3"
replace agegroup = "From 46 to 64 years" if G == "4"
replace agegroup = "Over 65 years" if G == "5"
replace agegroup = "" if G == "6"

gen agemax =  18 if G == "1"
replace agemax = 30 if G == "2"
replace agemax = 45 if G == "3"
replace agemax = 64 if G == "4"
replace agemax = 100 if G == "5"
gen agemin =  0 if G == "1"
replace agemin = 19 if G == "2"
replace agemin = 31 if G == "3"
replace agemin = 46 if G == "4"
replace agemin = 65 if G == "5"
egen age = rowmean(agemin agemax)



gen single = 0 if H != "6"
replace single = 1 if H == "1"
gen inpartnership = 0 if H != "6"
replace inpartnership = 1 if H == "2"
gen widowed = 0 if H != "6"
replace widowed = 1 if H == "3"
gen separated = 0 if H != "6"
replace separated = 1 if H == "4"


drop in 1/2
gen mdurat = substr(E,4,2)
gen hdurat = substr(E,1,2)
destring mdurat hdurat, replace
gen duration = mdurat + 60*hdurat
drop mdurat hdurat

gen call_reason = ""
replace call_reason = "Finding / choosing a partner / falling in love" if I == "0"
replace call_reason = "Jealousy" if I == "1"
replace call_reason = "Misunderstanding" if I == "2"
replace call_reason = "Sexuality" if I == "3"
replace call_reason = "Relationship with a married person" if I == "4"
replace call_reason = "Problems during pregnancy" if I == "5"
replace call_reason = "Violence (verbal / physical / psychological)" if I == "6"
replace call_reason = "Abortion" if I == "7"
replace call_reason = "Sexual violence" if I == "8"

replace call_reason = "Jealousy	" if I == "10"
replace call_reason = "Misunderstanding / alienation / separate living	" if I == "11"
replace call_reason = "Sexuality	" if I == "12"
replace call_reason = "Infidelity	" if I == "13"
replace call_reason = "Pregnancy problems	" if I == "14"
replace call_reason = "Violence (verbal / physical / psychological)	" if I == "15"
replace call_reason = "Divorce, separation	" if I == "16"
replace call_reason = "Problems after divorce	" if I == "17"
replace call_reason = "Abortion	" if I == "18"

replace call_reason = "Sick / disabled family member	" if I == "20"
replace call_reason = "Misunderstandings on the part of caretakers / parents	" if I == "21"
replace call_reason = "Violence (verbal / physical / psychological) in family	" if I == "22"
replace call_reason = "Violence in the social environment	" if I == "23"
replace call_reason = "Sexual abuse	" if I == "24"						
replace call_reason = "Sexuality	" if I == "25"
replace call_reason = "Infatuation	" if I == "26"
replace call_reason = "Problems accepting yourself	" if I == "27"
replace call_reason = "Problems at school	" if I == "28"
replace call_reason = "Prank calls	" if I == "29"

replace call_reason = "Upbringing issues	" if I == "30"
replace call_reason = "Sick / disabled family member	" if I == "31"
replace call_reason = "Children who are not from an existing relationship	" if I == "32"
replace call_reason = "Intergenerational problems (old and young)	" if I == "33"
replace call_reason = "Single mother / father	" if I == "34"
replace call_reason = "Violent family member / child	" if I == "35"
replace call_reason = "Sexual abuse	" if I == "36"							
replace call_reason = "Problems with relatives	" if I == "37"
replace call_reason = "Parental problems related to children's school	" if I == "38"

replace call_reason = "Personal reflections on the meaning of life	" if I == "40"
replace call_reason = "Personal reflections on faith	" if I == "41"
replace call_reason = "Personal reflections on social conditions	" if I == "42"

replace call_reason = "Lack of self-confidence	" if I == "45"
replace call_reason = "Superiority complex	" if I == "46"
replace call_reason = "Inferiority complex	" if I == "47"
replace call_reason = "Not accepting yourself	" if I == "48"
replace call_reason = "Work on yourself	" if I == "49"

replace call_reason = "Loneliness	" if I == "50"
replace call_reason = "Lack of social contact	" if I == "51"
replace call_reason = "Problems of the elderly	" if I == "52"
replace call_reason = "Diseases	" if I == "53"
replace call_reason = "Sudden blows of fate	" if I == "54"
replace call_reason = "Living with a disability	" if I == "55"
replace call_reason = "Mourning	" if I == "56"
replace call_reason = "Workplace violence / mobbing	" if I == "57"
replace call_reason = "Violence (verbal / physical / psychological / sexual / economic)	" if I == "58"
replace call_reason = "Consequences of a difficult childhood	" if I == "59"

replace call_reason = "Sleep problems	" if I == "60"
replace call_reason = "Anxiety, unfounded fears	" if I == "61"
replace call_reason = "Depressed states	" if I == "62"
replace call_reason = "Aggression	" if I == "63"
replace call_reason = "An unreal, distorted experience of oneself, others, the environment	" if I == "64"

replace call_reason = "Living with a mental illness	" if I == "66"
replace call_reason = "Problems related to therapy	" if I == "67"
replace call_reason = "Other mental abnormalities	" if I == "68"

replace call_reason = "Alcohol abuse	" if I == "69"
replace call_reason = "Drug and narcotics abuse	" if I == "70"
replace call_reason = "Food abuse	" if I == "71"
replace call_reason = "Abuse of relationships	" if I == "72"
replace call_reason = "Sex abuse	" if I == "73"
replace call_reason = "Other addictions (games of chance, food, computer ...)	" if I == "74"
replace call_reason = "Caring for a dependent family member / partner / friend	" if I == "75"

replace call_reason = "Suicidal thoughts	" if I == "76"
replace call_reason = "Past suicide attempt	" if I == "77"
replace call_reason = "Suicide threat	" if I == "78"
replace call_reason = "Worries about the suicidal tendencies of another	" if I == "79"

replace call_reason = "Environment / social issues	" if I == "	"
replace call_reason = "Neighbors / acquaintances / friends / classmates	" if I == "80"
replace call_reason = "Accommodation / apartment	" if I == "81"
replace call_reason = "Caring for others	" if I == "82"
replace call_reason = "School / education / study	" if I == "83"
replace call_reason = "Positive experience	" if I == "84"
replace call_reason = "Occupation / work / employment	" if I == "85"
replace call_reason = "Rest and free time	" if I == "86"
replace call_reason = "Legal issues	" if I == "87"
replace call_reason = "Peripheral groups / minorities / foreigners	" if I == "88"
replace call_reason = "Financial problems	" if I == "89"

replace call_reason = "General notices and questions	" if I == "90"
replace call_reason = "Helpline information	" if I == "91"
replace call_reason = "Calls ended after presentation	" if I == "92"
replace call_reason = "Silent calls	" if I == "93"
replace call_reason = "Thanks and encouragements	" if I == "94"
replace call_reason = "Complaints about the operation of other institutions	" if I == "95"
replace call_reason = "Complaints about our work, co-workers	" if I == "96"

replace call_reason = "Volunteer questions	" if I == "98"
replace call_reason = "Calls by mistake	" if I == "99"

replace call_reason = trim(call_reason)


gen suicide = 0 if call_reason != ""
replace suicide = 1 if call_reason == "Suicidal thoughts"
replace suicide = 1 if call_reason == "Past suicide attempt" 
replace suicide = 1 if call_reason == "Suicide threat"
replace suicide = 1 if call_reason == "Worries about the suicidal tendencies of another"


gen lonely = 0 if call_reason != ""
replace lonely = 1 if call_reason == "Loneliness"
replace lonely = 1 if call_reason == "Lack of social contact"

gen violence = 0 if call_reason != ""
replace violence = 1 if call_reason == "Workplace violence / mobbing"
replace violence = 1 if call_reason == "Violence (verbal / physical / psychological / sexual / economic)"
replace violence = 1 if call_reason == "Sexual abuse"
replace violence = 1 if call_reason == "Violence (verbal / physical / psychological) in family"
replace violence = 1 if call_reason == "Violence in the social environment"


gen addiction = 0 if call_reason != ""
replace addiction = 1 if call_reason == "Alcohol abuse"
replace addiction = 1 if call_reason == "Drug and narcotics abuse"
replace addiction = 1 if call_reason == "Food abuse"
replace addiction = 1 if call_reason == "Abuse of relationships"
replace addiction = 1 if call_reason == "Sex abuse"
replace addiction = 1 if call_reason == "Other addictions (games of chance, food, computer ...)"


gen grief = 0
replace grief = 1 if call_reason == "Mourning"


gen T_econ = 0
replace T_econ = 1 if call_reason == "Financial problems"
replace T_econ = 1 if call_reason == "Accommodation / apartment"


drop if call_reason == "Volunteer questions"
drop if call_reason == "Calls by mistake" 
drop if call_reason == "Prank calls" 

gen population = 2.081
gen helplinename = "Zaupni telefon Samarijan"
gen country = "Slovenia"


keep ddate-country

gen phone = 1
gen chat = 0

save `"$rawdata\Countries\Slovenia\SLVcontacts.dta"',  replace




