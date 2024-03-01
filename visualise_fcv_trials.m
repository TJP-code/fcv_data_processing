function [processed_data, cut_points, model_cvs, c_predicted, residuals, all_IvT, avg_colourplot] = ...
    visualise_fcv_trials(fcv_data, params, cut_params, bg_params, chemo_params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%initialise variables
model_cvs = [];
c_predicted = [];
residuals = [];

[TTL_data.start, TTL_data.end] = extract_TTL_times(fcv_data.TTLs);
TTL_data.TTLs = fcv_data.TTLs;

%cut data, background and plot
[cut_data, cut_points, cut_TTLs, cut_ts] = cut_fcv_data(fcv_data.data, TTL_data, fcv_data.ts, cut_params);
processed_data = bg_subtract(cut_data, cut_params, bg_params);


if params.apply_chemometrics
    %apply chemometrics 
    [model_cvs, c_predicted, residuals.q, residuals.q_crit, residuals.q_cutoff] = ...
        fcv_chemometrics(processed_data, chemo_params, cut_TTLs, cut_ts);   
    
    [h, all_IvT, avg_colourplot] = plot_fcv_trials(model_cvs, cut_ts, cut_TTLs, params, c_predicted);
    
else

    [h, all_IvT, avg_colourplot] = plot_fcv_trials(processed_data, cut_ts, cut_TTLs, params, []);
end


function processed_data = bg_subtract(cut_data, params, bg_params)

%set bg
bg_pos = ones(length(cut_data),1);
bg_pos = bg_pos*((params.time_align(1)+params.bg_pos)*params.sample_rate);

%%bg subtract/plot
for i = 1:length(cut_data)
    bg_params.bg_pos  = bg_pos(i);
    [processed_data{i}] = process_raw_fcv_data(cut_data{i}, bg_params);

end

function [h, all_IvT, avg_colourplot] = plot_fcv_trials(processed_data, cut_ts, cut_TTLs, params, c_predicted)
h = 0;
avg_colourplot = [];
%option to plot/prune

%plot avg IvsT, plus individual trials, look for outliers

%---------------------
ogsum_colourplot = zeros(size(processed_data{1}));
for i = 1:length(processed_data)
    if ~ismember(i,params.trial_exclude_list)
        if params.plot_each
            %plot colour plot
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
                plot(cut_ts{i},smooth(c_predicted{i}(1,:),5),'k')
                hold on                
                if params.extrachemometricsplot == 1
                    plot(cut_ts{i},smooth(processed_data{i}(params.scan_number,:),5),'r')
                    plot(cut_ts{i},smooth(c_predicted{i}(2,:),5),'b')
                end
                title('Chemometric I vs T');xlabel('Time(s)');ylabel('Current (nA)')
                
            else                
                plot(cut_ts{i},smooth(processed_data{i}(params.scan_number,:),5),'k')
                title('I vs T');xlabel('Time(s)');
                 
            end
            xlim([min(cut_ts{i}), max(cut_ts{i})]);

            if params.plot_CV == 1
                %plot cv instead of TTL
                subplot(1,3,3)
                plot_cv(processed_data{i}(:,110))
                
            else
                %plot TTLS
                subplot(1,3,3)
                plot_TTLs(cut_TTLs{i}, cut_ts{i})%, params.TTLnames)
                title('TTLs');xlabel('Time(s)');ylabel('TTLs')

                figtitle = sprintf('Trial number %d', i);
                suptitle(params.figtitle)
            end
            set(gcf, 'Position', [300, 300, 1900, 600]);
            
        end
        
         if ~isempty(c_predicted)
             all_IvT(i,:) = smooth(c_predicted{i}(1,:),5);
         else
             all_IvT(i,:) = smooth(processed_data{i}(params.scan_number,:),5);
         end
        ogsum_colourplot = ogsum_colourplot + processed_data{i};
        sum_colourplot(:,:,i) = processed_data{i};
    end
end

if params.plot_main_figs == 1
%plot all i vs t
    if params.plot_all_IvT
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
    subplot(1,3,1)

    %check for nans so averaging is correct


    ogavg_colourplot = ogsum_colourplot/length(processed_data);
    avg_colourplot = nanmean(sum_colourplot,3);
    plot_fcvdata(avg_colourplot);    
    originalSize1 = get(gca, 'Position');
    c = colorbar('eastoutside');
    title('Average Colour plot')
    set(gca, 'Position', originalSize1);

    subplot(1,3,2)
    plot(all_IvT')
    hold on
    plot(mean(all_IvT),'k','LineWidth', 2)
    title('I vs T');xlabel('Time(s)');ylabel('Current (nA)')
    set(gcf, 'Position', [300, 300, 1900, 600]);
    %Plot avg
    subplot(1,3,3)
    imagesc(all_IvT)
    colorbar
    ax = gca;
    ax.YDir = 'normal';
    colormap(ax,'parula')
    suptitle([params.fig_title]);
end