/* **********************************************************************************/
/* CREATED BY:      Jesse Blocher (UNC-Chapel Hill)                                               
/* MODIFIED BY:                                                    
/* DATE CREATED:    Aug 2010                                                                                                            
/* PROG NAME:       morn_macros.sas                                                              
/* Project:         Morningstar US Open Ended Funds Portfolio Data Merge
/* This File:       Set of macros to clean the Morningstar Data
/************************************************************************************/


* this checks column8 for any alpha data;
* returns one dataset, which was fine to begin with, as it should be;
* another dataset which needs col9 analyzed;


** Check: Alpha, special chars that could be in numbers, missing, and empty string;
%macro filter_col_clean(col = );
((anyalpha(&col) + indexc(&col,"/","%")) = 0) and not missing(&col) and (trim(&col) ne "")
%mend;
%macro filter_col_dirty(col = );
((anyalpha(&col) + indexc(&col,"/","%")) ne 0) or missing(&col) or (trim(&col) = "")
%mend;

%macro col8_num_only(ds_in=, ds_out_clean=, ds_out_dirty=, lastcol = );

data clean1 dirty1;
	set &ds_in;

	if %filter_col_clean(col = col8) then output clean1;
	if %filter_col_dirty(col = col8) then output dirty1;

run;

data clean2 dirtystill;
	set clean1 ;
	
	*these work for the fixed data;
	colnum8 = Col8*1;
	colnum9 = Col9*1;
	colnum10 = Col10*1;
	colnum11 = Col11*1;
	colnum13 = Col13*1;
	colnum14 = Col14*1;
	colnum15 = Col15*1;
	
	if _ERROR_ = 1 then output dirtystill;
	else output clean2;
run;
/* Debug
proc contents data = clean1;
proc contents data = clean2;
proc contents data = dirtystill;
run;
*/
proc append base = dirty1 data = dirtystill force; run;

data &ds_out_clean (drop = colnum8-colnum11 colnum13-colnum15);
	set clean2 (drop = col8-col11 col13-&lastcol);
	
	Col8 = colnum8;
	Col9 = colnum9;
	Col10 = colnum10;
	Col11 = colnum11;
	Col13 = colnum13;
	Col14 = colnum14;
	Col15 = colnum15;
run;
	
data &ds_out_dirty;
	set dirty1;
run;
	
run;
%mend;

%macro col9_num_only(ds_in=, ds_out_clean=, ds_out_dirty=, lastcol=);

data clean1 dirty1;
	set &ds_in;

	if %filter_col_clean(col = col9) = 0 then output clean1;
	if %filter_col_dirty(col = col9) ne 0 then output dirty1;

run;

data clean2 dirtystill;
	set clean1 ;
	
	*these work for the Clean1 dataset because we know they are OK after column8;
	length colchar7 $ 79;
	colchar7 = trim(col7) || ' ' || col8; *concatenation operator;
	
	
	colnum8 = Col9*1;
	colnum9 = Col10*1;
	colnum10 = Col11*1;
	colnum11 = Col12*1;
	colchar12 = Col13;
	colnum13 = Col14*1;
	colnum14 = Col15*1;
	colnum15 = Col16*1;
	
	if _ERROR_ = 1 then output dirtystill;
	else output clean2;
run;

data &ds_out_clean (drop = colchar7 colnum8-colnum11 colchar12 colnum13-colnum15);
	set clean2 (drop = col7-&lastcol);
	
	Col7 = colchar7;
	Col8 = colnum8;
	Col9 = colnum9;
	Col10 = colnum10;
	Col11 = colnum11;
	Col12 = colchar12;
	Col13 = colnum13;
	Col14 = colnum14;
	Col15 = colnum15;
run;
	
data &ds_out_dirty;
	set dirty1;
run;
	
run;
%mend;

%macro set_field_types(ds_in=, ds_out=, err_out=);

