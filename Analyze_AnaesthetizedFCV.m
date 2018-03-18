close all
clear all
%% Parameters
%Move these inside data processing loop if you want to setup individual parameters for each animal/session

%Set number of channels
no_of_channels = 1;

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
params.plot_each =  1; %plot individual trials/cut timestamps
params.scan_number = 317;
params.plot_all_IvT = 0;
params.apply_chemometrics = 1; %do chemometrics
params.fig_title = 'Amplitude Response Curve';

%% Set up data path and subfolder structure

%Directory containing all files
directory = 'D:\Marios aFCV\GLRA_002\';
%Pull out all folders within the directory, i.e. individual subjects
folderlist = dir(directory);
folders = {folderlist.name};
isfolder = cell2mat({folderlist.isdir});
folders(~isfolder)=[];

%find list of relevant folders starting with GLRA002 and update folders variable
relevantFolders  = strfind([folders], 'GLRA002');
folders = folders(~cellfun(@isempty, relevantFolders));

%list of important subfolders containing session specific data
subfolder1 = '\01_Stabilization\';
subfolder2 = '\02_STIMRESPONSE_VARY_AMPLITUDE\';
subfolder3 = '\03_STIMRESPONSE_VARY_PULSES\';
subfolder4 = '\04_Stabilization_Period2\';
subfolder5 = '\05_Baseline_PreDrug\';
subfolder6 = '\06_DrugPeriod\';
subfolders = {subfolder2};
% subfolders = {subfolder1,subfolder2,subfolder3,subfolder4,subfolder5,subfolder6};


%% Main Loop
%loop through each folder (subject) and each subfolder (protocol)
for i= 1:length(folders)
    %Extract subject and sessiond details from folder name
    sessionDetails = strsplit(folders{i}, '_');
    experiment{i} = sessionDetails{1};
    date{i} = sessionDetails{2};
    subject{i} = sessionDetails{3};
    
    for j = 1:length(subfolders)
        datapath = [directory folders{i} subfolders{j}];
        
        %% Process data
        
        %Read in separate files for analysis
        [fileNames, TTLs, ch0_fcv_data, ~, ts] = read_separate_tarheel_files(datapath, no_of_channels);
        %Background subtract data
        processed_data = bg_subtract_aFCV(ch0_fcv_data, cut_params, bg_params);
        [processed_data, processed_ts] = trim_data_aFCV(processed_data, cut_params, ts);
        
        
        %% Apply chemometrics
        
        if params.apply_chemometrics
            %initialise variables
            model_cvs = [];
            c_predicted = [];
            residuals = [];
            
            %apply chemometrics
            [model_cvs, c_predicted, residuals.q, residuals.q_crit, residuals.q_cutoff] = ...
                fcv_chemometrics(processed_data, chemo_params, TTLs, processed_ts);
        end
        
        %% Plot
        %h = plot_fcv_trials_Anaesthetized(model_cvs, processed_ts, TTLs, params, c_predicted);
        %suptitle([params.fig_title]);
        
        
        %calculate max value of DA i.e. DA peak
        baseline = (cut_params.target_pos + cut_params.bg_pos)*cut_params.sample_rate;
        % check for peak dopamine between baseline and max_end seconds later
        % (important to avoid large values caused by post-stim drift
        max_end = 10;
        max_end = max_end*cut_params.sample_rate;
        DA_max = [];
        DA_latency = [];
        for k = 1: size(c_predicted, 2)
            [max_val, max_index] = max(c_predicted{k}(1,baseline:baseline+max_end),[], 2);
            DA_max(k) = max_val;
            DA_latency(k) = max_index; %N.b. this is latency from baseline in scan number
        end
        
        
        
        delimiter = '_'; %delimiter used between filename sections
        remove = 1; % Boolean, True = remove the target text from the output, False = leave target text in output
        
        for l = 1:length(fileNames)
            target = 'Hz'; %target text
            stimFreq(l) = str2double(filenameSplitter(fileNames{l},delimiter,target,remove));
            target = 'p'; %target text
            stimPulses(l) = str2double(filenameSplitter(fileNames{l},delimiter,target,remove));
            target = 'uA'; %target text
            stimStrength(l) = str2double(filenameSplitter(fileNames{l},delimiter,target,remove));
        end
               
    end
      %Save data
  data(i).experiment = experiment{i};
  data(i).subject = subject{i};
  data(i).date = date{i};
  
  data(i).raw.filename = fileNames;
  data(i).raw.values = ch0_fcv_data;
  data(i).raw.ts = ts;
  data(i).raw.TTLs = TTLs;
  
  data(i).processed.filename = fileNames;
  data(i).processed.processed_data = processed_data;
  data(i).processed.ts = processed_ts;
  data(i).processed.model_cvs = model_cvs;
  data(i).processed.c_predicted = c_predicted;
  data(i).processed.residuals = residuals;

  
  data(i).summary.DA_max = DA_max;
  data(i).summary.DA_latency = DA_latency;
  
  data(i).stim_params.stimFreq = stimFreq;
  data(i).stim_params.stimPulses = stimPulses;
  data(i).stim_params.stimStrength = stimStrength;
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

