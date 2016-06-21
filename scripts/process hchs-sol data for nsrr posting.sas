
*processing hchs-sol biolincc data for nsrr posting;

*set library to location that houses SOL BioLINCC SAS datasets;
libname solb "\\rfa01\bwh-sleepepi-sol\nsrr-prep\_datasets";
options nofmterr;


/*

*explore proc contents of derived dataset file;
proc contents data=solb.part_derv_lad1 out=part_derv_contents;
run;

proc export data=part_derv_contents
  outfile="\\rfa01\bwh-sleepepi-sol\nsrr-prep\_documentation\part_derv_contents.csv"
  dbms=csv
  replace;
run;

*explore proc contents of slea dataset file;
proc contents data=solb.slea_lad1 out=slea_contents;
run;

proc export data=slea_contents
  outfile="\\rfa01\bwh-sleepepi-sol\nsrr-prep\_documentation\slea_contents.csv"
  dbms=csv
  replace;
run;

*/

*set release number;
%let release = 0.2.0.pre;

*import SAS dataset;
data part_derv_lad1_in;
  length PID $8 vnum 8.;
  set solb.part_derv_lad1;

  *set visit number to 1 for hchs/sol baseline visit;
  vnum = 1;
run;

*export datasets to CSV for posting;
proc export data=part_derv_lad1_in
  outfile="\\rfa01\bwh-sleepepi-sol\nsrr-prep\_releases\&release\hchs-sol-dataset-&release..csv"
  dbms=csv
  replace;
run;
