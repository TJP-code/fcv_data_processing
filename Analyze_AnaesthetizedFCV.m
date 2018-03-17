close all
clear all

%Directory containing all files
directory = 'E:\Marios aFCV\GLRA_002\';
%Pull out all folders within the directory, i.e. individual subjects 
folderlist = dir(directory);
folders = {folderlist.name};
isfolder = cell2mat({folderlist.isdir});
folders(~isfolder)=[];

%list of important subfolders containing session specific data
subfolder1 = '01_Stabilization\';
subfolder2 = '02_STIMRESPONSE_VARY_AMPLITUDE\';
subfolder3 = '03_STIMRESPONSE_VARY_PULSES\';
subfolder4 = '04_Stabilization_Period2\';
subfolder5 = '05_Baseline_PreDrug\';
subfolder6 = '06_DrugPeriod\';

subfolders = {subfolder1,subfolder2,subfolder3,subfolder4,subfolder5,subfolder6};

%Set file path
datapath = 'E:\Marios aFCV\GLRA_002\GLRA002_20170606_GLRA53.5f\06_DrugPeriod\';

%Set number of channels
no_of_channels = 1;

%% Process data

%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820;


%chemometric variables
chemo_params.cv_matrix = dlmread('C:\Users\mario\Documents\GitHub\fcv_data_processing\chemoset\cvmatrix1.txt');
chemo_params.conc_matrix = dlmread('C:\Users\mario\Documents\GitHub\fcv_data_processing\chemoset\concmatrix1.txt');
chemo_params.pcs = [];
chemo_params.alpha = 0.05;
chemo_params.plotfigs = 0;

%cutting variables
cut_params.sample_rate = 10;
cut_params.target_pos = 5; %time of stimulation
cut_params.bg_pos = -0.5; %seconds relative target
cut_params.trimData = [0 15]; %crop long files between a [start end] time in seconds


%visualisation params
params.trial_exclude_list = [];%[17,23, 57, 42];
params.plot_each =  1; %plot individual trials/cut timestamps
params.scan_number = 317;
params.plot_all_IvT = 0;
params.apply_chemometrics = 1; %do chemometrics
params.fig_title = 'Amplitude Response Curve';

%Read in separate files for analysis
[fileNames, TTLs, ch0_fcv_data, ~, ts] = read_separate_tarheel_files(datapath, no_of_channels);
%Background subtract data
processed_data = bg_subtract_aFCV(ch0_fcv_data, cut_params, bg_params);
[processed_data, ts] = trim_data_aFCV(processed_data, cut_params, ts);


%% Apply chemometrics


if params.apply_chemometrics
    %initialise variables
    model_cvs = [];
    c_predicted = [];
    residuals = [];
    
    %apply chemometrics
    [model_cvs, c_predicted, residuals.q, residuals.q_crit, residuals.q_cutoff] = ...
        fcv_chemometrics(processed_data, chemo_params, TTLs, ts);
end

%% Plot
h = plot_fcv_trials_Anaesthetized(model_cvs, ts, TTLs, params, c_predicted);
suptitle([params.fig_title]);


%calculate max value of DA i.e. DA peak
baseline = (cut_params.target_pos + cut_params.bg_pos)*cut_params.sample_rate;
% check for peak dopamine between baseline and max_end seconds later
% (important to avoid large values caused by post-stim drift
max_end = 10; 
max_end = max_end*cut_params.sample_rate;
DA_max = [];
DA_latency = [];
for i = 1: size(c_predicted, 2)
    [max_val, max_index] = max(c_predicted{i}(1,baseline:baseline+max_end),[], 2);
    
    DA_max(i) = max_val;
    DA_latency(i) = max_index; %N.b. this is latency from baseline in scan number
end





delimiter = '_'; %delimiter used between filename sections
remove = 1; % Boolean, True = remove the target text from the output, False = leave target text in output

for i = 1:length(fileNames)
    target = 'Hz'; %target text
    stimFreq(i) = str2double(filenameSplitter(fileNames{i},delimiter,target,remove));
    target = 'p'; %target text
    stimPulses(i) = str2double(filenameSplitter(fileNames{i},delimiter,target,remove));
    target = 'uA'; %target text
    stimStrength(i) = str2double(filenameSplitter(fileNames{i},delimiter,target,remove));
end


% %To Do: Save data
% %raw
% fileNames, TTLs, ch0_fcv_data, ~, ts
% %subtracted
% processed_data, ts
% %Chemometrics
% model_cvs, c_predicted, residuals.q, residuals.q_crit, residuals.q_cutoff
% %Summary
% DA_max
% DA_latency
% %Info
% stimFreq
% stimPulses
% stimStrength

%Save figures
%Add filename to figure suptitles for individuals, or use as filename for saving images

