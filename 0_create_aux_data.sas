/* *************************************************************************/
/* CREATED BY:      Jesse Blocher (UNC-Chapel Hill)                                               
/* MODIFIED BY:                                                    
/* DATE CREATED:    July 2010                                                                                                            
/* PROG NAME:       create_aux_data.sas                                                              
/* Project:         Morningstar US Open Ended Funds Portfolio Data Merge
/* This File:       Converts Type Codes to real variable names, enters sector codes
/************************************************************************************/
 
%include 'morn_merge_header.sas'; *header file with basic options and libraries;


/* Datasets required to run:
 * morn.portfolio_type_codes		: Excel Sheet converted to SAS via Stat Transfer
 */
 
/* Datasets Produced:
 * morn.portfolio_type_codes_renamed	: Cleaned and renamed data for use
 * morn.sector_codes					: Sector codes entered and small data set created
 */
 


proc contents data = morn.portfolio_type_codes;
proc print data = morn.portfolio_type_codes;
run;

data morn.portfolio_type_codes_renamed (drop = c1 c2);
	set morn.portfolio_type_codes;
	
	*because stattransfer picked up the header row;
	if c1 = 'Type Code' then delete;
	
	type_cd = substr(c1,1,2);
	label type_cd = 'Asset Type Code';
	
	type_name = c2;
	label type_name = 'Asset Type Name';
run;

proc contents data = morn.portfolio_type_codes_renamed;
proc print data = morn.portfolio_type_codes_renamed;
run;

data temp;
	infile datalines delimiter=',';
   	input sector_code_char $2. sector_name $20.;
   	datalines;
1 Software
2 Hardware
3 Media
4 Telecommunication
5 Healthcare
6 Consumer Service
7 Business Service
8 Financial Service
9 Consumer Goods
10Industrial Materials
11Energy
12Utilities
;

run;

data morn.sector_codes (drop = sector_code_char);
	set temp;
	sector_code=input(sector_code_char,best8.);
run;

proc contents data = morn.sector_codes;
proc print data = morn.sector_codes;
run;
