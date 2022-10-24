use "/Users/sam/Desktop/THORACIC_DATA.DTA", clear

***VARIABLES
{
**Exclusion Variable

gen exclusion=0
replace exclusion=1 if TX_DATE< date("01-01-2020", "MDY")
replace exclusion=1 if AGE<18
replace exclusion=1 if MULTIORG=="Y"
replace exclusion=1 if WL_ORG!= "HR"
replace exclusion=1 if TX_DATE==.
replace exclusion=1 if INIT_AGE==.
replace exclusion=1 if GENDER=="."

*Female Variable

gen female = 0
replace female = 1 if GENDER == "F"

*Ethnic Minority Variable

gen ethn = 0
replace ethn = 1 if ETHCAT != 1

*Race Variable

gen race=0
replace race=1 if ETHCAT==1
replace race=2 if ETHCAT==2
replace race=3 if ETHCAT==4
replace race=4 if ETHCAT==5
replace race=5 if race==0

label define racelabel 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Other"
label values race racelabel

*pVAD Variable

gen pvadlisting=0
replace pvadlisting=1 if VAD_BRAND1_TCR == 201 | VAD_BRAND1_TCR == 215 | VAD_BRAND1_TCR == 225 | VAD_BRAND1_TCR == 226 | VAD_BRAND1_TCR == 227 | VAD_BRAND1_TCR == 228 | VAD_BRAND1_TCR == 237 | VAD_BRAND1_TCR == 235 | VAD_BRAND1_TCR == 238 | VAD_BRAND1_TCR == 309 | VAD_BRAND1_TCR == 301 | VAD_BRAND1_TCR == 317 | VAD_BRAND1_TCR == 318 | VAD_BRAND1_TCR == 319 | VAD_BRAND1_TCR == 320 | VAD_BRAND1_TCR == 321 | VAD_BRAND1_TCR == 325 | VAD_BRAND1_TCR == 330 | VAD_BRAND1_TCR == 331 | VAD_BRAND1_TCR == 332 

gen pvadtx=0
replace pvadtx=1 if VAD_BRAND1_TRR == 201 | VAD_BRAND1_TRR == 215 | VAD_BRAND1_TRR == 225 | VAD_BRAND1_TRR == 226 | VAD_BRAND1_TRR == 227 | VAD_BRAND1_TRR == 228 | VAD_BRAND1_TRR == 237 | VAD_BRAND1_TRR == 235 | VAD_BRAND1_TRR == 238 | VAD_BRAND1_TRR == 309 | VAD_BRAND1_TRR == 301 | VAD_BRAND1_TRR == 317 | VAD_BRAND1_TRR == 318 | VAD_BRAND1_TRR == 319 | VAD_BRAND1_TRR == 320 | VAD_BRAND1_TRR == 321 | VAD_BRAND1_TRR == 325 | VAD_BRAND1_TRR == 330 | VAD_BRAND1_TRR == 331 | VAD_BRAND1_TRR == 332

*LVAD Variable

gen vadcat = 0 

replace vadcat = 1 if LVAD_AT_LISTING == 1
replace vadcat = 1 if LVAD_WHILE_LISTED == 1
replace vadcat = 1 if VAD_DEVICE_TY_TCR==2
replace vadcat = 1 if VAD_DEVICE_TY_TRR==2

*Status Variable

gen statushigh=0
replace statushigh=1 if END_STAT==2110 | END_STAT==2120

gen status=0
replace status=1 if END_STAT==2110
replace status=2 if END_STAT==2120
replace status=3 if END_STAT==2130
replace status=4 if END_STAT==2140
replace status=5 if END_STAT==2150
replace status=6 if END_STAT==2160

*Diabetic Donor Variable

gen diab_don = 0
replace diab_don = 1 if DIABETES_DON == "Y"

*Female Donor Variable

gen female_don = 0 
replace female_don = 1 if GENDER_DON == "F"

*Female to male Variable

gen female_male = 0
replace female_male = 1 if GENDER_DON=="F" & GENDER=="M"

*Size Mismatch Variable

gen LVgrams_rec = 8.25*((END_HGT_CM_CALC*0.01)^(0.54))*((END_WGT_KG_CALC)^(0.61)) if GENDER == "M"
gen LVgrams_don = 8.25*((HGT_CM_DON_CALC*0.01)^(0.54))*((WGT_KG_DON_CALC)^(0.61)) if GENDER_DON == "M"

replace LVgrams_rec = 6.82*((END_HGT_CM_CALC*0.01)^(0.54))*((END_WGT_KG_CALC)^(0.61)) if GENDER == "F"
replace LVgrams_don = 6.82*((HGT_CM_DON_CALC*0.01)^(0.54))*((WGT_KG_DON_CALC)^(0.61)) if GENDER_DON == "F"

sum LVgrams_rec, detail
sum LVgrams_don, detail

gen RVgrams_rec = 11.25*(1/(AGE^(.32)))*((END_HGT_CM_CALC*0.01)^(1.135))*((END_WGT_KG_CALC)^(0.315)) if GENDER == "M" 
gen RVgrams_don = 11.25*(1/(AGE_DON^(.32)))*((HGT_CM_DON_CALC*0.01)^(1.135))*((WGT_KG_DON_CALC)^(0.315)) if GENDER_DON == "M" 

replace RVgrams_rec = 10.59*(1/(AGE^(.32)))*((END_HGT_CM_CALC*0.01)^(1.135))*((END_WGT_KG_CALC)^(0.315)) if GENDER == "F" 
replace RVgrams_don = 10.59*(1/(AGE_DON^(.32)))*((HGT_CM_DON_CALC*0.01)^(1.135))*((WGT_KG_DON_CALC)^(0.315)) if GENDER_DON == "F" 


sum RVgrams_rec, detail
sum RVgrams_don, detail

gen total_heart_mass_rec = (LVgrams_rec + RVgrams_rec)
gen total_heart_mass_don = (LVgrams_don + RVgrams_don)

sum total_heart_mass_rec, detail
sum total_heart_mass_don, detail

gen size_perc = ((total_heart_mass_don - total_heart_mass_rec)/total_heart_mass_rec)
sum size_perc, detail

gen size_mism_typ = "Size Matched"
replace size_mism_typ = "Undersized" if size_perc <= (-.2)
replace size_mism_typ = "Oversized" if size_perc >= (.2)


tab size_mism_typ, missing


gen size_mism = 0
replace size_mism = 1 if size_mism_typ != "Size Matched"

*30-day mortality Variable

gen mort30daystat = 0
replace mort30daystat = 1 if COMPOSITE_DEATH_DATE - TX_DATE <= 30
 
*Survival days, deceased Variables

gen survdays=PTIME
replace survdays=date("06-30-2022", "MDY") - INIT_DATE if PTIME==.

gen deceased = 1 if COMPOSITE_DEATH_DATE !=.
replace deceased = 0 if COMPOSITE_DEATH_DATE == .

*In-hospital mortality Variable

gen inhospmort=0
replace inhospmort=1 if survdays<=LOS & deceased==1

*Post-op stroke Variable

gen stroke=0
replace stroke=1 if PST_STROKE=="Y"

*Post-op dialysis Variable

gen postdialysis=0
replace postdialysis=1 if PST_DIAL=="Y"

*Post-op pacemaker Variable

gen pacemaker=0
replace pacemaker=1 if PST_PACEMAKER=="Y"

*Post-op dialysis Variable

gen postdial=0
replace postdial=1 if PST_DIAL=="Y"

*Retransplantation Variable

gen retx=0
replace retx=1 if RETXDATE!=.

*COD Variable

tostring COD, gen(cod)

gen codcat=0
replace codcat=1 if inlist(substr(cod,1,2),"20")
replace codcat=2 if inlist(substr(cod,1,2),"21")
replace codcat=3 if inlist(substr(cod,1,2),"22")
replace codcat=4 if inlist(substr(cod,1,2),"23")
replace codcat=5 if inlist(substr(cod,1,2),"24")
replace codcat=6 if inlist(substr(cod,1,2),"26")
replace codcat=7 if COD==2705
replace codcat=8 if COD!=998 & codcat==0 & COMPOSITE_DEATH_DATE!=.
replace codcat=9 if COD==998

label define codlabel 1 "Graft Failure" 2 "Infection" 3 "Cardiovascular" 4 "Pulmonary" 5 "Cerebrovascular" 6 "Malignancy" 7 "Multi-organ Failure" 8 "Other" 9 "Unknown"
label values codcat codlabel

gen graftfail=0
replace graftfail=1 if codcat==1
replace graftfail=1 if retx==1

gen infection=0
replace infection=1 if codcat==2

gen cardio=0
replace cardio=1 if codcat==3

gen pulm=0
replace pulm=1 if codcat==4

gen cerebdeath=0
replace cerebdeath=1 if codcat==5

gen maligdeath=0
replace maligdeath=1 if codcat==6

gen multiorg=0
replace multiorg=1 if codcat==7

gen otherdeath=0
replace otherdeath=1 if codcat==8 | codcat==9

*Acute rejection Variable

gen acuterej=0
replace acuterej=1 if ACUTE_REJ_EPI==1 | ACUTE_REJ_EPI==2

*Merging donor database

merge m:m DONOR_ID using "/Users/sam/Desktop/DECEASED_DONOR_DATA.DTA"

drop _merge

*Covid Variable

gen alldonor_covid=0
foreach i in COVID19_NAT_TESTRESULT COVID19_OTHER_TESTRESULT COVID19_ANTIGEN_TESTRESULT{
replace alldonor_covid=1 if `i'=="Positive"
}

tab alldonor_covid if exclusion==0

gen covidtestdatenat=dofc(COVID19_NAT_SPECDT)

gen covidtestdaysnat=TX_DATE-covidtestdatenat

gen covidtestdateantig=dofc(COVID19_ANTIGEN_SPECDT)

gen covidtestdaysantig=TX_DATE-covidtestdateantig

gen covidtestdateother=dofc(COVID19_OTHER_SPECDT)

gen covidtestdaysother=TX_DATE-covidtestdateother

gen positivetestdays=.
replace positivetestdays=covidtestdaysnat if COVID19_NAT_TESTRESULT=="Positive"
replace positivetestdays=covidtestdaysantig if COVID19_ANTIGEN_TESTRESULT=="Positive"
replace positivetestdays=covidtestdaysother if COVID19_OTHER_TESTRESULT=="Positive"

gen donor_covid=0
replace donor_covid=1 if positivetestdays<=7

tab donor_covid if exclusion==0

drop if exclusion==1

} 

***TABLE 1. BASELINE CHARACTERISTICS OF COVID-19+ DONOR HEART TRANSPLANTATION
{

tab donor_covid if exclusion==0

foreach i in female ethn race ECMO_TRR IABP_TRR pvadtx vadcat status diab_don phtn cerebvasc priorctsx dhtn diab_don female_don female_male size_mism {
tab donor_covid `i' if exclusion == 0, row chi2
tab donor_covid `i' if exclusion == 0, row exact
}

foreach i in AGE END_BMI_CALC DAYSWAIT_CHRON HEMO_SYS_TCR HEMO_PA_MN_TCR HEMO_CO_TCR AGE_DON BMI_DON_CALC ISCHTIME positivetestdays{
sum `i' if exclusion == 0, detail
bysort donor_covid: sum `i' if exclusion ==0, detail
ranksum `i' if exclusion == 0, by(donor_covid)
}

}
***TABLE 2. LOGISTIC REGRESSION FOR 30-DAY MORTALITY FOLLOWING HEART TRANSPLANTATION
{
*Forwards selection of variables P<0.2
foreach i in i.race ECMO_TRR IABP_TRR pvadtx vadcat i.status diab_don phtn cerebvasc priorctsx dhtn diab_don female_don female_male size_mism AGE END_BMI_CALC DAYSWAIT_CHRON HEMO_SYS_TCR HEMO_PA_MN_TCR HEMO_CO_TCR AGE_DON BMI_DON_CALC ISCHTIME {
logit mort30daystat `i' if exclusion==0, base or
}


logit mort30daystat donor_covid female AGE END_BMI_CALC i.race ECMO_TRR IABP_TRR pvadtx vadcat HEMO_PA_MN_TCR phtn priorctsx DAYSWAIT_CHRON AGE_DON female_male ISCHTIME if exclusion==0, base or
lroc
}
***TABLE 3. SHORT-TERM OUTCOMES OF COVID-19+ DONOR HEART TRANSPLANTATION
{
foreach i in mort30daystat inhospmort deceased pulm infection graftfail cerebdeath maligdeath multiorg acuterej pacemaker stroke postdialysis{
tab `i' donor_covid if exclusion==0, col chi2
tab `i' donor_covid if exclusion==0, col exact
}
}
*3-MONTH KAPLAN-MEIER
{
stset PTIME, failure(deceased== 1) exit(time 90)
sts graph, by(donor_covid) ci risktable title("") ytitle("Survival Probability") xtitle ("Time after Transplant (Years)") graphregion(color(white)) ylab(,nogrid format(%2.1g)) 
sts test donor_covid, logrank
stsum, by(donor_covid)
sts list, by(donor_covid) at(1 30 60 90)
}

*PROPENSITY-SCORE MATCH
{
*Define treatment, outcome, and independent variable
global treatment donor_covid
global ylist mort30daystat
global xlist female AGE ethn statushigh diaflt phtn END_BMI_CALC HEMO_CO_TCR HEMO_SYS_TCR HEMO_PA_MN_TCR cerebvasc priorctsx AGE_DON female_don female_male ECMO_TRR IABP_TRR pvadtx vadcat DAYSWAIT_CHRON dhtn diab_don BMI_DON_CALC size_mism

*psmatch2
psmatch2 $treatment $xlist, outcome($ylist) caliper(.01) noreplace neighbor(1)
gen pair = _id if _treated==0
replace pair = _n1 if _treated==1
bysort pair: egen paircount = count(pair)

psgraph
twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0)

drop if paircount !=2

psgraph
twoway (kdensity _pscore if _treated==1) (kdensity _pscore if _treated==0)

twoway (kdensity _pscore if donor_covid==1) (kdensity _pscore if donor_covid==0)

tab donor_covid, missing
}

***TABLE 4. BASELINE CHARACTERISTICS OF COVID-19+ DONOR HEART TRANSPLANTATION - MATCHED
{
foreach i in female race ECMO_TRR IABP_TRR pvadtx vadcat status diab_don phtn cerebvasc priorctsx dhtn diab_don female_don female_male size_mism {
tab donor_covid `i' if exclusion == 0, row chi2
tab donor_covid `i' if exclusion == 0, row exact
}

foreach i in AGE END_BMI_CALC DAYSWAIT_CHRON HEMO_SYS_TCR HEMO_PA_MN_TCR HEMO_CO_TCR AGE_DON BMI_DON_CALC ISCHTIME positivetestdays{
sum `i' if exclusion == 0, detail
bysort donor_covid: sum `i' if exclusion ==0, detail
ranksum `i' if exclusion == 0, by(donor_covid)
}
}

***TABLE 5. SHORT-TERM OUTCOMES OF COVID-19+ DONOR HEART TRANSPLANTATION - MATCHED
{
foreach i in mort30daystat inhospmort deceased pulm infection graftfail cerebdeath maligdeath multiorg acuterej stroke postdialysis{
tab `i' donor_covid if exclusion==0, col chi2
tab `i' donor_covid if exclusion==0, col exact
}
}

*3-MONTH KAPLAN-MEIER
{
stset PTIME, failure(deceased== 1) exit(time 90)
sts graph, by(donor_covid) ci risktable title("") ytitle("Survival Probability") xtitle ("Time after Transplant (Years)") graphregion(color(white)) ylab(,nogrid format(%2.1g)) 
sts test donor_covid, logrank
stsum, by(donor_covid)
sts list, by(donor_covid) at(1 30 60 90)
}


