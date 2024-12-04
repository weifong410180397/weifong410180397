*Midterm Program;
 
****Reading data;
PROC IMPORT OUT = data_china_orig3
	DATAFILE = "C:\Users\USER\Downloads\data_china.xls" 
	DBMS = EXCEL REPLACE;
run;

 ***********************************************;
 ***���s�y�ۤv�����(�H2015�~����);
 data mydata;
	set data_china_orig3;
	*if year = '2015    ' and  Ind = 'C ';
	if year = '2015    ';
run;

*�P�_�ܼƪ��榡���A;
proc contents data = mydata;
run;

data mydata;
	set mydata;
	drop F23-F28;
	*���r���A�ܼ��ন�ƭȫ��ܼ�;
	year2 = year + 0;
	*year2 = input (year, 8.) ;
	drop year;
	rename year2 = year;
run;


***�гy�@�ӷs�������ܼ�(���겣�P��v)�[�J�j�k���A�ҥH�ݭn����X�겣�P��v�����;
***���G���s�ո겣�P��v����Ƭ�0.4801240 ;
proc means data = mydata median;
	var TA_turnover; 
run;

***�гy�@�ӷs�������ܼ�(���겣�P��v)�A�H���s�ո겣�P��v����Ƥ���;
***�b�гy���s�����ܼƻP��Ӧ^�k������L2�ܼƤ��歼��(highTAT_PM,highTAT_EM) ;
DATA mydata2 ;
	set mydata;
		if TA_turnover > 0.4801240 then high_TAturn=1; 
		else high_TAturn = 0;

		if TA_turnover = . then delete;

		*else if high_TAturn >= 0 and TA_turnover <= 0.5146320 then high_TAturn = 0; 
		*else high_TAturn = .; 

	highTAT_PM = high_TAturn * Profit_Margin;
	*highTAT_EM = high_TAturn * Equity_Multiple;
run;


/*�D�������R*/
/*�겣�޲z�Ĳv(�D����1,prin1,�Ĥ@�b)*/
proc princomp data = mydata2 out = prin_assetm
	outstat = prin_weight_assetm;
		var AR_turnover FA_turnover Inv_turnover NWC_turnover TA_turnover;
run;

data prin_assetm2;
	set prin_assetm;
	rename prin1 = prin1_assetm prin2 = prin2_assetm prin3 = prin3_asstem;
		drop prin4 prin5;
run;

/*�D�������R*/
/*�u���y�ʩ�(�D����2,prin2,�ĤG�b)*/
proc princomp data = mydata2 out = prin_liq
	outstat = prin_weight_liq;
		var Current_Ratio Quick_Ratio Cash_Ratio NWC_Debt;
run;

data prin_liq2;
	set prin_liq;
	keep stkcd prin1;
		rename prin1 = prin1_liq stkcd = stkcd2;
run;

proc sql;
create table corp_pca
as select e.*, s.*
from prin_assetm2 as e
left join prin_liq2 as s
on e.stkcd=s.stkcd2;
quit;

/*�]�j�k*/
proc reg data = corp_pca;
	model roe = prin1_assetm prin1_liq;
run;

/*�]�����R*/
proc factor data = mydata2 rotate = varimax ;
	var AR_turnover FA_turnover Inv_turnover NWC_turnover TA_turnover 
		Current_Ratio Quick_Ratio Cash_Ratio NWC_Debt;
run;

proc factor data = mydata2 ;
	var AR_turnover  Inv_turnover NWC_turnover TA_turnover 
		Current_Ratio Quick_Ratio Cash_Ratio ;
run;

proc factor data = mydata2 rotate = varimax;
	var AR_turnover  Inv_turnover NWC_turnover TA_turnover 
		Current_Ratio Quick_Ratio Cash_Ratio ;
run;

proc factor data = mydata2 rotate = varimax n=3;
var AR_turnover  Inv_turnover NWC_turnover TA_turnover 
		Current_Ratio Quick_Ratio Cash_Ratio ;
run;

proc factor data = mydata2 rotate = varimax n=3 out = factorloading;
var AR_turnover  Inv_turnover NWC_turnover TA_turnover 
		Current_Ratio Quick_Ratio Cash_Ratio ;
run;

/*��factor loading �̪� factor 1 2 3 �]�^�k  */
