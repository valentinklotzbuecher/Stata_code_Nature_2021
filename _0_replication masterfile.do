//****************************************************************************************************
**	Mental ealth concerns during COVID-19 as Revealed through Helpline Calls
//****************************************************************************************************
clear all
version 17.0
set more off, permanently
set maxvar 32767
set excelxlsxlargefile on
global F5 "browse;"
frame reset

cd "C:\Users\VK\Dropbox\10_Covid19_EU"
global rawdata "C:\Users\VK\Sync\Research\Helplinedata local"
//**************************************************



* Prepare helpline data:
do ".\Stata replication\obtain_Austria.do"
do ".\Stata replication\obtain_Belgium.do"
do ".\Stata replication\obtain_Germany.do"			
do ".\Stata replication\obtain_Germany2.do"		
do ".\Stata replication\obtain_Germany3.do"
do ".\Stata replication\obtain_Netherlands.do"
do ".\Stata replication\obtain_Switzerland.do"
do ".\Stata replication\obtain_Italy.do"
do ".\Stata replication\obtain_Israel.do"
do ".\Stata replication\obtain_Lebanon.do"
do ".\Stata replication\obtain_Finland.do"
do ".\Stata replication\obtain_HongKong.do"
do ".\Stata replication\obtain_China.do"
do ".\Stata replication\obtain_Luxembourg.do"
do ".\Stata replication\obtain_Bosnia.do"
do ".\Stata replication\obtain_Portugal.do"
do ".\Stata replication\obtain_Czech_Republic.do"
do ".\Stata replication\obtain_Hungary.do"
do ".\Stata replication\obtain_France.do"
do ".\Stata replication\obtain_Slovenia.do"
do ".\Stata replication\obtain_USA.do"

* Prepare data on Covid-19, NPIs:
do ".\Stata replication\obtain_additional_data.do"

* Prepare datasets: 
do ".\Stata replication\merge.do"


* Analysis:
do ".\Stata replication\_fig_1.do"
do ".\Stata replication\_fig_2.do"
do ".\Stata replication\_fig_3.do"
do ".\Stata replication\_fig_4.do"
do ".\Stata replication\_fig_5.do"

do ".\Stata replication\_ext_dta_fig_1.do"
do ".\Stata replication\_ext_dta_fig_3.do"
do ".\Stata replication\_ext_dta_fig_5.do"
do ".\Stata replication\_ext_dta_fig_6.do"

do ".\Stata replication\additional_figures.do"

* Supplementary Materials:
do ".\Stata replication\supplementary_figures.do"



//**************************************************
exit, clear
//**************************************************
