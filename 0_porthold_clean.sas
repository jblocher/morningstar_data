/* **********************************************************************************/
/* CREATED BY:      Jesse Blocher (UNC-Chapel Hill)                                               
/* MODIFIED BY:                                                    
/* DATE CREATED:    Aug 2010                                                                                                            
/* PROG NAME:       porthold_clean.sas                                                              
/* Project:         Morningstar US Open Ended Funds Portfolio Data Merge
/* This File:       Calls macros to clean the Portfolio Holdings data. Yuk.
/************************************************************************************/

%include 'morn_merge_header.sas'; *header file with basic options and libraries;
%include 'morn_macros.sas'; *Macro file;


* Get contents to see what data types we are dealing with;
%macro process_porthold();
	proc contents data = morn.porthold1980to1992 ;
	proc print data = morn.porthold1980to1992 (obs = 100);
	run;
	
	%do ds = 1993 %to 2009;
	proc contents data = morn.porthold&ds ;
	proc print data = morn.porthold&ds (obs = 100);
	run;
	%end;
%mend process_porthold;

%macro all_contents(base = , start =, finish =);
	%do end = &start %to &finish;
	proc contents data = &base.&end;
	run;
	%end;

%mend;

*%process_porthold;
/*

*****************************************;
** Process the early 1980 to 1992 dataset;
*****************************************;

* first, we divide on col8, keep those that pass in our base dataset;
%col8_num_only(ds_in=morn.porthold1980to1992, ds_out_clean=ms_work.porthold1980to1992, ds_out_dirty=ms_work.porthold1980to1992dirty);

* next we check column9. Here, because we know col9 is ok, we expect the dirty data set to be empty;
%col9_num_only(ds_in=ms_work.porthold1980to1992dirty, ds_out_clean=ms_work.porthold1980to1992clean, ds_out_dirty=ms_work.porthold1980to1992dirty2);


*****************************************;
** Now, Append 1993 to 2001 because they do not have data issues;
*****************************************;


data ms_work.porthold2001_1980;
	set morn.porthold2001;
run;

proc append base = ms_work.porthold2001_1980 data = ms_work.porthold1980to1992 force;
proc append base = ms_work.porthold2001_1980 data = ms_work.porthold1980to1992clean force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1993 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1994 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1995 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1996 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1997 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1998 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold1999 force;
proc append base = ms_work.porthold2001_1980 data = morn.porthold2000 force;
run;

*****************************************;
** Now, 2009 because it has the longest description field;
*****************************************;


* We are going to bail on doing this in SAS. Dump it out to Excel and clean manually;

%col8_num_only(ds_in=morn.porthold2009, ds_out_clean=ms_work.porthold2009, ds_out_dirty=morn.porthold2009dirty, lastcol = col20);
%col8_num_only(ds_in=morn.porthold2008, ds_out_clean=ms_work.porthold2008, ds_out_dirty=morn.porthold2008dirty, lastcol = col21);
%col8_num_only(ds_in=morn.porthold2007, ds_out_clean=ms_work.porthold2007, ds_out_dirty=morn.porthold2007dirty, lastcol = col21);
%col8_num_only(ds_in=morn.porthold2006, ds_out_clean=ms_work.porthold2006, ds_out_dirty=morn.porthold2006dirty, lastcol = col17);
%col8_num_only(ds_in=morn.porthold2005, ds_out_clean=ms_work.porthold2005, ds_out_dirty=morn.porthold2005dirty, lastcol = col16);
%col8_num_only(ds_in=morn.porthold2004, ds_out_clean=ms_work.porthold2004, ds_out_dirty=morn.porthold2004dirty, lastcol = col16);
%col8_num_only(ds_in=morn.porthold2003, ds_out_clean=ms_work.porthold2003, ds_out_dirty=morn.porthold2003dirty, lastcol = col15);
%col8_num_only(ds_in=morn.porthold2002, ds_out_clean=ms_work.porthold2002, ds_out_dirty=morn.porthold2002dirty, lastcol = col16);



*proc contents data = ms_work.porthold2001_1980;run;
*%all_contents(base = ms_work.porthold, start=2002, finish=2009);

*****************************************;
***** Here, for the first (very large) set of already clean data, we rename and format all the fields *******;
*****************************************;

%set_field_types(ds_in=ms_work.porthold2001_1980, ds_out=tempporthold2001_1980, err_out=ms_work.err2001_1980);
%iterate_set_fields();

** Testing ;
*proc contents data = tempporthold2001_1980;run;
*%all_contents(base = temp, start=2002, finish=2009);

** Now, we append the main holdings data all together ;
data morn.porthold_main_clean;
	set tempporthold2001_1980;
run;

%macro iterate_append();
	%do yy = 2002 %to 2009;
		proc append base = morn.porthold_main_clean data = temp&yy ; run;
	%end;
%mend;

%iterate_append();

*****************************************;
*** Now, we bring in the manually cleaned data. This was all dumped out above and is a small part of the dataset;
*****************************************;

* Testing;
*proc contents data = ms_work.porthold2002_6clean_manually;run;
*proc contents data = ms_work.porthold2007clean_manually;run;
*proc contents data = ms_work.porthold2008clean_manually;run;
*proc contents data = ms_work.porthold2009clean_manually;run;


%clean_datatype2(ds_in=ms_work.porthold2002_6clean_manually, ds_out_clean=temp2002_6, ds_out_dirty=dirty2002_6);
%clean_datatype2(ds_in=ms_work.porthold2007clean_manually, ds_out_clean=temp2007, ds_out_dirty=dirty2007);
%clean_datatype2(ds_in=ms_work.porthold2008clean_manually, ds_out_clean=temp2008, ds_out_dirty=dirty2008);
%clean_datatype2(ds_in=ms_work.porthold2009clean_manually, ds_out_clean=temp2009, ds_out_dirty=dirty2009);

*****************************************;
* This is only four records that dumped out above, missed my initial filter;
*****************************************;

%clean_datatype(ds_in=ms_work.fixed_errdata, ds_out_clean=temp_err_fixed, ds_out_dirty=hopefully_not_still_dirty);

*proc contents data = temp2002_6;run;
*proc contents data = temp2007;run;
*proc contents data = temp2008;run;
*proc contents data = temp2009;run;

data ms_work.manually_cleaned_master;
	set temp2008;
run;
proc append base = ms_work.manually_cleaned_master data = temp2007 force; run;
proc append base = ms_work.manually_cleaned_master data = temp2002_6 force; run;
proc append base = ms_work.manually_cleaned_master data = temp2009 force; run;
proc append base = ms_work.manually_cleaned_master data = temp_err_fixed force; run;

%set_field_types(ds_in=ms_work.manually_cleaned_master, ds_out=temp_cleaned_master);

proc append base = morn.porthold_main_clean data = temp_cleaned_master; run;
*/
*** DONE ***;
** Now, Summary Stats - Pre Cleaning of data VALUES now that we have the types ok;
title 'Pre-Fixing Stats';
proc contents data = morn.porthold_main_clean; run;

