



import delimited ".\03_Data\Countries\Czech Republic\Modrá linka Daily statistics 1.1.2019 - 3.4.2019.csv",  clear delim(";")

save `".\03_Data\Countries\Czech Republic\2019_a.dta"',  replace



import delimited ".\03_Data\Countries\Czech Republic\Modrá linka Daily statistics 4.4.2019 - 12.6.2020.csv",  clear delim(";")


append using `".\03_Data\Countries\Czech Republic\2019_a.dta"'

erase `".\03_Data\Countries\Czech Republic\2019_a.dta"'


gen ddate = date(datum,"DMY")
format ddate %td


gen country = "Czech Republic"
gen population = 10.69

gen helplinename = "Modrá linka"

split otázkaodpovìï, gen(problem) p(" / ")


tab problem1,m		// call type
tab problem2,m		// issue
tab problem3,m






drop datum id otázkaodpovìï poèet






save `".\03_Data\Countries\Czech Republic\Modralinka.dta"',  replace


