clear
close all
datapath = '..\fcv_data_processing\test data\46_20170208_02 - Variable reward post\';

%-------------------------------------------------------------
%cv match params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 

cv_params.cv_match_template = 'Chemometrics\cv_match';
cv_params.shiftpeak = 0;
cv_params.plotfig = 1;
cv_params.colormap_type = 'fcv';
cv_params.scan_number = 140;
cv_params.point_number = 170;
cv_params.bg = 95;
%--------------------------------------------------------------

no_of_channels = 2;
[TTLs, ch0_fcv_data, ch1_fcv_data] = read_whole_tarheel_session(datapath, no_of_channels);

[TTL_data.start, TTL_data.end] = extract_TTL_times(TTLs);
TTL_data.TTLs = TTLs;

params.include.bits = []; %include target_bit
params.include.buffer = []; %time(s) before target,time after target
params.exclude.bits = [];
params.exclude.buffer = [];
params.target_bit = 9;
params.target_location = 0; %0 = start, 1 = end, 0.5 = middle
params.ignore_repeats = [10]; %no of seconds to ignore repeats
params.sample_rate = 10;
params.time_align = [10 30];
params.bg_pos = -2; %seconds relative to target_location

exclude_list = [4]; %not implemented yet
bg_adjustments = [5 -.5]; %not implemented yet

[cut_ch0_data, cut_ch0_points, cut_TTLs] = cut_fcv_data(ch0_fcv_data, TTL_data, params);
[cut_ch1_data, cut_ch1_points, ~] = cut_fcv_data(ch1_fcv_data, TTL_data, params);

%set bg
bg_pos = ones(length(cut_ch0_data),1);
bg_pos = bg_pos*((params.time_align(1)+params.bg_pos)*params.sample_rate);

%%bg subtract/plot
for i = 1:length(cut_ch0_data)
    bg_params.bg_pos  = bg_pos(i);
    cv_params.bg = bg_pos(i);
    [processed_data{i}] = process_raw_fcv_data(cut_ch0_data{i}, bg_params);

end

%option to plot/prune

%plot avg IvsT, plus individual trials, look for outliers

%---------------------

%training set import/validation

%let f-test pick out components, or specific number

A = dlmread('..\fcv_data_processing\chemosetcvmatrix2.txt');
C = dlmread('..\fcv_data_processing\chemosetconcmatrix2.txt');
pcs = [];
alpha = [];
i = [];
for i = 1:length(processed_data)

    [Vc, F, Qcrit, K] = pca_training_set(A,C,pcs, alpha);

    [C_predicted{i}, Q{i}, Q_cutoff{i}, model_cvs{i}, residuals{i}] = apply_pcr(processed_data{i}, Vc, F, Qcrit);
    
    [h] = visualise_fcv_data(processed_data{i}, ts, cv_params, cv_match, cut_TTLs);
    figure
    subplot(2,2,1)
    plot(C_predicted{i}(1,:))
    
    subplot(2,2,2)
    imagesc(model_cvs{i})
    load fcv_colormap
    colormap(norm_fcv)
    [vals] = scale_fcv_colorbar(model_cvs{i});
    caxis(vals)
    ax = gca;
    ax.YDir = 'normal';
    colorbar
    
    subplot(2,2,3)
    plot(Q{i})    
    hold on 
    plot(Qcrit*ones(size(Q{i},2)),'k')
    
    subplot(2,2,4)
    imagesc(residuals{i})
    load fcv_colormap
    colormap(norm_fcv)
    [vals] = scale_fcv_colorbar(residuals{i});
    caxis(vals)
    ax = gca;
    ax.YDir = 'normal';
    colorbar

end