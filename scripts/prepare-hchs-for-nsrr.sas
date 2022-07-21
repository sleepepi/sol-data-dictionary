*******************************************************************************;
* Program           : prepare-hchs-for-nsrr.sas
* Project           : National Sleep Research Resource (sleepdata.org)
* Author            : Michael Rueschman (MR)
* Date Created      : 20190107
* Purpose           : Prepare Hispanic Community Health Study (HCHS) data for
*                       deposition on sleepdata.org.
* Revision History  :
*   Date      Author    Revision
*
*******************************************************************************;

*******************************************************************************;
* set options and libnames ;
*******************************************************************************;
  libname solb "\\rfawin\BWH-SLEEPEPI-SOL\nsrr-prep\_datasets";
  options nofmterr;

  %let release = 0.7.0.pre;


/*
*explore proc contents of derived dataset file;
proc contents data=solb.part_derv_lad1 out=part_derv_contents;
run;

proc export data=part_derv_contents
  outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_documentation\part_derv_contents.csv"
  dbms=csv
  replace;
run;

*explore proc contents of slea dataset file;
proc contents data=solb.slea_lad1 out=slea_contents;
run;

proc export data=slea_contents
  outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_documentation\slea_contents.csv"
  dbms=csv
  replace;
run;

*explore proc contents of slpa dataset file;
proc contents data=solb.slpa_lad1 out=slpa_contents;
run;

proc export data=slpa_contents
  outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_documentation\slpa_contents.csv"
  dbms=csv
  replace;
run;

  */

*******************************************************************************;
* pull in source data ;
*******************************************************************************;
  data part_derv_lad1_in;
    length pid $8 vnum 8.;
    set solb.part_derv_lad1;

    *set visit number to 1 for hchs/sol baseline visit;
    vnum = 1;

    *drop extraneous variables;
    drop
      /* drop 'permit' variables, overridden by HCHS-created 'any_permit' indicator */
      np_permit
      external_permit
      commercial_permit
      ;
  run;

  data slea_lad1_in;
    length pid $8;
    set solb.slea_lad1;

    *rename form for this dataset;
    rename form = slea_form;

    *drop extraneous variables;
    drop fseqno linenumber vers visit slea1a slea1c slea2a slea2c ;
  run;

  data slpa_lad1_in;
    length pid $8;
    set solb.slpa_lad1;

    *drop extraneous variables;
    drop fseqno linenumber vers visit form slpa2 
  SLPA72 SLPA73 SLPA74 SLPA75 SLPA76 SLPA77 SLPA78 SLPA79
    SLPA80 SLPA81 SLPA82 SLPA83 SLPA84 SLPA85 SLPA86 SLPA87
    SLPA88 SLPA89; /* drop apnea, central apnea only events*/
  run;

  data mhea_lad1_in;
    length pid $8;
    set solb.mhea_lad1;

    *recode .q/.s values to missing;
    array allvars mhea1--mhea39;
    do over allvars;
      if allvars in (.q,.s) then allvars = .;
    end;

    *drop extraneous variables;
    drop fseqno linenumber vers visit form linenumber ;
  run;

data sbpa_lad1_in;
length pid $8;
set solb.sbpa_lad1;


*only keep average bp measures;
keep pid sbpa5 sbpa6;
run;

  data part_derv_sueno_lad1_in;
    set solb.part_derv_sueno_lad1;

    *drop extraneous variables;
    drop
      /* drop 'permit' variables, overridden by HCHS-created 'any_permit' indicator */
      np_permit
      external_permit
      commercial_permit
      ;
  run;

  data sawa_lad1_in;
    set solb.sawa_lad1;

  run;

  data spea_lad1_in;
    set solb.spea_lad1;

    *drop variables not kept in hchs documentation;
    drop SPEA1A SPEA1A1 SPEA1B SPEA1B1 SPEA2A
      SPEA2A1 SPEA2B SPEA2B1 
    ;
  run;

  data sqea_lad1_in;
    set solb.sqea_lad1;

  run;

  *merge sub-datasets;
  data hchs_sol_dataset;
    merge
      part_derv_lad1_in
      slea_lad1_in
      slpa_lad1_in
      mhea_lad1_in
    sbpa_lad1_in
      ;
    by pid;

  run;

  *merge sub-datasets;
  data hchs_sueno_dataset;
    merge
      part_derv_sueno_lad1_in
      sawa_lad1_in
      spea_lad1_in
      sqea_lad1_in;
    by pid;

    vnum = 2;

    drop skips_on vers visit linenumber form fseqno;
  run;

*******************************************************************************;
* create harmonized datasets ;
*******************************************************************************;
data hchs_sol_harmonized;
  set hchs_sol_dataset;
  *vnum exists;

*demographics
*age;
*use age;
  format nsrr_age 8.2;
  if age gt 89 then nsrr_age = 90;
  else if age le 89 then nsrr_age = age;

*age_gt89;
*use age;
  format nsrr_age_gt89; 
  if age gt 89 then nsrr_age_gt89= 'yes';
  else if age le 89 then nsrr_age_gt89='no';

*sex;
*use gendernum;
  format nsrr_sex $100.;
  if gendernum = 01 then nsrr_sex = 'male';
  else if gendernum = 0 then nsrr_sex = 'female';
  else if gendernum = . then nsrr_sex = 'not reported';

*race;
*use race;
    format nsrr_race $100.;
    if race = 01 then nsrr_race = 'american indian or alaska native';
    else if race = 02 then nsrr_race = 'asian';
    else if race = 03 then nsrr_race = 'native hawaiian or other pacific islander';
    else if race = 04 then nsrr_race = 'black or african american';
    else if race = 05 then nsrr_race = 'white';
    else if race = 06 then nsrr_race = 'multiple';
  else if race = 07 then nsrr_race = 'unknown';
  else nsrr_race = 'not reported';

