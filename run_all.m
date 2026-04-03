clear;
close all;
clc;

run_simulations_cloud('json_files/simMRS_PRESS.json');
run_simulations_cloud('json_files/simMRS_sLASER.json');
run_simulations_cloud('json_files/simMRS_MEGA_sLASER.json');
run_simulations_cloud('json_files/simMRS_HERMES_sLASER.json');

close all;
