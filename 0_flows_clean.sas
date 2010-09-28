/* **********************************************************************************/
/* CREATED BY:      Jesse Blocher (UNC-Chapel Hill)                                               
/* MODIFIED BY:                                                    
/* DATE CREATED:    Aug 2010                                                                                                            
/* PROG NAME:       flows_clean.sas                                                              
/* Project:         Morningstar US Open Ended Funds Portfolio Data Merge
/* This File:       Flows are much better; mostly renames variables
/************************************************************************************/

%include 'morn_merge_header.sas'; *header file with basic options and libraries;
%include 'morn_macros.sas'; *Macro file;

data morn.flows_clean (drop = col1-col3);
	set morn.flows;
	
	FundId = col1;
	label FundId = 'Fund ID';
	
	port_date = col2;
	label port_date = 'Portfolio Date';
	port_year = year(port_date);
	
	flow = col3;
	label = 'Fund Flow';
run;

proc contents data = morn.flows_clean; run;

proc sort data = morn.flows_clean out = tester nodupkey;
by fundid port_date;
run;

title 'Time Frequency of data';
proc freq data = morn.flows_clean;
tables port_year;
run;