*Midterm Program;
 
****Reading data;
PROC IMPORT OUT = data_china_orig3
	DATAFILE = "C:\Users\USER\Downloads\data_china.xls" 
	DBMS = EXCEL REPLACE;
run;

 ***********************************************;
 ***先製造自己的資料(以2015年為例);
 data mydata;
	set data_china_orig3;
	*if year = '2015    ' and  Ind = 'C ';
	if year = '2015    ';
run;

*判斷變數的格式型態;
proc contents data = mydata;
run;

data mydata;
	set mydata;
	drop F23-F28;
	*把文字型態變數轉成數值型變數;
	year2 = year + 0;
	*year2 = input (year, 8.) ;
	drop year;
	rename year2 = year;
run;


***創造一個新的虛擬變數(高資產周轉率)加入迴歸中，所以需要先找出資產周轉率中位數;
***結果本群組資產周轉率中位數為0.4801240 ;
proc means data = mydata median;
	var TA_turnover; 
run;

***創造一個新的虛擬變數(高資產周轉率)，以本群組資產周轉率中位數分割;
***在創造此新虛擬變數與原來回歸式中其他2變數之交乘項(highTAT_PM,highTAT_EM) ;
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


/*主成分分析*/
/*資產管理效率(主成分1,prin1,第一軸)*/
proc princomp data = mydata2 out = prin_assetm
	outstat = prin_weight_assetm;
		var AR_turnover FA_turnover Inv_turnover NWC_turnover TA_turnover;
run;

data prin_assetm2;
	set prin_assetm;
	rename prin1 = prin1_assetm prin2 = prin2_assetm prin3 = prin3_asstem;
		drop prin4 prin5;
run;

/*主成分分析*/
/*短期流動性(主成分2,prin2,第二軸)*/
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

/*跑迴歸*/
proc reg data = corp_pca;
	model roe = prin1_assetm prin1_liq;
run;

/*因素分析*/
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

/*用factor loading 裡的 factor 1 2 3 跑回歸  */
