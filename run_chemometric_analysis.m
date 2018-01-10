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
[TTLs, ch0_fcv_data, ch1_fcv_data, ts] = read_whole_tarheel_session(datapath, no_of_channels);

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

exclude_list = [2]; %not implemented yet
bg_adjustments = [5 -.5]; %not implemented yet

[cut_ch0_data, cut_ch0_points, cut_TTLs, cut_ts] = cut_fcv_data(ch0_fcv_data, TTL_data, ts, params);
[cut_ch1_data, cut_ch1_points, ~] = cut_fcv_data(ch1_fcv_data, TTL_data, ts, params);

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

A = dlmread('..\fcv_data_processing\chemoset\cvmatrix2.txt');
C = dlmread('..\fcv_data_processing\chemoset\concmatrix2.txt');
pcs = [];
alpha = [];
i = [];
sum_colourplot = zeros(size(processed_data{1}));
for i = 1:length(processed_data)

    [Vc, F, Qcrit, K] = pca_training_set(A,C,pcs, alpha);

    [C_predicted{i}, Q{i}, Q_cutoff{i}, model_cvs{i}, residuals{i}] = apply_pcr(processed_data{i}, Vc, F, Qcrit);
    
    %plot colour plot
    figure
    subplot(2,3,1)
    plot_fcvdata(processed_data{i},cut_ts{i})    
    c = colorbar('eastoutside');
    ylabel(c,'Current(nA)')
    title('Raw FCV data')
    %plot chemometric colour plot
    subplot(2,3,2)
    plot_fcvdata(model_cvs{i},cut_ts{i})    
    c = colorbar('eastoutside');
    ylabel(c,'Current(nA)')
    title('Chemometric FCV data')
    %plot I vs T
    subplot(2,3,3)
    plot(smooth(C_predicted{i}(1,:),5),'k')
    title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
    
    %plot TTLS
    subplot(2,3,6)
    plot_TTLs(cut_TTLs{i}, cut_ts{i})
    title('TTLs');xlabel('Time(s)');ylabel('TTLs')
    
    %plot model fit
    subplot(2,3,4)    
    plot(Q{i},'k')    
    hold on 
    plot(Qcrit*ones(size(Q{i},2)),'r')
    title('Residuals');xlabel('Time(s)');ylabel('Q value')
    
    %plot residuals
    subplot(2,3,5)
    plot_fcvdata(residuals{i},cut_ts{i})
    c = colorbar('eastoutside');
    ylabel(c,'Current(nA)')
    title('Residuals')
    
    all_IvT(i,:) = smooth(C_predicted{i}(1,:),5);
    sum_colourplot = sum_colourplot+model_cvs{i};
end

figure
subplot(1,2,1)
avg_colourplot = sum_colourplot/length(processed_data);
plot_fcvdata(avg_colourplot)    
c = colorbar('eastoutside');
ylabel(c,'Current(nA)')
title('Average Chemometric plot')
subplot(1,2,2)
plot(all_IvT')
hold on
plot(mean(all_IvT),'k')
%Plot avg