function [cut_points_ch0,cut_points_ch1] = visualise_fcv_trials(datapath, exclude_list, no_of_channels, cut_params, bg_params, chemo_params, ...
     apply_chemometrics, scan_number, TTLnames, plot_each, fig_title)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load in data (could put this outside function and pass fcv data)
[TTLs, ch0_fcv_data, ch1_fcv_data, ts] = read_whole_tarheel_session(datapath, no_of_channels);

[TTL_data.start, TTL_data.end] = extract_TTL_times(TTLs);
TTL_data.TTLs = TTLs;

%cut ch0 data, background and plot
[cut_data_ch0, cut_points_ch0, cut_TTLs, cut_ts] = cut_fcv_data(ch0_fcv_data, TTL_data, ts, cut_params);
processed_data_ch0 = bg_subtract(cut_data_ch0, cut_params, bg_params);
if apply_chemometrics
    [ch0_model_cvs, ch0_c_predicted, ch0_q, ch0_q_crit, ch0_q_cutoff] = fcv_chemometrics(processed_data_ch0, chemo_params, cut_TTLs, cut_ts);
    plot_fcv_trials(ch0_model_cvs, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list, TTLnames, apply_chemometrics, ch0_c_predicted)
else
    plot_fcv_trials(processed_data_ch0, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list, TTLnames, apply_chemometrics)
end
suptitle([fig_title ' Ch0']);

%if two channel recording do the same for ch1
if no_of_channels == 2
    [cut_data_ch1, cut_points_ch1, cut_TTLs, cut_ts] = cut_fcv_data(ch1_fcv_data, TTL_data, ts, cut_params);
    processed_data_ch1 = bg_subtract(cut_data_ch1, cut_params, bg_params);
    if apply_chemometrics
        [ch1_model_cvs, ch1_c_predicted, ch0_q, ch0_q_crit, ch0_q_cutoff] = fcv_chemometrics(processed_data_ch0, chemo_params, cut_TTLs, cut_ts);
        plot_fcv_trials(ch1_model_cvs, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list, TTLnames, apply_chemometrics, ch1_c_predicted)
    else
        plot_fcv_trials(processed_data_ch1, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list, TTLnames, apply_chemometrics)
    end
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

function h = plot_fcv_trials(processed_data, scan_number,cut_ts, cut_TTLs, plot_each, plot_all_IvT, exclude_list, TTLnames, apply_chemometrics, c_predicted)

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
            if apply_chemometrics
                title('Chemometric FCV data')
            else
                title('Raw FCV data')
            end

            %plot I vs T
            subplot(1,3,2)
            if apply_chemometrics
                plot(cut_ts{i},smooth(c_predicted,5),'k')
                title('Chemometric I vs T');xlabel('Time(s)');ylabel('Current (nA)')
            else                
                plot(cut_ts{i},smooth(processed_data{i}(scan_number,:),5),'k')
                title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
            end
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
    rows = floor(sqrt(trials))+1;
    cols = ceil(sqrt(trials));    
    for j = 1:size(all_IvT,1)
        subplot(rows,cols,j);
        plot(cut_ts{j},smooth(processed_data{j}(scan_number,:),5),'k')
        xlim([min(cut_ts{j}), max(cut_ts{j})]);
    end
    suptitle('All trials I vs T')
end

%final plot, avg colour plot and individual i vs t
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