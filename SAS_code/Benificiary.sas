proc import datafile="/home/u64515276/myfolder/Beneficary_data.xlsx"
    out=beneficiary
    dbms=xlsx
    replace;
    getnames=yes;
run;
proc contents data=beneficiary;
run;

proc print data=beneficiary(obs=10);
run;

proc means data=beneficiary
n
mean
median
min
max;
var amount package_booked_rate final_approved_claim_amt;
run;

proc print data=beneficiary(obs=10);
run;

proc freq data=beneficiary;
tables

status_in_log
hospital_type
hospital_category
identity_status
package_type
beneficiary_district
discharge_status
policy_year;
run;

proc print data=beneficiary(obs=10);
run;

DATA beneficiary;
SET beneficiary;

IF MISSING(PACKAGE_UNIQUE_NAME) THEN PACKAGE_UNIQUE_NAME="-";
IF MISSING(PACKAGE_UNIQUE_CODE) THEN PACKAGE_UNIQUE_CODE="-";
IF MISSING(SPECIALITY_UNIQUE_NAME) THEN SPECIALITY_UNIQUE_NAME="-";
 
/*     Extract number part */
    ID_PART = compress(substr(UNIQUEMEMBER,1,10),,'kd');

/*     Extract name part */
    NAME_PART = substr(UNIQUEMEMBER,11);

/*     Proper case the name */
    NAME_PART = propcase(strip(NAME_PART));

/*     Combine back */
    UNIQUEMEMBER = cats(ID_PART, NAME_PART);

    drop ID_PART NAME_PART;
    
IF MISSING(REJECTION_REASON) THEN REJECTION_REASON="NA";

UNIQUEMEMBER=STRIP(SUBSTR(UNIQUEMEMBER,11));
RUN;

proc print data=benficiary(obs=100);
run;

data beneficiary_analysis;
    set beneficiary;

    claim_difference = AMOUNT - FINAL_APPROVED_CLAIM_AMT;
run;

proc print data=beneficiary_analysis(obs=10);
run;

data analysis_data;
    set beneficiary;

    if amount>0 then
        approval_percentage =
        (final_approved_claim_amt/amount)*100;

run;
proc print data=analysis_data(obs=10);
run;

data analysis_data;
    set beneficiary;

    delay_days =
    last_action_date -
    submission_date;
    
month = month(TID_CREATED_DATE);

run;

/* KPIs */

proc sql;
select count(*) as Total_Claims
from analysis_data;
quit;

proc sql;
select sum(AMOUNT) as TOTAL_CLAIM_AMOUNT format=comma15.
from analysis_data;
quit;

proc sql;
select sum(FINAL_APPROVED_CLAIM_AMT) as TOTAL_APPROVED_AMOUNT format=comma15.
from analysis_data;
quit;

proc means data=analysis_data mean;
var AMOUNT;
run;

proc means data=analysis_data mean;
var FINAL_APPROVED_CLAIM_AMT;
run;

proc means data=analysis_data mean;
var approval_percentage;
run;

proc means data=analysis_data mean;
var delay_days;
run;

proc sql;
select HOSPITAL_NAME,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by HOSPITAL_NAME
order by Total_Claim desc;
quit;

proc freq data=analysis_data order=freq;
tables HOSPITAL_NAME;
run;

proc sql;
select BENEFICIARY_DISTRICT,
       count(*) as Claims,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by BENEFICIARY_DISTRICT
order by Total_Claim desc;
quit;

proc freq data=analysis_data order=freq;
tables PACKAGE_SPECIALITY_NAME;
run;

proc sql;
select PACKAGE_SPECIALITY_NAME,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by PACKAGE_SPECIALITY_NAME
order by Total_Claim desc;
quit;

proc sql;
select PACKAGE_SPECIALITY_NAME,
       count(*) as Claims,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by PACKAGE_SPECIALITY_NAME
order by Total_Claim desc;
quit;

proc sql;
select POLICY_YEAR,
       count(*) as Claims,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by POLICY_YEAR;
quit;

proc sql;
select month,
       count(*) as Claims,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by month
order by month;
quit;

proc sql;
select HOSPITAL_TYPE,
       count(*) as Claims,
       sum(AMOUNT) as Total_Claim
from analysis_data
group by HOSPITAL_TYPE;
quit;

proc freq data=analysis_data;
tables REJECTION_REASON;
run;

proc freq data=analysis_data;
tables IDENTITY_STATUS;
run;

proc freq data=analysis_data;
tables DISCHARGE_STATUS;
run;

proc sql;
select TPA,
       count(*) as Claims,
       sum(FINAL_APPROVED_CLAIM_AMT) as Approved
from analysis_data
group by TPA
order by Approved desc;
quit;

/* KPIs Done */