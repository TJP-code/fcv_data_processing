close all
clear all
%Set file path
datapath = 'C:\Users\Marios\Desktop\GLRA002_20170927_GLRA65.2a\02_STIMRESPONSE_VARY_AMPLITUDE\';

%Set number of channels
no_of_channels = 1;

%% Process data

%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820;


%chemometric variables
chemo_params.cv_matrix = dlmread('C:\Users\Marios\Documents\GitHub\fcv_data_processing\chemoset\cvmatrix1.txt');
chemo_params.conc_matrix = dlmread('C:\Users\Marios\Documents\GitHub\fcv_data_processing\chemoset\concmatrix1.txt');
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
params.plot_each =  0; %plot individual trials/cut timestamps
params.scan_number = 317;
params.plot_all_IvT = 0;
params.apply_chemometrics = 1; %do chemometrics
params.fig_title = 'Amplitude Response Curve';

%Read in separate files for analysis
[fileNames, TTLs, ch0_fcv_data, ~, ts] = read_separate_tarheel_files(datapath, no_of_channels);
%Background subtract data
processed_data = bg_subtract_aFCV(ch0_fcv_data, cut_params, bg_params);
processed_data = trim_data_aFCV(processed_data, cut_params);

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
DA_max = [];
DA_latency = [];
for i = 1: size(c_predicted, 2)
[max_val, max_index] = max(c_predicted{i}(1,baseline:end),[], 2);

DA_max(i) = max_val;
DA_latency(i) = max_index; %N.b. this is latency from baseline in scan number
end


figure
scatter([1:length(DA_max)], DA_max)
figure
scatter([1:length(DA_latency)], DA_latency)


delimiter = '_'; %delimiter used between filename sections
remove = 1; % Boolean, True = remove the target text from the output, False = leave target text in output

for i = 1:length(fileNames)
target = 'Hz'; %target text
stimFreq(i) = str2double(filenameSplitter(fileNames{i},delimiter,target,remove));
target = 'p'; %target text
stimPulses{i} = filenameSplitter(fileNames{i},delimiter,target,remove);
target = 'uA'; %target text
stimStrength{i} = filenameSplitter(fileNames{i},delimiter,target,remove);
end


