%plot the LED light best example

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% params for common functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
close all
%bg sub params
bg_params.filt_freq = 2000; %we found 2000Hz for 2 channel data gave a smoother CV
bg_params.sample_freq = 58820; 

%chemometric variables
chemo_params.cv_matrix = dlmread('C:\Users\tjahansprice\Documents\GitHub\fcv_data_processing\chemoset\cvmatrix2.txt');
chemo_params.conc_matrix = dlmread('C:\Users\tjahansprice\Documents\GitHub\fcv_data_processing\chemoset\concmatrix2.txt');
chemo_params.pcs = [];
chemo_params.alpha = 0.05;
chemo_params.plotfigs = 0;

params.apply_chemometrics = 0;
params.scan_number = 150;
params.plot_CV = 1;
params.extrachemometricsplot = 0;

filename = 'C:\Users\tjahansprice\Google Drive\Thomas B analysis\candidate cvs\LED example\40_20150501_sanderson_121';
no_of_channels = 2;
[fcv_header, ch1_fcv_data, ch0_fcv_data] = tarheel_read(filename,no_of_channels);

[ts,TTLs] = TTLsRead([filename '.txt']);

%ts = [0:0.1:size(ch0_fcv_data,2)/10-0.1]; 

bg_params.bg_pos = 714;

[processed_data] = process_raw_fcv_data(ch0_fcv_data, bg_params);
plot_window = [70 85];

data{1} = processed_data;
[model_cvs, c_predicted, residuals.q, residuals.q_crit, residuals.q_cutoff] = ...
        fcv_chemometrics(data, chemo_params, TTLs, ts);

%==========plot=================

%plot colour plot
figure
subplot(1,3,1)


if params.apply_chemometrics
    plot_fcvdata(model_cvs{1},ts,[],[-4 6]); 
    title('Chemometric FCV data')
else
    plot_fcvdata(processed_data,ts,[],[-4 6]);
    title('Raw FCV data')
end

c = colorbar('eastoutside');
ylabel(c,'Current(nA)')

xlim(plot_window);
hold on
%plot when LED comes on 
LED = find(TTLs(:,4) == 1);
lighton = [LED(1) LED(1)+100];
plot(lighton/10,[50,50],'w');


%plot I vs T
subplot(1,3,2)
if params.apply_chemometrics
    plot(ts,smooth(c_predicted(1,:),5),'k')
    hold on                
    if params.extrachemometricsplot == 1
        plot(ts,smooth(processed_data(params.scan_number,:),5),'r')
        plot(ts,smooth(c_predicted(2,:),5),'b')
    end
    title('Chemometric I vs T');xlabel('Time(s)');ylabel('Current (nA)')

else                
    plot(ts,smooth(processed_data(params.scan_number,:),5),'k')
    title('I vs T');xlabel('Time(s)');

end
xlim(plot_window);

if params.plot_CV == 1
    %plot cv instead of TTL
    subplot(1,3,3)
    if params.apply_chemometrics == 1
    plot_cv(processed_data(:,746))
    else
    plot_cv(model_cvs{1}(:,746))
    end
    
    title('CV');
else
    %plot TTLS
    subplot(1,3,3)
    plot_TTLs(TTLs, ts)%, params.TTLnames)
    title('TTLs');xlabel('Time(s)');ylabel('TTLs')

%     figtitle = sprintf('Trial number %d', i);
%     suptitle(params.figtitle)
    
end
set(gcf, 'Position', [300, 300, 1900, 500]);