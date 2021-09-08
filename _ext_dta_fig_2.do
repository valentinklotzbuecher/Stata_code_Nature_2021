


use "$rawdata\merged_contacts.dta",  clear

sum chat phone mail

tab firstcall

bysort HCcode: egen mrcall =  mean(repcall)

gen knownrepcall = 0 if mrcall != .
replace knownrepcall = 1 if repcall == 1
replace knownrepcall = . if year == 2020 & HCcode == "GER1"
replace knownrepcall = . if HCcode == "GER1"

	bysort HCcode: sum firstcall habitcall repcall knownrepcall 

gen hphlcode = .
replace hphlcode = 1 if HCcode == "GER1"
replace hphlcode = 2 if HCcode == "FRA"
replace hphlcode = 3 if HCcode == "NLD"
replace hphlcode = 4 if HCcode == "GER2"
replace hphlcode = 5 if HCcode == "BEL"
replace hphlcode = 6 if HCcode == "ITA"
replace hphlcode = 7 if HCcode == "AUT"
replace hphlcode = 8 if HCcode == "SVN"
replace hphlcode = 9 if HCcode == "GER3"
replace hphlcode = 10 if HCcode == "CHN"
replace hphlcode = 11 if HCcode == "ISR"
replace hphlcode = 12 if HCcode == "LBN"

foreach j of numlist 1/12  {
sum hphlcode if hphlcode == `j'
gen N`j' = r(N)
tostring N`j' , gen(N_`j'_string) format(%12.0fc) force
}

		
sum hphlcode
gen Ntot = r(N)
tostring Ntot , gen(Ntot_string) format(%12.0fc) force
			
					
	tabstat fears lonely suicide addiction violence  physhealth T_econ T_social , statistics(mean) by(hphlcode) save
matrix C = (r(Stat1) \ r(Stat2) \ r(Stat3)  \ r(Stat4)  \ r(Stat5)  \ r(Stat6)  \ r(Stat7)  \ r(Stat8) \ r(Stat9) \ r(Stat10) \ r(Stat11)  \ r(Stat12) \ r(StatTotal))
matrix rownames C = `r(name1)' `r(name2)' `r(name3)'  `r(name4)'  `r(name5)'  `r(name6)'  `r(name7)'  `r(name8)'  `r(name9)'  `r(name10)'   `r(name11)'  `r(name12)'   Average
matrix colnames C =  "Fears"  "Loneliness"  "Suicidality"  "Addiction" "Violence"  "Physical health"  "Livelihood"  "Relationships"
matrix rownames C = "Germany, Telefonseelsorge" "France, SOS Amitié"  "Netherlands, De Luisterlijn" "Germany, NgK children line" "Belgium, Tele-Onthaal" "Italy, Telefono Amico" "Austria, Telefonseelsorge" "Slovenia, Zaupni Samarijan" "Germany, NgK parents line" "China, Hope Line" "Israel, SAHAR" "Lebanon, Embrace" "Overall average"

foreach j of numlist 1/12  {
local N_`j'= N_`j'_string[1]
display "`N_`j''"
}


local N_tot=Ntot_string[1]
display "`N_tot'"

# delimit ;
heatplot C, values(format(%9.2f)) legend(off) aspectratio(1.2) scheme(s1mono)
		graphregion(color(white) margin(medsmall) lwidth(medium)) plotregion(color(white)  margin(small))
		 text(0.2 10 "N", placement(west) size(small))
		 text(1 10.5 "`N_1'", placement(west) size(small))
		 text(2 10.5 "`N_2'", placement(west) size(small))
		 text(3  10.5 "`N_3 '", placement(west) size(small))
		 text(4  10.5 "`N_4 '", placement(west) size(small))
		 text(5  10.5 "`N_5 '", placement(west) size(small))
		 text(6  10.5 "`N_6 '", placement(west) size(small))
		 text(7  10.5 "`N_7 '", placement(west) size(small))
		 text(8  10.5 "`N_8 '", placement(west) size(small))
		 text(9  10.5 "`N_9 '", placement(west) size(small))
		 text(10 10.5 "`N_10'", placement(west) size(small))
		 text(11 10.5 "`N_11'", placement(west) size(small))
		 text(12 10.5 "`N_12'", placement(west) size(small))
		 text(13 10.5 "`N_tot'", placement(west) size(small))
		 xlabel(, angle(45) labsize(small) nogrid	) 
		 ylabel(,  labsize(small) nogrid	) name(grc1, replace) 
		colors(plasma)    cuts(-0.15(0.05)0.4) ;
# delimit cr		

					graph export ".\02_Project\Figures\heatplot_HCtopics.pdf", replace
					
graph export ".\Revisions_Nature\Final figures\ExtDataFig2.pdf", replace

				

gen N = .
foreach j of numlist 1/12  {
replace N = N`j' if _n == `j'
}
replace N = Ntot if _n == 13	

keep in 1/13			
svmat C, names(col) 
gen helpline = "Germany, Telefonseelsorge"  if _n == 1
replace helpline = "France, SOS Amitié"  if _n == 2
replace helpline = "Netherlands, De Luisterlijn" 		if _n == 3
replace helpline = "Germany, NgK children line" if _n == 4
replace helpline = "Belgium, Tele-Onthaal" if _n == 5
replace helpline = "Italy, Telefono Amico" if _n == 6
replace helpline = "Austria, Telefonseelsorge" if _n == 7
replace helpline = "Slovenia, Zaupni Samarijan" if _n == 8
replace helpline = "Germany, NgK parents line" if _n == 9
replace helpline = "China, Hope Line" if _n == 10
replace helpline = "Israel, SAHAR" if _n == 11
replace helpline = "Lebanon, Embrace" if _n ==12 
replace helpline = "Overall average" if _n == 13

keep helpline Fears Loneliness Suicidality Addiction Violence Physical health Livelihood N
order helpline Fears Loneliness Suicidality Addiction Violence Physical health Livelihood N

export excel using ".\Revisions_Nature\Final figures\ExtDataFig2_SourceData.xlsx", firstrow(varlabels) replace

					
					
					
					
					
					