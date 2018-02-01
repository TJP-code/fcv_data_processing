function visualise_fcv_trials()
clear
close all
%variables: move these into parameters
datapath = '..\fcv_data_processing\test data\46_20170208_02 - Variable reward post\';
datapath = 'I:\GLRA_FCV\Feratu_Coach\20171220_RI60Day1\RI60Day1\';
datapath = 'C:\Data\GluA1 FCV\GluA1 Data\003\Gazorpazorp\20180118_RI60Day3\RI60Day3\';
datapath = 'E:\VolatmmetryRoomData\GLRA_FCV\003\Gazorpazorp\20180118_RI60Day3\RI60Day3\';
fig_title = 'zorp RI60 Day 3 Rewarded lever press';

exclude_list = [];%[17,23, 57, 42];
plot_each =  0; %plot individual trials/cut timestamps
scan_number = 150;
plot_all_IvT = 0;


%-------------------------------------------------------------
%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 

%--------------------------------------------------------------

%meta data to add to structure:


no_of_channels = 2;
[TTLs, ch0_fcv_data, ch1_fcv_data, ts] = read_whole_tarheel_session(datapath, no_of_channels);

[TTL_data.start, TTL_data.end] = extract_TTL_times(TTLs);
TTL_data.TTLs = TTLs;

params.include.bits = []; %include target_bit
params.include.window = []; %time(s) before target,time after target
params.exclude.bits = [];
params.exclude.window = [];
params.target_bit = 1;
params.target_location = 0; %0 = start, 1 = end, 0.5 = middle
params.ignore_repeats = []; %no of seconds to ignore repeats
params.sample_rate = 10;
params.time_align = [10 30]; %window size, [seconds before after]
params.bg_pos = -2; %seconds relative to target_location


bg_adjustments = [5 -.5]; %not implemented yet


%cut ch0 data, background and plot
[cut_data_ch0, cut_points_ch0, cut_TTLs, cut_ts] = cut_fcv_data(ch0_fcv_data, TTL_data, ts, params);
processed_data_ch0 = bg_subtract(cut_data_ch0, params, bg_params);
plot_fcv_trials(processed_data_ch0, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list)
suptitle([fig_title ' Ch0']);

%if two channel recording do the same for ch1
if no_of_channels == 2
    [cut_data_ch1, cut_points_ch1, cut_TTLs, cut_ts] = cut_fcv_data(ch1_fcv_data, TTL_data, ts, params);
    processed_data_ch1 = bg_subtract(cut_data_ch1, params, bg_params);
    plot_fcv_trials(processed_data_ch1, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list)
    suptitle([fig_title ' Ch1']);
end


function processed_data = bg_subtract(cut_data, params, bg_params)

%if no data give error

%set bg
bg_pos = ones(length(cut_data),1);
bg_pos = bg_pos*((params.time_align(1)+params.bg_pos)*params.sample_rate);

%%bg subtract/plot
for i = 1:length(cut_data)
    bg_params.bg_pos  = bg_pos(i);
    [processed_data{i}] = process_raw_fcv_data(cut_data{i}, bg_params);

end

function h = plot_fcv_trials(processed_data, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list)

TTLnames = {'Reward', 'Head Entry', 'Head Exit', 'Left Lever Press', 'Left Lever Out', 'Right Lever Press', 'Right Lever Out', 'Fan', '', '', '', '', '', '', '', ''};

%option to plot/prune

%plot avg IvsT, plus individual trials, look for outliers

%---------------------
sum_colourplot = zeros(size(processed_data{1}));
for i = 1:length(processed_data)
    if ~ismember(i,exclude_list)
        if plot_each
            %plot colour plot
            figure
            subplot(1,3,1)
            plot_fcvdata(processed_data{i},cut_ts{i})    
            c = colorbar('eastoutside');
            ylabel(c,'Current(nA)')
            title('Raw FCV data')

            %plot I vs T
            subplot(1,3,2)
            plot(cut_ts{i},smooth(processed_data{i}(scan_number,:),5),'k')
            title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
            xlim([min(cut_ts{i}), max(cut_ts{i})]);

            %plot TTLS
            subplot(1,3,3)
            plot_TTLs(cut_TTLs{i}, cut_ts{i}, TTLnames)
            title('TTLs');xlabel('Time(s)');ylabel('TTLs')
            
            figtitle = sprintf('Trial number %d', i);
            suptitle(figtitle)
        end

        all_IvT(i,:) = smooth(processed_data{i}(scan_number,:),5);
        sum_colourplot = sum_colourplot+processed_data{i};
    end
end

%plot all i vs t
if plot_all_IvT
    figure
    hold on
    trials = size(all_IvT,1);
    rows = floor(sqrt(trials));
    cols = ceil(sqrt(trials));    
    for j = 1:size(all_IvT,1)
        subplot(rows,cols,j);
        plot(cut_ts{j},smooth(processed_data{j}(scan_number,:),5),'k')
        xlim([min(cut_ts{j}), max(cut_ts{j})]);
    end
    suptitle('All trials I vs T')
end

h = figure;
subplot(1,2,1)
avg_colourplot = sum_colourplot/length(processed_data);
plot_fcvdata(avg_colourplot)    
c = colorbar('eastoutside');
ylabel(c,'Current(nA)')
title('Average Colour plot')
subplot(1,2,2)
plot(all_IvT')
hold on
plot(mean(all_IvT),'k','LineWidth', 2)
title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
set(gcf, 'Position', [300, 300, 1300, 500])
%Plot avg