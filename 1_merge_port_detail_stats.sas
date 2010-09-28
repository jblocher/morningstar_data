/* *************************************************************************/
/* CREATED BY:      Jesse Blocher (UNC-Chapel Hill)                                               
/* MODIFIED BY:                                                    
/* DATE CREATED:    Aug 2010                                                                                                            
/* PROG NAME:       merge_port_detail_stats.sas                                                              
/* Project:         Create Morningstar Open Ended US fund DB
/* This File:       Merge morningstar portfolio detail data with portfolio statistics
/************************************************************************************/
 
%include 'morn_merge_header.sas'; *header file with basic options and libraries;


/* Datasets required to run:
 * morn.portfolio_type_codes_renamed		: Excel Sheet converted to SAS via Stat Transfer
 * morn.sector_codes						: Twelve Sector Codes manually input into dataset
 * morn.porthold_main_clean_fixed			: Text Files convered via Stat Transfer, merged, cleaned
 * morn.portfolio_statistics_only			: Fund level stats, unique by fundid, portfolio date
 */
 
/* Datasets Produced:
 * morn.master_morn_holdings				: Master Dataset with all holdings and fund stats
 */
 ** Main Data **;
/*
proc sql;
	create table portfolio_holdings_merged1 as
	select a.*, b.sector_name
	from morn.porthold_main_clean_fixed as a
	left join 
	morn.sector_codes as b
	on a.sector_code = b.sector_code;
	
	create table morn.portfolio_holdings_merged as
	select a.*, b.type_name
	from portfolio_holdings_merged1 as a
	left join 
	morn.portfolio_type_codes_renamed as b
	on a.type_cd = b.type_cd;
	
	create table morn.master_morn_holdings as
	select a.*, b.*
	from morn.portfolio_holdings_merged as a
	left join
	morn.portfolio_statistics_only as b
	on a.fundid = b.fundid and a.port_date = b.port_date
	order by port_date, fundid;
quit;
*/
proc contents data = morn.master_morn_holdings;
/*
proc print data = morn.master_morn_holdings (obs = 100);
run;

** Check Duplicates;
proc sort data = morn.master_morn_holdings out = tester nodupkey;
where ~missing(cusip);
by port_date fundid cusip;
run;
* maybe description is missing;
proc sort data = morn.master_morn_holdings out = tester1 nodupkey;
where ~missing(security);
by port_date fundid security;
run;
* maybe description is missing;
proc sort data = morn.master_morn_holdings out = tester2 nodupkey;
where ~missing(marketvalue);
by port_date fundid marketvalue;
run;

/*
proc freq data = sorted_morn_holds noprint ; 
by port_date ;
table fundid / out = holdings_DUPS (keep = port_date fundid weight marketvalue cusip Count where = (Count > 1)) ;
run ;

/*
**********
This worked. I now have a unique identifier - don't run this again
**********
*rowid is a unique identifier since we do not have one at the holdings level necessarily;
data morn.master_morn_holdings;
	set morn.master_morn_holdings;
	rowid = _N_;
run;
proc sort data = morn.master_morn_holdings out = tester nodupkey;
by port_date fundid rowid;
run;
*/




**** Now, lets get some stats on it ***;

proc sql;
	create table morn_port_stats_sum as
	select 	port_date, fundid,
			sum(weight) as sum_port_weight, 
			sum(marketvalue) as sum_mkt_val,
			count(type_cd) as num_holdings_calc
	from morn.porthold_main_clean_fixed
	group by port_date, fundid;

	create table ms_work.morn_port_stats as
	select 	a.port_date, a.fundid, year(a.port_date) as port_year, b.sum_port_weight,
			a.tot_investment, b.sum_mkt_val,
			a.num_holdings, b.num_holdings_calc,
			a.pct_long_bond, a.pct_long_cash, a.pct_long_convertible, a.pct_long_other, a.pct_long_preferred, a.pct_long_stock, 
			a.pct_net_bond, a.pct_net_cash, a.pct_net_convertible, a.pct_net_other, a.pct_net_preferred, a.pct_net_stock
	from morn.portfolio_statistics_only as a, morn_port_stats_sum as b
	where a.port_date = b.port_date and a.fundid = b.fundid;
quit;

data test_morn_stats;
	set ms_work.morn_port_stats;
	** all of these should be zero;
	mkt_val_diff = sum_mkt_val - tot_investment;
	weight_diff = sum_port_weight - 100;
	num_hold_diff = num_holdings_calc - num_holdings;
	
	pct_long_diff = pct_long_bond+ pct_long_cash+ pct_long_convertible+ pct_long_other+ pct_long_preferred+ pct_long_stock - 100;
	pct_net_diff = pct_net_bond+ pct_net_cash+ pct_net_convertible+ pct_net_other+ pct_net_preferred+ pct_net_stock - 100;
run;

proc univariate data = test_morn_stats;
var mkt_val_diff weight_diff num_hold_diff pct_long_diff pct_net_diff;
run;