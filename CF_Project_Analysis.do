		***************************************************************
		/*DHS Credible Fear Project Sample - Preliminary Analysis*/
		***************************************************************

* Housekeeping
	cls
	clear all
	version 17.0
	//global root "C:\STATA\Stata Code Sample"
	global root "/Users/shayleelouth/Desktop/STATA/Stata Code Sample"
	cd "/Users/shayleelouth/Desktop/STATA/Stata Code Sample"

/*************************************************************************
							Summary Statistics
**************************************************************************/

	//use "$root\top15panel.dta"
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

	// Graphing the shifts in total displaced populations by country over time (Graph A)
	xtline UNHCRtotal, title("UNHCR Total Displaced Population") //saving(xtUNHCRtotal.png) 
	
	// Graph A without Venezuela or Colombia to look at countries with smaller displaced populations (Graph B)
	xtline UNHCRtotal if !inlist(country, "Venezuela", "Colombia"), title("Total UNHCR Displaced without VZ or CL") //saving(xtUNHCR_noC_noV.png) 
	
	// Graphing U.S. asylum cases as a proportion of global displaced population by year and country (Graph C)
	twoway scatter completed_UNHCR year, mlabel(country) title("Completed DHS Cases to UNHCR Total Ratio") //saving(scatter_comp_UNHCR.png)
	
	// Subsetting annual data summed across all fifteen countries
	collapse (sum) completed CFfound CFnotfound closed UNHCRtotal asylum_seekers, by(year)
		gen found_completed= CFfound/completed
		gen completed_UNHCR=completed/UNHCRtotal
		gen closed_completed= closed/completed
		gen notfound_completed= CFnotfound/completed
		
		// Graphing trends in global displaced population totals over time (Graph D)
		twoway line UNHCRtotal asylum_seekers year, title("Total Displaced Pop. for Top 15 Countries")  //saving(Total_UNHCR.png)
		
		// Graphing share of global displaced population processed by DHS asylum over time (Graph E)
		twoway line completed_UNHCR year, title("Proportion Completed to Displaced (Total Top 15)") //saving(Total_completed_UNHCR.png)
		
		// Graphing percent of cases represented by each interview outcome over time (Graph F)
		twoway line found_completed closed_completed notfound_completed year, title("% Asylum Cases by Outcome (Total Top 15)") //saving(Total_CfOutcomes.png) 
		
		clear
		//use "$root\top15panel.dta"
		use "top15panel.dta"
	
	// Graphing percent of cases represented by each outcome over time by country (Graph G)
	xtline found_completed not_completed closed_completed, title("% Cases by CF Outcome")
/***********************************************************************
								Regressions
************************************************************************/

* Fixed Effects Estimator
	xtreg found_decided asylum_seekers Cen_Am Europe South_Am Asia covid_year, fe
		estimates store fixed

* Random Effects Estimator 
	xtreg found_decided asylum_seekers Cen_Am Europe South_Am Asia covid_year, re
		estimates store random
		
* Hausman Test to determine if FE or RE is preferred
	hausman fixed random
