
*processing hchs-sol biolincc data for nsrr posting;

*set library to location that houses SOL BioLINCC SAS datasets;
libname solb "\\rfawin\bwh-sleepepi-sol\nsrr-prep\_datasets";
options nofmterr;


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

*set release number;
%let release = 0.3.0.rc2;

*import sas datasets;
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

data part_derv_sueno_lad1_in;
  set solb.part_derv_sueno_lad1;

run;

data sawa_lad1_in;
  set solb.sawa_lad1;

run;

*merge sub-datasets;
data hchs_sol_dataset;
  merge part_derv_lad1_in
    slea_lad1_in
    slpa_lad1_in
    part_derv_sueno_lad1_in
    sawa_lad1_in;
  by pid;

  drop skips_on vers visit linenumber form fseqno;
run;

*export datasets to CSV for posting;
proc export data=hchs_sol_dataset
  outfile="\\rfawin\bwh-sleepepi-sol\nsrr-prep\_releases\&release\hchs-sol-dataset-&release..csv"
  dbms=csv
  replace;
run;
