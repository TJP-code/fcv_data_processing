function h = plot_fcv_trials_Anaesthetized(processed_data, cut_ts, cut_TTLs, params, c_predicted)

%option to plot/prune

%plot avg IvsT, plus individual trials, look for outliers

%---------------------
sum_colourplot = zeros(size(processed_data{1}));
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

        all_IvT(i,:) = smooth(processed_data{i}(params.scan_number,:),5);
        sum_colourplot = sum_colourplot+processed_data{i};
    end
end

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
%Plot avg