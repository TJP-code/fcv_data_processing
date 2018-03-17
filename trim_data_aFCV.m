
function [trimmed_data, ts] = trim_data_aFCV(cut_data, cut_params, ts)

%Identify start and end cut points in seconds and convert to scan number
trim_start = (cut_params.trimData(1)*cut_params.sample_rate)+1;
trim_end = cut_params.trimData(2)*cut_params.sample_rate+1;
%%bg subtract/plot
for i = 1:length(cut_data)
    [trimmed_data{i}] = cut_data{1,i}(:,trim_start:trim_end);
    [ts{i}] = ts{1,i}(:,trim_start:trim_end);
end