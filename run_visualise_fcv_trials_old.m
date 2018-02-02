clear
close all

%parameters
datapath = '..\fcv_data_processing\test data\46_20170208_02 - Variable reward post\';
datapath = 'I:\GLRA_FCV\Feratu_Coach\20171220_RI60Day1\RI60Day1\';
datapath = 'C:\Data\GluA1 FCV\GluA1 Data\003\Gazorpazorp\20180118_RI60Day3\RI60Day3\';
datapath = 'C:\Data\GluA1 FCV\GluA1 Data\003\Gazorpazorp\20180118_RI60Day3\RI60Day3\';
fig_title = 'zorp RI60 Day 3 Rewarded lever press';

trial_exclude_list = [];%[17,23, 57, 42];
plot_each =  0; %plot individual trials/cut timestamps
scan_number = 150;
plot_all_IvT = 1;
apply_chemometrics = 1;

%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 

no_of_channels = 2;

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
TTLnames = {'Reward', 'Head Entry', 'Head Exit', 'Left Lever Press', 'Left Lever Out', 'Right Lever Press', 'Right Lever Out', 'Fan', '', '', '', '', '', '', '', ''};


[cut_points_ch0,cut_points_ch1] = visualise_fcv_trials_2ch(datapath, trial_exclude_list, no_of_channels, cut_params, bg_params, chemo_params, ...
     apply_chemometrics, scan_number, TTLnames, plot_each, plot_all_IvT, fig_title);
 
 %OR
 
 [TTLs, ch0_fcv_data, ch1_fcv_data, ts] = read_whole_tarheel_session(datapath, no_of_channels);