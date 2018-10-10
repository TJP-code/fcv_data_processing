function [h, c] = visualise_fcv_data_one_file(fcv_data, bg_params)


[processed_data] = process_raw_fcv_data(fcv_data, bg_params);
lines = []; %dont plot any scan/bg lines
clim = [-1.5 2.3];
ts = [0:0.1:(size(fcv_data,1)*0.1)-0.1];



for i = 1:size(processed_data,1)
    data_smooth_rows(i,:) = smooth(processed_data(i,:),3);
end


h = plot_fcvdata(data_smooth_rows,ts,[],clim);    
c = colorbar;
ylabel(c,'Current(nA)')

