/* **********************************************************************************/
/* CREATED BY:      Jesse Blocher (UNC-Chapel Hill)                                               
/* MODIFIED BY:                                                    
/* DATE CREATED:    Aug 2010                                                                                                            
/* PROG NAME:       morn_port_stats_conv.sas                                                              
/* Project:         Morningstar US Open Ended Funds Portfolio Data Merge
/* This File:       Stats are pretty easy comparet to holdings
/************************************************************************************/

%include 'morn_merge_header.sas'; *header file with basic options and libraries;
%include 'morn_macros.sas'; *Macro file;
/*
proc contents data = morn.stat;
proc print data = morn.stat(obs = 100);
run;


                            Alphabetic List of Variables and Attributes
 
                                    #    Variable    Type    Len

                                    1    Col1        Char     10
                                    2    Col2        Char     10
                                    3    Col3        Char     10
                                    4    Col4        Num       8
                                    5    Col5        Num       8
                                    6    Col6        Num       8
                                    7    Col7        Num       8
                                    8    Col8        Num       8
                                    9    Col9        Num       8
                                   10    Col10       Num       8
                                   11    Col11       Num       8
                                   12    Col12       Num       8
                                   13    Col13       Num       8
                                   14    Col14       Num       8
                                   15    Col15       Num       8
                                   16    Col16       Num       8
                                   17    Col17       Num       8
                                   18    Col18       Num       8
                                   19    Col19       Num       8
                                   20    Col20       Num       8
                                   21    Col21       Num       8
                                   22    Col22       Num       8
                                   23    Col23       Num       8
                                   24    Col24       Num       8
                                   25    Col25       Num       8
                                   26    Col26       Num       8
                                   27    Col27       Num       8
                                   28    Col28       Num       8
                                   29    Col29       Num       8
                                   30    Col30       Num       8
                                   31    Col31       Num       8
 
Portfolio stats:
Fundid;portfoliodate;previousportfoliodate;totinvestment;#holdings;equitystylebox;fixedincome stylebox;
%stock(long);%bond(long);%preferred(long);%convertible(long);%cash(long);
%other(long);%stock(net);%bond(net);%preferred(net);%convertible(net);%cash(net);%other(net);%sector1-12

*/
/* OK, my paranoia has been settled - all these seemed to have imported just fine;
%macro all_contents(base = , start =, finish =);
	%do end = &start %to &finish;
	proc contents data = &base.&end;
	run;
	%end;

%mend;

proc contents data = morn.stat1980to1992; run;
%all_contents(base=morn.stat, start=1993, finish=2009);
*/

data morn.portfolio_statistics_only (drop = col1-col31);
	set morn.stat;
	fundid = col1;
	label fundid = 'Fund ID';
	
	port_date = input(col2,yymmdd10.);
	label port_date = 'Porfolio Date';
	format port_date yymmdd10.;
	
	prv_port_date = input(col3,yymmdd10.);
	label port_date = 'Previous Porfolio Date';
	format prv_port_date yymmdd10.;

	tot_investment = col4;
	label tot_investment = 'Total Invesment - NAV? Port value?';
	num_holdings = col5;
	
	eq_style_box = col6;
	*if col6 = -99 then eq_style_box = .;
	fi_style_box = col7;
	*if col7 = -99 then fi_style_box = .;
	
	pct_long_stock = col8;
	pct_long_bond = col9;
	pct_long_preferred = col10;
	pct_long_convertible = col11;
	pct_long_cash = col12;
	pct_long_other = col13;
	
	pct_net_stock = col14;
	pct_net_bond = col15;
	pct_net_preferred = col16;
	pct_net_convertible = col17;
	pct_net_cash = col18;
	pct_net_other = col19;
	
	pct_sector_1 = col20;
	pct_sector_2 = col21;
	pct_sector_3 = col22;
	pct_sector_4 = col23;
	pct_sector_5 = col24;
	pct_sector_6 = col25;
	pct_sector_7 = col26;
	pct_sector_8 = col27;
	pct_sector_9 = col28;
	pct_sector_10 = col29;
	pct_sector_11 = col30;
	pct_sector_12 = col31;
	
	
run;

proc contents data = morn.portfolio_statistics_only;
proc print data = morn.portfolio_statistics_only (obs = 100);
run;

* check unique key;
proc sort data = morn.portfolio_statistics_only out = tester nodupkey;
by fundid port_date;
run;
