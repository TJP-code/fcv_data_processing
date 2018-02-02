clear
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% params for common functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 

%chemometric variables
chemo_params.cv_matrix = dlmread('..\fcv_data_processing\chemoset\cvmatrix2.txt');
chemo_params.conc_matrix = dlmread('..\fcv_data_processing\chemoset\concmatrix2.txt');
chemo_params.pcs = [];
chemo_params.alpha = 0.05;
chemo_params.plotfigs = 0;

%cutting variables
cut_params.include.bits = []; %include target_bit
cut_params.include.buffer = []; %time(s) before target,time after target
cut_params.exclude.bits = [];
cut_params.exclude.buffer = [];
cut_params.target_bit = 1;
cut_params.target_location = 0; %0 = start, 1 = end, 0.5 = middle
cut_params.ignore_repeats = []; %no of seconds to ignore repeats
cut_params.sample_rate = 10;
cut_params.time_align = [10 30]; %window size, [seconds before after]
cut_params.bg_pos = -2; %seconds relative to target_location

bg_adjustments = [5 -.5]; %not implemented yet

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Params for visualise function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%visualisation params
fcv_data.TTLnames = {'Reward', 'Head Entry', 'Head Exit', 'Left Lever Press', 'Left Lever Out', 'Right Lever Press', 'Right Lever Out', 'Fan', '', '', '', '', '', '', '', ''};
params.trial_exclude_list = [];%[17,23, 57, 42];
params.plot_each =  0; %plot individual trials/cut timestamps
params.scan_number = 150;
params.plot_all_IvT = 0;
params.apply_chemometrics = 1; %do chemometrics

%read in tarheel session
datapath = 'C:\Data\GluA1 FCV\GluA1 Data\003\Gazorpazorp\20180118_RI60Day3\RI60Day3\';
no_of_channels = 2;
[fcv_data.TTLs,  ch0_fcv_data, ch1_fcv_data,  fcv_data.ts] = read_whole_tarheel_session(datapath, no_of_channels);

fcv_data.data = ch0_fcv_data;
params.fig_title = 'zorp RI60 Day 3 Rewarded lever press ch0';

%cut, chemometrics and plot data ch0
[processed_data_ch0, cut_points_ch0, model_cvs_ch0, c_predicted_ch0, residuals_ch0] = ...
    visualise_fcv_trials(fcv_data, params, cut_params, bg_params, chemo_params);

%cut, chemometrics and plot data ch1
fcv_data.data = ch1_fcv_data;
params.fig_title = 'zorp RI60 Day 3 Rewarded lever press ch1';
[processed_data_ch1, cut_points_ch1, model_cvs_ch1, c_predicted_ch1, residuals_ch1] = ...
    visualise_fcv_trials(fcv_data, params, cut_params, bg_params, chemo_params);
