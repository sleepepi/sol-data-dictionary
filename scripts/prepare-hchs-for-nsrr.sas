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
  libname solb "\\rfawin\bwh-sleepepi-sol\nsrr-prep\_datasets";
  options nofmterr;

  %let release = 0.4.0.pre;

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
  run;

  data slea_lad1_in;
    length pid $8;
    set solb.slea_lad1;

    *rename form for this dataset;
    rename form = slea_form;

    *drop extraneous variables;
    drop fseqno linenumber vers visit ;
  run;

  data slpa_lad1_in;
    length pid $8;
    set solb.slpa_lad1;

    *drop extraneous variables;
    drop fseqno linenumber vers visit form slpa2 ;
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

  data part_derv_sueno_lad1_in;
    set solb.part_derv_sueno_lad1;

  run;

  data sawa_lad1_in;
    set solb.sawa_lad1;

  run;

  *merge sub-datasets;
  data hchs_sol_dataset;
    merge 
      part_derv_lad1_in
      slea_lad1_in
      slpa_lad1_in
      mhea_lad1_in;
    by pid;

  run;

  *merge sub-datasets;
  data hchs_sueno_dataset;
    merge 
      part_derv_sueno_lad1_in
      sawa_lad1_in;
    by pid;

    vnum = 2;

    drop skips_on vers visit linenumber form fseqno;
  run;

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
