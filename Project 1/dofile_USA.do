cd "C:\Users\lollo\Documents\uni\QEM\[3] Barcelona_Autonoma\Academics Barcelona\quantitative macro\Homework 1"
use employment_USA.dta

ssc install asgen

gen unemp=1 if empstat==21&22
gen labf=1 if labforce==2

gen year2= 12 if year== 2019
gen year3= 24 if year== 2020
mvencode year2 year3, mv(0)
gen year1= year2 + year3
gen yearmonth= month + year1

egen unemployment2 = sum( unemp), by(yearmonth)

*plot unemployment2 yearmonth

egen labforce2 = sum( labf), by(yearmonth)
gen ratio2=  unemployment2/ labforce2

gen employment= 1- ratio2

preserve
****************************************

drop if educ==1
gen PreHS=1 if educ <= 71
gen HS=1 if educ >= 72 &  educ<= 110
gen College=1 if educ >= 111 &  educ<= 122
gen PostCollege=1 if educ >= 123 &  educ<= 125
mvencode PreHS HS College PostCollege, mv(0) /*it makes missing values being equal to zero, because then we have to sum and we only want 1 and zeros*/

egen PreHSunem = sum( unemp)  if PreHS==1,  by(yearmonth)
egen HSunem = sum( unemp)  if HS==1,  by(yearmonth)
egen Collegeunem = sum( unemp)  if College==1,  by(yearmonth)
egen PostCollegeunem = sum( unemp)  if PostCollege==1,  by(yearmonth)

egen PreHSlab = sum( labforce) if PreHS==1, by(yearmonth)
egen HSlab = sum( labforce) if HS==1, by(yearmonth)
egen Collegelab = sum( labforce) if College==1, by(yearmonth)
egen PostCollegeHSlab = sum( labforce) if PostCollege==1, by(yearmonth)

gen ratio3= PreHSunem/PreHSlab
gen ratio4= HSunem/HSlab
gen ratio5= Collegeunem/Collegelab
gen ratio6= PostCollegeunem/PostCollegeHSlab 

gen empl1= 1-ratio3
gen empl2= 1-ratio4
gen empl3= 1-ratio5
gen empl4= 1-ratio6

*line empl1 empl2 empl3 empl4 yearmonth, legend(size(medsmall))

*** INDUSTRY (ability to telework) ***
restore
preserve

drop if ind==0

gen phy=1 if ind<=6390 | ind>=8560 & ind<=9180
gen tel=1 if ind>=9190 | ind<=8470 & ind>=6470
mvencode phy tel, mv(0)

egen u_phy= sum( unemp) if phy==1, by(yearmonth)
egen u_tel=sum( unemp) if tel==1, by(yearmonth)
egen l_phy=sum( labforce) if phy==1, by(yearmonth)
egen l_tel=sum( labforce) if tel==1, by(yearmonth)

gen ratio7=u_phy/l_phy
gen ratio8=u_tel/l_tel

gen empl7=1-ratio7
gen empl8=1-ratio8

*line empl7 empl8 yearmonth, legend(size(medsmall))

*** OCCUPATION (administration, public, private) ***

restore
preserve

drop if occ==0
gen Highoff=1 if occ<= 3540
gen offiPublic=1 if occ>= 3600 & occ<= 5940
gen Field=1 if occ>= 6000

egen Highoffunem = sum( unemp)  if Highoff==1,  by(yearmonth)
egen offiPublicunem = sum( unemp)  if offiPublic==1,  by(yearmonth)
egen Fieldunem= sum( unemp)  if Field==1,  by(yearmonth)

egen Highofflab = sum( labforce) if Highoff==1, by(yearmonth)
egen offiPubliclab = sum( labforce) if offiPublic==1, by(yearmonth)
egen Fieldlab = sum( labforce) if Field==1, by(yearmonth)

gen ratio9= Highoffunem/Highofflab
gen ratio10= offiPublicunem/offiPubliclab
gen ratio11= Fieldunem/Fieldlab

gen empl9= 1-ratio9
gen empl10= 1-ratio10
gen empl11= 1-ratio11

*line empl9 empl10 empl11 yearmonth, legend(size(medsmall))

*************** PREDICTION EMPLOYMENT 2020 *********************
restore
preserve
/*
asgen pre = ratio2 if year!=2020, w(year) by(month)

replace pre = pre[309088] if yearmonth==27
replace pre = pre[472998] if yearmonth==28
replace pre = pre[599441] if yearmonth==29
replace pre = pre[641590] if yearmonth==30
replace pre = pre[772718] if yearmonth==31
replace pre = pre[899161] if yearmonth==32
*replace pre= . if yearmonth!=27&28&29&30&31&32

line ratio2 pre yearmonth, legend(size(medsmall))
*/

