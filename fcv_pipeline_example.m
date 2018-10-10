clear
close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Description:
% This example script runs a use case of fcv data processing, incorporating
% all data processing steps containing within the toolbox
%
% Use case:
% Visualise fcv data at the point of a magasine entry from a single
% recording session. 
% Generating a reward delivery triggered chemometric plot, with indivudual
% trial and average traces, generate an average chemometric colour plot
%
% Steps:
%
% 1) Read fcv data from tarheel file 
%   In this case one folder containing multiple 2min recording files, they will 
%   be appended and one set of timestamps created for the whole session
%   replace with tarheel_read to just read a single file.
%
%
% 2) Extract TTL times
%   Get the times that rewards were delivered
%
% 3) Cut fcv data around magazine entry
%   Using the cutting function we extract data 10 seconds before and 30
%   seconds after magazine entry, we set our fcv background 2 seconds
%   before reward delivery
%
% 4) Background subtract data
%   We now have 40 second segments of raw fcv data, this is background
%   subtracted 8 seconds into the segment and filtered
%
% 5) Apply chemometrics 
%   Using a template of example dopamine cyclic voltamagrams we apply a principal component
%   regression to the backgrounded data
%
% 6) Plot data
%   With now 21 trials of chemometric data all of which have a reward at
%   10s in we can plot an average chemometric colour plot, along with
%   an average chemometric line along with the indivudual trials. 
%
%   To plot trials fcv colour plot and TTLs set params.plot_each = 1 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% params for common functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 

%chemometric variables
chemo_params.cv_matrix = dlmread('..\fcv_data_processing\chemoset\cvmatrix2.txt');
chemo_params.conc_matrix = dlmread('..\fcv_data_processing\chemoset\concmatrix2.txt');
chemo_params.pcs = []; %let the function decide how many principal components to use
chemo_params.alpha = 0.05;
chemo_params.plotfigs = 0; %we've decided not to plot the chemometrics on indivudual trials, set to 1 to see the output

%cutting variables
cut_params.include.bits = []; %include target_bit
cut_params.include.window = []; %time(s) before target,time after target
cut_params.exclude.bits = [];
cut_params.exclude.window = [];
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
params.scan_number = 150; %point in scan to plot if chemometrics not applied
params.apply_chemometrics = 1; %do chemometric processing, set to 0 to just average the raw fcv data

%read in tarheel session
datapath = 'C:\Data\GluA1 FCV\GluA1 Data\003\Gazorpazorp\20180118_RI60Day3\RI60Day3\';
no_of_channels = 2;
[fcv_data.TTLs,  ch0_fcv_data, ch1_fcv_data,  fcv_data.ts] = read_whole_tarheel_session(datapath, no_of_channels);

fcv_data.data = ch0_fcv_data;
params.fig_title = 'zorp RI60 Day 3 Rewarded lever press ch0';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract TTL times
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[TTL_data.start, TTL_data.end] = extract_TTL_times(fcv_data.TTLs);
TTL_data.TTLs = fcv_data.TTLs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cut fcv data around magazine entry
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[cut_data, cut_points, cut_TTLs, cut_ts] = cut_fcv_data(fcv_data.data, TTL_data, fcv_data.ts, cut_params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Background subtract data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%set bg
bg_pos = ones(length(cut_data),1);
bg_pos = bg_pos*((cut_params.time_align(1)+cut_params.bg_pos)*cut_params.sample_rate);

%bg subtract
for i = 1:length(cut_data)
    bg_params.bg_pos  = bg_pos(i);
    [processed_data{i}] = process_raw_fcv_data(cut_data{i}, bg_params);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply chemometrics 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if params.apply_chemometrics
        
    %initialise chemometric variables
    model_cvs = [];
    c_predicted = [];
    residuals = [];
    [model_cvs, c_predicted, residuals.q, residuals.q_crit, residuals.q_cutoff] = ...
        fcv_chemometrics(processed_data, chemo_params, cut_TTLs, cut_ts);    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sum_colourplot = zeros(size(processed_data{1}));
for i = 1:length(processed_data)
    if ~ismember(i,params.trial_exclude_list)
        if params.plot_each
            %plot each colour plot
            figure
            subplot(1,3,1)
            plot_fcvdata(processed_data{i},cut_ts{i})    
            c = colorbar('eastoutside');
            ylabel(c,'Current(nA)')
            if params.apply_chemometrics
                title('Chemometric FCV data')
            else
                title('Raw FCV data')
            end

            %plot I vs T
            subplot(1,3,2)
            if params.apply_chemometrics
                plot(cut_ts{i},smooth(c_predicted,5),'k')
                title('Chemometric I vs T');xlabel('Time(s)');ylabel('Current (nA)')
            else                
                plot(cut_ts{i},smooth(processed_data{i}(params.scan_number,:),5),'k')
                title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
            end
            xlim([min(cut_ts{i}), max(cut_ts{i})]);

            %plot TTLS
            subplot(1,3,3)
            plot_TTLs(cut_TTLs{i}, cut_ts{i}, params.TTLnames)
            title('TTLs');xlabel('Time(s)');ylabel('TTLs')
            
            figtitle = sprintf('Trial number %d', i);
            suptitle(params.figtitle)
        end

        sum_colourplot = sum_colourplot+processed_data{i};
    end
end

%final plot, avg colour plot and individual i vs t
h = figure;
subplot(1,2,1)
avg_colourplot = sum_colourplot/length(processed_data);
plot_fcvdata(avg_colourplot);    
c = colorbar('eastoutside');
ylabel(c,'Current(nA)')
title('Average Colour plot')
subplot(1,2,2)
plot(all_IvT')
hold on
plot(mean(all_IvT),'k','LineWidth', 2)
title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
set(gcf, 'Position', [300, 300, 1300, 500]);

suptitle([params.fig_title]);