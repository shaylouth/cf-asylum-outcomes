	***************************************************************
		/*DHS Credible Fear Project Sample - Cleaning Data*/
	***************************************************************

* Housekeeping
	cls
	clear all
	version 17.0
	//global root "C:\STATA\Stata Code Sample"
	global root "/Users/shayleelouth/Desktop/STATA/Stata Code Sample"
	cd "/Users/shayleelouth/Desktop/STATA/Stata Code Sample"
	
/*************************************************************************
						Cleaning UNHCR dataset
**************************************************************************/

	//import delimited "$root\population.csv", case(preserve) clear
	import delimited "population.csv", case(preserve) clear

	drop v4 v5 // dropping empty variable categories for receiving country
	
	rename v1 year
	rename v2 country
	rename v3 ISO
	rename v6 refugees
	rename v7 asylum_seekers
	rename v8 IDPs
	rename v9 OIPs
	rename v10 stateless
	rename v11 host
	rename v12 others
	
	drop if _n<15 // dropping observations containing dataset descriptions & varnames
	
	// correcting variable types and setting "-" to missing values
	destring year refugees asylum_seekers IDPs, replace 
	destring OIPs stateless host others, replace ignore(`"-"')
	
	// correcting differences in country names from DHS data
	replace country="Dominican Republic" if country=="Dominican Rep." 
	replace country="Venezuela" if country=="Venezuela (Bolivarian Republic of)"
	
	//save "$root\UNHCR.dta", replace 
	save "UNHCR.dta", replace
clear

/*************************************************************************
						Cleaning Region & ISO Data
**************************************************************************/

	//import delimited "$root\all.csv"
	import delimited "all.csv"

	// Dropping unnecessary
	rename alpha3 ISO 
	drop name iso_31662 countrycode regioncode subregioncode intermediateregioncode

	// Adding subregion to intermediateregion for countnries missing intermediateregion 
	replace intermediateregion = subregion if intermediateregion=="" 
	
	// Assigning numeric categorical values
	encode region, gen(region1)
	encode subregion, gen(subregion1)
	encode intermediateregion, gen(intregion1)
	
	//save "$root\ISO.dta", replace
	save "ISO.dta", replace
clear 

/**************************************************************************
							Cleaning DHS Data
**************************************************************************/ 

	//import delimited "$root\DoHSdata.csv", case(preserve) clear
	import delimited "DoHSdata.csv", case(preserve) clear

* Renaming variables in preparation to reshape data from wide to long form
	rename v1 country
	recast str country
	
	// loops to rename all variables representing completed cases to completed[year] format, repeating for other case categories
	forvalues x = 2(4)25 {   
		local year = v`x'[2]
		rename v`x' completed`year'
	} 
	
	forvalues x = 3(4)25 {
		local year = v`x'[2]
		rename v`x' CFfound`year'
	}

	forvalues x = 4(4)25 {
		local year = v`x'[2]
		rename v`x' CFnotfound`year'
	}
	
	forvalues x = 5(4)25 {
		local year = v`x'[2]
		rename v`x' closed`year'
	}
	
	// dropping unnecessary observations (headings and notes)
	drop if _n < 5 
	drop if _n > 17


* Reshaping Dataset
	reshape long completed CFfound CFnotfound closed, i(country) j(year)
	
* Correcting variable types & converting withheld "D" values to missing  
	destring completed, replace ignore(`","') force
		la var completed "Interviews completed by DHS"
	destring CFfound, replace ignore(`","') force
		la var CFfound "Interviews where CF found"
	destring CFnotfound, replace ignore(`","') force
		la var CFnotfound "Interviews where CF not found"
	destring closed, replace ignore(`","') force
		la var closed "Asylum cases closed"

	save "DHS.dta", replace
clear
		
/*************************************************************************
			Merging Datasets & Creating New Variables
**************************************************************************/
	use "DHS.dta"

* Joining UNHCR data with DoHS data by country and year

	//joinby country year using "$root\UNHCR.dta"
	joinby country year using "UNHCR.dta"
	//joinby ISO using "$root\ISO.dta"
	joinby ISO using "ISO.dta"
	
* Creating new variables 

	// Expanding categorical region variable into indicator variables 
	xi i.intregion1
	rename (_Iintregion_3 _Iintregion_8 _Iintregion_16 _Iintregion_19) (Cen_Am Europe South_Am Asia)

	// Comparing DHS Outcomes to UNHCR Total Displaced Population 
	egen UNHCRtotal = rowtotal(refugees asylum_seekers IDPs OIPs stateless host others) 
		la var UNHCRtotal "Total displaced from UNHCR"
	gen CFfound_UNHCR = CFfound/UNHCRtotal
		la var CFfound_UNHCR "CF found to UNHCR total ratio"
	gen completed_UNHCR = completed/UNHCRtotal
		la var completed_UNHCR "DHS cases to UNHCR population ratio"
		
	// Representing CF outcome as percentage of DHS completed cases 
	gen found_completed = CFfound/completed
		la var found_completed "% cases CF found"
	gen not_completed = CFnotfound/completed
		la var not_completed "% cases CF not found"
	gen closed_completed= closed/completed
		la var closed_completed "% cases closed"
	
	// Representing CF outcome as percentage of DHS cases where decision was made
	gen cases_decided= completed-closed
		la var cases_decided "Cases CF decision made"
	gen found_decided = CFfound/cases_decided
		la var found_decided "Cases CF found as % of cases decided"
	gen not_decided = CFnotfound/cases_decided
		la var not_decided "Cases CF not found as % of cases decided"
		
	// Generating variable: basic representation of COVID-19 Pandemic
	gen covid_year = 0
		replace covid_year=1 if year>2019
		la var covid_year "Indicator, Pre- or Post-Covid-19"

* Setting dataset as panel data 
	encode country, gen(country1)
	xtset country1 year
	xtdescribe
	
	//save "$root\top15panel.dta", replace // Saving merged data
	save "top15panel.dta", replace // Saving merged data