asgen pre = employment if year!=2020, w(year) by(month)

replace pre = pre[309088] if yearmonth==27
replace pre = pre[472998] if yearmonth==28
replace pre = pre[599441] if yearmonth==29
replace pre = pre[641590] if yearmonth==30
replace pre = pre[772718] if yearmonth==31
replace pre = pre[899161] if yearmonth==32
*replace pre= . if yearmonth!=27&28&29&30&31&32

*line employment pre yearmonth, legend(size(medsmall))

************* AVERAGE WEEKLY HOURS ******************

restore
preserve

drop if uhrsworkt==997
drop if uhrsworkt==999

egen wh=mean(uhrsworkt), by(yearmonth)

asgen pre_wh=wh if year!=2020, w(year) by(month)
replace pre_wh = wh[135964] if yearmonth==27
replace pre_wh = wh[191580] if yearmonth==28
replace pre_wh = wh[247200] if yearmonth==29
replace pre_wh = wh[306956] if yearmonth==30
replace pre_wh = wh[346081] if yearmonth==31
replace pre_wh = wh[403758] if yearmonth==32

*line wh pre_wh yearmonth, legend(size(medsmall))

********* WAGES ************************************

restore
preserve

drop if hourwage== 999.99
egen meanWage= mean( hourwage), by (yearmonth)

gen realwage2018= meanWage*0.679  if year==2018
gen realwage2019= meanWage*0.663  if year==2019
gen realwage2020= meanWage*0.652  if year==2020

mvencode realwage2018  realwage2019 realwage2020, mv(0)
gen realwage= realwage2019 + realwage2018 + realwage2020

asgen predicwage = realwage if year!=2020, w(year) by(month)

replace predicwage = predicwage[18948] if yearmonth== 27
replace predicwage = predicwage[27401] if yearmonth== 28
replace predicwage = predicwage[35269] if yearmonth== 29
replace predicwage = predicwage[41972] if yearmonth== 30
replace predicwage = predicwage[50132] if yearmonth== 31
replace predicwage = predicwage[61790] if yearmonth== 32

*line realwage predicwage yearmonth, legend(size(medsmall))

**************** AGGREGATE HOURS *******************

restore
preserve

drop if uhrsworkt==997
drop if uhrsworkt==999

egen wh=mean(uhrsworkt), by(yearmonth)

drop if empstat==0
gen empl=1 if  empstat<=12
egen emp=sum(empl), by(yearmonth)

gen agg_wh=emp*wh

asgen pre_agg_wh=agg_wh if year!=2020, w(year) by(month)
replace pre_agg_wh = agg_wh[144208] if yearmonth==27
replace pre_agg_wh = agg_wh[214239] if yearmonth==28
replace pre_agg_wh = agg_wh[234841] if yearmonth==29
replace pre_agg_wh = agg_wh[302818] if yearmonth==30
replace pre_agg_wh = agg_wh[339897] if yearmonth==31
replace pre_agg_wh = agg_wh[401695] if yearmonth==32

*line agg_wh pre_agg_wh yearmonth, legend(size(medsmall))

**************** PERCENTAGE DEVIATIONS ************

gen percent_agg=(pre_agg_wh-agg_wh)/agg_wh if yearmonth>=27

*for wh
asgen pre_wh=wh if year!=2020, w(year) by(month)
replace pre_wh = wh[135964] if yearmonth==27
replace pre_wh = wh[191580] if yearmonth==28
replace pre_wh = wh[247200] if yearmonth==29
replace pre_wh = wh[306956] if yearmonth==30
replace pre_wh = wh[346081] if yearmonth==31
replace pre_wh = wh[403758] if yearmonth==32

gen percent_wh=(pre_wh-wh)/wh if yearmonth>=27

*for employment
asgen pre = employment if year!=2020, w(year) by(month)
replace pre = pre[309088] if yearmonth==27
replace pre = pre[472998] if yearmonth==28
replace pre = pre[599441] if yearmonth==29
replace pre = pre[641590] if yearmonth==30
replace pre = pre[772718] if yearmonth==31
replace pre = pre[899161] if yearmonth==32

gen percent_emp=(pre-employment)/employment if yearmonth>=27

/*regression
gen ln_agg=ln(agg_wh)
gen ln_wh=ln(wh)
gen ln_emp=ln(employment)
reg ln_agg ln_wh
reg ln_agg ln_emp
reg agg_wh wh employment*/
