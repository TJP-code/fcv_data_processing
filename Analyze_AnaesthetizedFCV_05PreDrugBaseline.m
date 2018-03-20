close all
clear all
%% Parameters
%Move these inside data processing loop if you want to setup individual parameters for each animal/session

%list of experiment specific params
experimentParams = readtable('E:\Marios aFCV\GLRA_002\DataAnalysis\GLRA002_params.xlsx');

%Set number of channels
no_of_channels = 1;

%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820;


%chemometric variables
chemo_params.cv_matrix = dlmread('E:\Marios aFCV\chemoset1\cvmatrix1.txt');
chemo_params.conc_matrix = dlmread('E:\Marios aFCV\chemoset1\concmatrix1.txt');
chemo_params.pcs = [];
chemo_params.alpha = 0.05;
chemo_params.plotfigs = 0;

%cutting variables
cut_params.sample_rate = 10;
cut_params.target_pos = 5; %time of stimulation
cut_params.bg_pos = -0.5; %seconds relative target
cut_params.trimData = [0 20]; %crop long files between a [start end] time in seconds


%visualisation params
params.trial_exclude_list = [];%[17,23, 57, 42];
params.plot_each =  1; %plot individual trials/cut timestamps
params.scan_number = 317;
params.plot_all_IvT = 0;
params.apply_chemometrics = 1; %do chemometrics
params.fig_title = 'Amplitude Response Curve';

%% Set up data path and subfolder structure

%Directory containing all files
directory = 'E:\Marios aFCV\GLRA_002\';
%Pull out all folders within the directory, i.e. individual subjects
folderlist = dir(directory);
folders = {folderlist.name};
isfolder = cell2mat({folderlist.isdir});
folders(~isfolder)=[];

%find list of relevant folders starting with GLRA002 and update folders variable
relevantFolders  = strfind([folders], 'GLRA002');
folders = folders(~cellfun(@isempty, relevantFolders));
%Manual Override
%folders = {'GLRA002_20170524_GLRA50.6d','GLRA002_20170524_GLRA51.6c','GLRA002_20170524_GLRA64.1e','GLRA002_20170601_GLRA64.1c','GLRA002_20170606_GLRA52.4d','GLRA002_20170606_GLRA53.5f','GLRA002_20170920_GLRA56.2a','GLRA002_20170920_GLRA62.4b','GLRA002_20170922_GLRA65.1a','GLRA002_20170925_GLRA58.3c','GLRA002_20170925_GLRA58.3d','GLRA002_20170927_GLRA58.3b','GLRA002_20170927_GLRA65.2a'};


%list of important subfolders containing session specific data
subfolder1 = '\01_Stabilization\';
subfolder2 = '\02_STIMRESPONSE_VARY_AMPLITUDE\';
subfolder3 = '\03_STIMRESPONSE_VARY_PULSES\';
subfolder4 = '\04_Stabilization_Period2\';
subfolder5 = '\05_Baseline_PreDrug\';
subfolder6 = '\06_DrugPeriod\';
subfolders = {subfolder5};
% subfolders = {subfolder1,subfolder2,subfolder3,subfolder4,subfolder5,subfolder6};


%% Main Loop
%loop through each folder (subject) and each subfolder (protocol)
for i= 1:length(folders)
    %Extract subject and sessiond details from folder name
    sessionDetails = strsplit(folders{i}, '_');
    experiment{i} = sessionDetails{1};
    date{i} = sessionDetails{2};
    subject{i} = sessionDetails{3};
    
    
    %Identify subject and update parameters accordingly
    varindex = cellfind(subject{i}, experimentParams.SubjID);
    
    cut_params.trimData = [experimentParams.TrimStart(varindex) experimentParams.TrimEnd(varindex)];
    cut_params.bg_pos = experimentParams.Baseline(varindex);
    cut_params.target_pos = experimentParams.TargetPos(varindex);
    max_end = experimentParams.PeakPeriod(varindex);
    Genotype{i} = experimentParams.Genotype(varindex);
    Sex{i} = experimentParams.Sex(varindex);
    CalibrationFactor{i} = experimentParams.CalibrationFactor(varindex); 
    
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
        %         h = plot_fcv_trials_Anaesthetized(model_cvs, processed_ts, TTLs, params, c_predicted);
        %         suptitle([params.fig_title]);
        
        
        %calculate max value of DA i.e. DA peak
        baseline = (cut_params.target_pos - cut_params.trimData(1))*cut_params.sample_rate;
        % check for peak dopamine between baseline and max_end seconds later
        % (important to avoid large values caused by post-stim drift
%         max_end = 5;
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
       stimFreq = [];
       stimPulses = [];
       stimStrength = [];
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
    data(i).genotype = Genotype{i};
    data(i).sex = Sex{i};
    data(i).calibrationFactor = CalibrationFactor{i};
    
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
%%
  summaryDA_max = [];
  summaryDA_latency = [];
  subjectcol = {};
for i = 1:size(data,2)

   temp_max  = groupstats([data(i).stim_params.stimPulses]', [data(i).summary.DA_max]',@mean);
   temp_latency = groupstats([data(i).stim_params.stimPulses]', [data(i).summary.DA_latency]',@mean);
  
   
   newrows = size(temp_max,1);
   oldpos =  size(subjectcol,1);
   subjectcol((oldpos+1): (oldpos+newrows),1)= {data(i).subject};
   genotypecol((oldpos+1): (oldpos+newrows),1)= {data(i).genotype};
   sexcol((oldpos+1): (oldpos+newrows),1)= {data(i).sex};
   calibrationcol((oldpos+1): (oldpos+newrows),1)= {data(i).calibrationFactor};
   summaryDA_max = [summaryDA_max; temp_max];
   summaryDA_latency = [summaryDA_latency; temp_latency];
end

    summary = {subjectcol genotypecol sexcol calibrationcol summaryDA_max summaryDA_latency};
% xlswrite('C:\Users\mario\Documents\GitHub\Marios-temp\GLRA002_IntensitySTimResponseCurve.xlsx', summary)
% ans = cellfind('WT', [data.genotype])
% {data(ans).subject}

%save('E:\Marios aFCV\GLRA_002\DataAnalysis\GLRA002_PulseResponse', 'data', 'summary' )

%%
%Average responses during baseline period
%data stored in data(i).processed.c_predicted


%initialisevars
avg_DA_WT = [];
avg_DA_KO = [];
avg_DA_cal_WT = [];
avg_DA_cal_KO = [];
for i = 1: size(data,2)
%convert data to numeric matrix, rows 1,3,5... are DA, rows 2,4,6.... are pH
temp = cell2mat(data(i).processed.c_predicted(1,:)');
%DA data picker for even rows
temp = temp(1:2:size(temp,1),:);
temp_mean = mean(temp);
avg_DA(i,:) = temp_mean;

temp_mean_cal = temp_mean/data(i).calibrationFactor;
avg_DA_cal(i,:) = temp_mean_cal;

if strcmp([data(i).genotype], 'WT');
    avg_DA_WT = [avg_DA_WT;  temp_mean];
    avg_DA_cal_WT = [avg_DA_cal_WT;  temp_mean_cal];
elseif strcmp([data(i).genotype], 'KO');
    avg_DA_KO = [avg_DA_KO; temp_mean];
    avg_DA_cal_KO = [avg_DA_cal_KO; temp_mean_cal];
end
end


%%
save('E:\Marios aFCV\GLRA_002\DataAnalysis\GLRA002_05BaselinePreDrugData', 'data', 'summary', 'avg_DA_WT','avg_DA_cal_WT' , 'avg_DA_KO','avg_DA_cal_KO')














