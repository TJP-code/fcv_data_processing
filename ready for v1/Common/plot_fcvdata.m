function h = plot_fcvdata(data,ts,lines,clim)

% plot_fcvdata creates a colour plot of fcv data from tarheel fcv
%
% function h = plot_fcvdata(data,ts,clim,lines)
% 
% Take a matrix of fcv data and plots using traditional colour map
%
% Inputs:
%   data                - fcv data (m�n matrix, points in scan�scan number)
%
%   (optional)
%   ts                  - timestamps for fcv data (much be the same size as fcv data)
%   lines.               (data structure containing plotting params)
%       point_number    - point in waveform to draw line
%       scan_number     - scan to draw line at
%       bg              - scan to draw bg line
%
% Outputs:
%   h                   - handle to plot
%
% Authors:
%   TJP and MP 2018

if nargin < 2; ts = []; end;
if nargin < 3; lines = []; end;
if nargin < 4; clim = []; end;
if isempty(ts)
    h = imagesc(data);
    hold on
    if ~isempty(lines) 
        %plot white lines for scan and point
        plot([1 size(data,1)],[lines.point_number,lines.point_number],'w')
        plot([lines.scan_number,lines.scan_number],[0,size(data,1)],'w')
        plot([lines.bg,lines.bg],[0,size(data,1)],'b')            
    end
else
    h(1) = imagesc(ts,[0:1:size(data,1)],data);
    hold on
    if ~isempty(lines) 
        %plot white lines for scan and point
        h(2) = plot([ts(1),max(ts)],[lines.point_number,lines.point_number],'w');
        h(3) = plot([ts(lines.scan_number),ts(lines.scan_number)],[0,size(data,1)],'w');
        h(4) = plot([ts(lines.bg),ts(lines.bg)],[0,size(data,1)],'b');            
    end
end
load fcv_colormap
colormap(norm_fcv)
if isempty(clim)
    [clim] = scale_fcv_colorbar(data);
end
caxis(clim)
ax = gca;
ax.YDir = 'normal';

xlabel('Time(s)');ylabel('Point Number')
    
   