data &ds_out (drop = col1-col15) &err_out ;
	set &ds_in ;
	where ~missing(col1) and ~missing(col2);
	fundid = col1;
	label fundid = 'Fund ID';
	
	port_date = input(col2,yymmdd10.);
	label port_date = 'Porfolio Date';
	format port_date yymmdd10.;
	port_year = year(port_date);
	
	stkid = col3;
	label stkid = 'ISIN';
	
	cusip = col4;
	label cusip = '9 digit CUSIP';
	
	type_cd = col5;
	label type_cd = 'Asset Type Code';
	
	country = col6;
	label country = 'Country';
	
	length security $ 80;
	
	security = col7;
	label security = 'Security Name';
	
	shares = col8;
	label shares = 'Number of Shares Owned';
	
	sharechange = col9;
	label sharechange = 'Change in Shares';
	
	marketvalue = col10;
	label marketvalue = 'Market Value of Shares as reported by manager';
	
	weight = col11;
	** Note, I am concerned that some of these are in decimals, others percent;
	*if weight < 1 then weight = weight*100;
	label weight = 'Portfolio Weight in percentage points';

	
	* note: this is a date field;
	* the question mark supresses errors to output, but will still set the value of _ERROR_ to 1 so create err dataset;
	maturity = input(trim(col12),? yymmdd10.);
	label maturity = 'Maturity if holding is bond';
	format maturity yymmdd10.;
	mat_year = year(maturity);
	
	coupon = col13;
	label coupon = 'Coupon if holding is bond in pct';
	
	
	industry_code = col14;
	label industry_code = 'Industry Code';

	sector_code = col15;
	label sector_code = 'Sector Code';
	
	if _ERROR_ = 1 then output &err_out ;
	else output &ds_out ;
run;


%mend;

%macro iterate_set_fields();
	%do yy = 2002 %to 2009;
		%set_field_types(ds_in=ms_work.porthold&yy, ds_out=temp&yy , err_out=ms_work.err&yy );
	%end;
%mend;



%macro print_subsample(ds =, num = );
*subsample and print;
proc surveyselect data = &ds
	method = srs
	n = &num
	out = temp;
run;

proc print data = temp; run;

%mend;

%macro clean_datatype(ds_in=, ds_out_clean=, ds_out_dirty=);

data clean2 dirtystill;
	set &ds_in; ;
	
	*these work for the fixed data;
	colnum8 = Col8*1;
	colnum9 = Col9*1;
	colnum10 = Col10*1;
	colnum11 = Col11*1;
	colnum13 = Col13*1;
	colnum14 = Col14*1;
	colnum15 = Col15*1;
	
	if _ERROR_ = 1 then output dirtystill;
	else output clean2;
run;

/* Debug
proc contents data = clean1;
proc contents data = clean2;
proc contents data = dirtystill;
run;
*/


data &ds_out_clean (drop = colnum8-colnum11 colnum13-colnum15);
	set clean2 (drop = col8-col11 col13-col15);
	
	Col8 = colnum8;
	Col9 = colnum9;
	Col10 = colnum10;
	Col11 = colnum11;
	Col13 = colnum13;
	Col14 = colnum14;
	Col15 = colnum15;
run;
	
data &ds_out_dirty;
	set dirtystill;
run;
	

%mend;

%macro clean_datatype2(ds_in=, ds_out_clean=, ds_out_dirty=);

data clean2 dirtystill;
	set &ds_in; ;
	
	*these work for the fixed data;
	colnum8 = C8*1;
	colnum9 = C9*1;
	colnum10 = C10*1;
	colnum11 = C11*1;
	colnum13 = C13*1;
	colnum14 = C14*1;
	colnum15 = C15*1;
	
	if _ERROR_ = 1 then output dirtystill;
	else output clean2;
run;

data &ds_out_clean (drop = colnum8-colnum11 colnum13-colnum15 C1-C15);
	set clean2 ;
	Col1 = C1;
	Col2 = C2;
	Col3 = C3;
	Col4 = C4;
	Col5 = C5;
	Col6 = C6;
	Col7 = C7;
	Col8 = colnum8;
	Col9 = colnum9;
	Col10 = colnum10;
	Col11 = colnum11;
	Col12 = C12;
	Col13 = colnum13;
	Col14 = colnum14;
	Col15 = colnum15;
run;
	
data &ds_out_dirty;
	set dirtystill;
run;

%mend;