*ethnicity;
*set all value to 'hispanic or latino';
  format nsrr_ethnicity $100.;
    if pid ne '.' then nsrr_ethnicity = 'hispanic or latino';
  else if pid = '.' then nsrr_ethnicity = 'not reported';

*hispanic subgroup;
*use BKGRD1_C7;
  format nsrr_hispanic_subgroup $100.;
  if BKGRD1_C7= '0' then nsrr_hispanic_subgroup = 'dominican';
  else if BKGRD1_C7= '01' then nsrr_hispanic_subgroup = 'centralamerican';
  else if BKGRD1_C7= '02' then nsrr_hispanic_subgroup = 'cuban';
  else if BKGRD1_C7= '03' then nsrr_hispanic_subgroup = 'mexican';
  else if BKGRD1_C7= '04' then nsrr_hispanic_subgroup = 'puertorican';
  else if BKGRD1_C7= '05' then nsrr_hispanic_subgroup = 'southamerican';
  else if BKGRD1_C7= '06' then nsrr_hispanic_subgroup = 'multiple';
  else if BKGRD1_C7= 'Q' then nsrr_hispanic_subgroup = 'unknown';
  else nsrr_hispanic_subgroup = 'not reported';

*anthropometry
*bmi;
*use bmi;
  format nsrr_bmi 10.9;
  nsrr_bmi = bmi;

*clinical data/vital sign;
*bp_systolic;
*use sbpa5;
  format nsrr_bp_systolic 8.2;
  nsrr_bp_systolic = sbpa5;

*bp_diastolic;
*use sbpa6;
  format nsrr_bp_diastolic 8.2;
  nsrr_bp_diastolic = sbpa6;
  

*lifestyle and behavioral health
*current_smoker;
*use current_smoker;
  format nsrr_current_smoker $100.;
  if current_smoker = 0 then nsrr_current_smoker = 'no';
  else if current_smoker = 01 then nsrr_current_smoker = 'yes';
    else if current_smoker = . then nsrr_current_smoker = 'not reported';

*ever_smoker;
*use CIGARETTE_USE;
  format nsrr_ever_smoker $100.;
  if CIGARETTE_USE = 01 then nsrr_ever_smoker = 'no';
  else if CIGARETTE_USE = 02 then nsrr_ever_smoker = 'yes';
  else if CIGARETTE_USE = 03 then nsrr_ever_smoker = 'yes';
    else if CIGARETTE_USE = . then nsrr_ever_smoker = 'not reported';

*ever_smoker;
*not using;

*polysomnography;
*nsrr_ahi_ap3u;
*use slpa54;
  format nsrr_ahi_ap3u 8.2;
  nsrr_ahi_ap3u = slpa54;
  
*nsrr_ahi_ap4u;
*use slpa63;
  format nsrr_ahi_ap4u 8.2;
  nsrr_ahi_ap4u = slpa63;
  
  keep 
    pid
    vnum
    nsrr_age
    nsrr_age_gt89
    nsrr_sex
    nsrr_race
    nsrr_ethnicity
    nsrr_hispanic_subgroup
    nsrr_bmi
    nsrr_bp_systolic
    nsrr_bp_diastolic
    nsrr_current_smoker
    nsrr_ever_smoker
    nsrr_ahi_ap3u
    nsrr_ahi_ap4u
  ;
run;

*******************************************************************************;
* checking harmonized datasets ;
*******************************************************************************;
/* Checking for extreme values for continuous variables */

proc means data=hchs_sol_harmonized;
VAR   nsrr_age
    nsrr_bmi
  nsrr_bp_systolic
  nsrr_bp_diastolic
  nsrr_ahi_ap3u
  nsrr_ahi_ap4u
    ;
run;

/* Checking categorical variables */

proc freq data=hchs_sol_harmonized;
table   nsrr_age_gt89
    nsrr_sex
    nsrr_race
    nsrr_ethnicity
    nsrr_hispanic_subgroup
    nsrr_current_smoker
    nsrr_ever_smoker;
run;

*******************************************************************************;
* make all variable names lowercase ;
*******************************************************************************;
  options mprint;
  %macro lowcase(dsn);
       %let dsid=%sysfunc(open(&dsn));
       %let num=%sysfunc(attrn(&dsid,nvars));
       %put &num;
       data &dsn;
             set &dsn(rename=(
          %do i = 1 %to &num;
          %let var&i=%sysfunc(varname(&dsid,&i));    /*function of varname returns the name of a SAS data set variable*/
          &&var&i=%sysfunc(lowcase(&&var&i))         /*rename all variables*/
          %end;));
          %let close=%sysfunc(close(&dsid));
    run;
  %mend lowcase;

  %lowcase(hchs_sol_dataset);
  %lowcase(hchs_sueno_dataset);
  %lowcase(hchs_sol_harmonized);


*******************************************************************************;
* export csv datasets ;
*******************************************************************************;
  proc export data=hchs_sol_dataset
    outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_releases\&release\hchs-sol-baseline-dataset-&release..csv"
    dbms=csv
    replace;
  run;

  proc export data=hchs_sueno_dataset
    outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_releases\&release\hchs-sol-sueno-ancillary-dataset-&release..csv"
    dbms=csv
    replace;
  run;

  proc export data=hchs_sol_harmonized
    outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_releases\&release\hchs-sol-baseline-harmonized-dataset-&release..csv"
    dbms=csv
    replace;
  run;
