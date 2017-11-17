function [h, fcv_IT, fcv_CV] = visualise_fcv_data(fcv_data, ts, params, TTLs, cv_match, ph_match)
% function [h] = visualise_fcv_data(fcv_data, ts, params, cv_match)
% Visualise FCV data, plots fcv data and returns a handle to the figure

% plotting data include: fcv colour plot, current vs time, and cyclic
% voltammogram for given points in the data. cv match data and TTLs are also plotted if provided 
% 

%check params
if nargin < 1; error('Need FCV data'); end;
if nargin < 2; 
    ts = [0:0.1:size(fcv_data,2)/10-0.1]; 
elseif isempty(ts)
    ts = [0:0.1:size(fcv_data,2)/10-0.1]; 
end
if nargin < 3; params = []; end;
if nargin < 4; TTLs = []; end;
if nargin < 5; cv_match = []; end;
if nargin < 6; ph_match = []; end;

if ~isfield(params,'point_number') || isempty(params.point_number)
     params.point_number = 150;
end
if ~isfield(params,'scan_number') || isempty(params.scan_number)
     params.scan_number = 20;
end
if ~isfield(params,'shiftpeak') || isempty(params.shiftpeak)
     params.shiftpeak = 0;
end
if ~isfield(params,'plotfig') || isempty(params.plotfig)
     params.plotfig = 0;
end
if ~isfield(params,'colormap_type') || isempty(params.colormap_type)
     params.colormap_type = 'jet';
end
if ~isfield(params,'bg') || isempty(params.bg)
     params.bg = [];
end

fcv_IT = fcv_data(params.point_number,:);
fcv_CV = fcv_data(:,params.scan_number);

h = figure;
subplot(2,3,1);
%check if need to do invert

imagesc(ts,[0:1:size(fcv_data,1)],fcv_data)

if strcmp(params.colormap_type,'b2r')
    colormap(b2r(min(fcv_data(:)),max(fcv_data(:))))
elseif strcmp(params.colormap_type,'fcv')
    load fcv_colormap
    colormap(norm_fcv)
    
    [vals] = scale_fcv_colorbar(fcv_data);
    caxis(vals)
else
    colormap(params.colormap_type);
end

ax = gca;
ax.YDir = 'normal';
title('Colourplot - Applied waveform Vs Time');xlabel('Time(s)');ylabel('Point Number')
c = colorbar('westoutside');
ylabel(c,'Current(nA)')
hold on
%plot white lines for scan and point
plot([ts(1),max(ts)],[params.point_number,params.point_number],'w')
plot([params.scan_number/10,params.scan_number/10],[0,size(fcv_data,1)],'w')
if ~isempty(params.bg)
    plot([params.bg/10,params.bg/10],[0,size(fcv_data,1)],'k')
end

subplot(2,3,2);
plot(ts, fcv_IT)
title('Current Vs Time');xlabel('Time');ylabel('Current (nA)')
xlim([ts(1),max(ts)]);
subplot(2,3,3);
plot(fcv_CV);
title('Cyclic Voltammogram');xlabel('Waveform Point Number');ylabel('Current (nA)')
%legend('Applied Waveform', 'CV');

%plot how cv data look
if ~isempty(cv_match)
    %da
    subplot(2,3,5);
    plot(cv_match(:,1:size(cv_match,2)))
    title('Template DA CV');xlabel('Voltage');ylabel('Current (nA)')
end
if ~isempty(ph_match)
    %ph
    subplot(2,3,6);
    plot(ph_match(1:size(cv_match,2)))
    title('Template PH CV');xlabel('Voltage');ylabel('Current (nA)')
end

%Modify TTLs to allow for separate lines
for i = 1:size(TTLs,2)
    TTLs_plot(:,i) = TTLs(:,i) + i
end

if ~isempty(TTLs)
    subplot(2,3,4);
    plot(ts,TTLs_plot)
    title('TTLs');xlim([ts(1),max(ts)]);xlabel('Times(s)');
    
end



