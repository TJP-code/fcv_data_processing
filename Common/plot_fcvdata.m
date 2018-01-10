function h = plot_fcvdata(data,ts,clim)
    if nargin < 2; ts = []; end;
    if nargin < 3; clim = []; end;
    if isempty(ts)
        h = imagesc(data);
    else
        h = imagesc(ts,[0:1:size(data,1)],data);
    end
    load fcv_colormap
    colormap(norm_fcv)
    if isempty(clim)
        [clim] = scale_fcv_colorbar(data);
    end
    caxis(clim)
    ax = gca;
    ax.YDir = 'normal';
    
    title('Colourplot - Applied waveform Vs Time');xlabel('Time(s)');ylabel('Point Number')
    
    