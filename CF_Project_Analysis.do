		***************************************************************
		/*DHS Credible Fear Project Sample - Preliminary Analysis*/
		***************************************************************

* Housekeeping
	cls
	clear all
	version 17.0
	//global root "/Users/shayleelouth/Desktop/cf-asylum-outcomes"
	cd "/Users/shayleelouth/Desktop/cf-asylum-outcomes/clean_data"

/*************************************************************************
							Summary Statistics
**************************************************************************/
	
	use "top15panel.dta"

	*-------------------------------------------------------------------
	// Summarizing key variables by year 
	sort year
	by year: sum UNHCRtotal found_decided closed_completed completed_UNHCR
		* Both found_decided and found_completed are included as closed cases represent a relevant non-affirmative interview outcome in some questions. Note : DHS did not disclose data for Romania or Cuba in 2016 		
		
	*-------------------------------------------------------------------
	// Summarizing key variables by region 
	sort intermediateregion year
	by intermediateregion: sum UNHCRtotal asylum_seekers found_decided found_completed completed_UNHCR 
		* Comparing relative sizes of displaced populations between regions. Revealing that Eastern Europe and South Asia have relatively higher rates of affirmative credible fear outcomes compared to Latin American and Caribbean regions (noting that Eastern Europe is only represented by Romania in this dataset)
	
	*-------------------------------------------------------------------
	// Panel summary statistics 
	sort country year
	xtsum UNHCRtotal asylum_seekers found_decided found_completed
		* Here we can see that total displaced populations vary more between countries than within countries overtime, whereas the rates of affirmative CF outcomes vary slightly more over time than between countries.
		
		
/************************************************************************
						Visualizing the Dataset
*************************************************************************/
	cd "../graphs"
	
* Graphing the shifts in total displaced populations by country over time (Graph A)
	// Matrix version
	xtline UNHCRtotal, xtitle("Year") ///
		byopts(title("Total Displaced Populations by Country Over Time"))
		graph export xtUNHCRtotal.png, replace
		
	// Overlay version
	xtline UNHCRtotal, overlay xtitle("Year") ///
		title("Total Displaced Populations by Country (Overlay)")
		graph export xtUNHCRtotal_overlay.png, replace
	
* Graph A without Venezuela or Colombia to look at countries with smaller displaced populations (Graph B)
	// Matrix version
		xtline UNHCRtotal if !inlist(country, "Venezuela", "Colombia"), ///
			byopts(title("Total UNHCR Displaced without VZ or CL")) xtitle("Year")
			graph export xtUNHCR_noC_noV.png, replace 
		
	// Overlay version
		xtline UNHCRtotal if !inlist(country, "Venezuela", "Colombia"), ///
			overlay title("Total UNHCR Displaced without VZ or CL (Overlay)")
			graph export xtUNHCR_noC_noV_overlay.png, replace 
	
* Graphing U.S. asylum cases as a proportion of global displaced population by year and country (Graph C)
	twoway scatter completed_UNHCR year, mlabel(country) title("Completed DHS Cases to UNHCR Total Ratio")
		graph export scatter_comp_UNHCR.png, replace
		
* Graphing percent of cases represented by each outcome over time by country (Graph G)
	xtline found_completed not_completed closed_completed, byopts(title("% Cases by CF Outcome"))
		graph export cf_outcome_proportion_matrix.png, replace
	
* Graphs with collapsed data

	// Subsetting annual data summed across all fifteen countries
	collapse (sum) completed CFfound CFnotfound closed UNHCRtotal asylum_seekers, by(year)
		gen found_completed= CFfound/completed
		gen completed_UNHCR=completed/UNHCRtotal
		gen closed_completed= closed/completed
		gen notfound_completed= CFnotfound/completed
		
	// Graphing trends in global displaced population totals over time (Graph D)
		twoway line UNHCRtotal asylum_seekers year, title("Total Displaced Pop. for Top 15 Countries") 
			graph export Total_UNHCR.png, replace
		
	// Graphing share of global displaced population processed by DHS asylum over time (Graph E)
		twoway line completed_UNHCR year, title("Proportion Completed to Displaced (Total Top 15)") 
			graph export Total_completed_UNHCR.png, replace 
		
	// Graphing percent of cases represented by each interview outcome over time (Graph F)
		twoway line found_completed closed_completed notfound_completed year, ///
			title("% Asylum Cases by Outcome (Total Top 15)")
			graph export Total_CfOutcomes.png, replace
		
/***********************************************************************
								Regressions
************************************************************************/
	clear
	cd "../clean_data"
	use "top15panel.dta"

* Fixed Effects Estimator
	xtreg found_decided asylum_seekers Cen_Am Europe South_Am Asia covid_year, fe
		estimates store fixed

* Random Effects Estimator 
	xtreg found_decided asylum_seekers Cen_Am Europe South_Am Asia covid_year, re
		estimates store random
		
* Hausman Test to determine if FE or RE is preferred
	hausman fixed random
