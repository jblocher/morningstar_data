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

data errdata;
	set ms_work.errdata2002 (keep = Col1-Col15) ms_work.errdata2003 (keep = Col1-Col15);
run;

data fixed_errdata1 (drop = Col8-Col12);
  set errdata;
	newcol8 = Col9;
	newcol9 = Col10;
	newcol10 = Col11;
	newcol11 = Col12;
	newcol12 = Col13;
	Col14 = .;
	Col8 = .;
run;

data ms_work.fixed_errdata (drop=newcol8-newcol12);
	set fixed_errdata1;
	Col9 = newcol9;
	Col10 = newcol10;
	Col11 = newcol11;
	Col12 = newcol12;
	Col8 = newcol8;
run;
