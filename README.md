<!DOCTYPE html>
<html>
<body>
  
# Public Health & U.S. Asylum Outcomes Project

## Description

This repository contains the code and raw data needed to reproduce the results of "Factors Influencing Asylum Outcomes in the United States: Preliminary Analysis" by Shaylee Louth, as well as several products of the code. The goal of the project was to observe fluctuations in the outcomes of a critical stage of the U.S. asylum process, the Credible Fear Interview, and identify potential relationships between these outcomes and a range of factors. The focus of this preliminary stage was on observing fluctuations in asylum outcomes during the COVID-19 pandemic, which is the focus of the paper as well. The paper is included in this repository under the name "COVID19_Asylum_Outcomes.pdf".

Below I have included a directory of the files in this respository, instructions to run the code, and some additional information about the data sources of this project. If you have any questions regarding this project, please do not hesitate to reach out to shaylee.louth@gmail.com.

## Instructions & Directory

This respository contains two code files, one to clean the data (CF_project_cleaning.do) and one to run the analysis (CF_project_analysis.do). These files can be run one after the other to produce the results found in "Factors Influencing Asylum Outcomes in the United States: Preliminary Analysis." 

**Directory**
<ul> 
  <li><b>CF_project_cleaning.do</b> - Stata code file to clean the raw data, resulting in the code files contained in <i> clean_data </i>
    <ul> 
      <li>Input: <i>raw_data</i></li>
      <li>Output: <i>clean_data</i></li>
    </ul>
  
  <li><b>CF_project_analysis.do</b> - Stata code file to run the analysis used in the associated paper. Because the cleaned data is already saved in this repository, this file can be run on it's own without prior use of the cleaning file.
    <ul> 
      <li>Input: <i>clean_data</i></li>
      <li>Output: <i>graphs</i></li>
    </ul>
  </li>
  
  <li><b>raw_data</b> - Raw data files to be used in <i>CF_project_cleaning.do</i>. See Data Sources below for more details.
  </li>
  
  <li><b>clean_data</b> - Clean data files in .dta format to be used in <i>CF_project_analysis.do</i>. Produced by <i>CF_project_cleaning.do</i>
  </li>
  
  <li><b>graphs</b> - Contains the graphs produced by <i>CF_project_analysis.do</i>. Running the analysis code file with modifications will replace the existing graphs.
  </li>
  
</ul>


## Data Sources

**DHS Data** - This dataset from the U.S. Department of Homeland Security contains annual metrics for asylum seekers' Credible Fear Interview outcomes. Countries represented include the top fifteen most common countries of origin for asylum seekers in the U.S., as well as an "all other nationalities" category. Three outcomes are reported - credible fear (CF) found, CF not found, and closed (when asylum applications are closed) - as well as the total of these three outcomes, denoted as "completed." 

 *Source: https://www.dhs.gov/immigration-statistics/readingroom/RFA/credible-fear-cases-interview*

**UNHCR Population Data** - This UNHCR dataset contains global annual population totals for a number of categories of displaced people by year and by country of origin.

*Source: https://www.unhcr.org/refugee-statistics/download/?url=H9ihDu*

*Data Definitions: https://www.unhcr.org/refugee-statistics/methodology/*

</body>
<html>