proc freq data = morn.porthold_main_clean;
tables sector_code industry_code mat_year port_year type_cd country;
run;

options ls = max;
proc means data = morn.porthold_main_clean N NMISS mean std min p1 p5 p25 p50 p75 p95 p99 max;
var shares sharechange marketvalue weight coupon;
run;

proc sql;
	title 'How many records have invalid maturity i.e. before portfolio date';
	select count(*)
	from morn.porthold_main_clean
	where maturity < port_date and ~missing(maturity);
	
	
quit;

title 'Port Year 1900 record';
proc print data = morn.porthold_main_clean (obs = 50);
where port_year = 1900;
run;


data morn.porthold_main_clean_fixed;
	set morn.porthold_main_clean;
	* First, fix non-integer sector codes. Going to set to missing;
	if mod(sector_code,1) ne 0 then sector_code = .;
	
	* Second fix dates. One Port_date of 1900? Check this one out. Is it 2000?;
	* checked. It is not 2000. I do not see a good place for it, but it seems ok to delete;
	if port_year = 1900 then delete;

	* Third, Maturity Dates. Set all earlier than 1980 to missing;
	if mat_year < 1980 then do;
		maturity = .;
		mat_year = .;
	end;
	
	* Fourth, take care of zeros. Lots of them. In Shares, ShareChange, MarketValue, Weight, Coupon. In all cases, set to missing, except maybe sharechange.;
	* If marketvalue = 0 then marketvalue = .;
	* if weight = 0 then weight = .;
	* if coupon = 0 then coupon =.;
	*** Not sure about this now ***;
run;

** Now, Summary Stats - Post Fix;
title '***************  Post-Fixing Stats ********* This is final dataset *************';
proc contents data = morn.porthold_main_clean_fixed; run;

proc freq data = morn.porthold_main_clean_fixed;
tables sector_code industry_code mat_year port_year type_cd country;
run;

options ls = max;
proc means data = morn.porthold_main_clean_fixed N NMISS mean std min p1 p5 p25 p50 p75 p95 p99 max;
var shares sharechange marketvalue weight coupon;
run;