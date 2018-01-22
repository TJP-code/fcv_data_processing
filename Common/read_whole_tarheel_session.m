function [TTLs, ch0_fcv_data, ch1_fcv_data, ts] = read_whole_tarheel_session(datapath, no_of_channels)

% function [TTLs, ch0_fcv_data, ch1_fcv_data] = read_whole_tarheel_session(datapath, no_of_channels)
%
% TJP & MP 09/05/2017
% todo: write help
%
% 10/1/2018 - added ts for whole session
%
if nargin < 2; no_of_channels = 2; end

filelist = dir(datapath);
if (size(filelist) == [0 1])
    error('Invalid path')
end
files = {filelist.name};
isfolder = cell2mat({filelist.isdir});
files(isfolder)=[];
myindices = find(~cellfun(@isempty,strfind(files,'txt')));
files([myindices])=[]; 



all_ch0_data = []; all_ch1_data = [];all_ttls = [];
%for each datafile
for i = 1:length(files)
    %initialise variable
    temp_ch = [];
    %load raw tarheel & TTLS
    [~, temp_ch0_fcv_data, temp_ch1_fcv_data] = tarheel_read([datapath files{i}],no_of_channels);
    [~, tempTTLs] = TTLsRead([datapath files{i} '.txt']);   
    
    all_ch0_data = [all_ch0_data, temp_ch0_fcv_data];
    if no_of_channels == 2
        all_ch1_data = [all_ch1_data, temp_ch1_fcv_data];
    end
    all_ttls = [all_ttls; double(tempTTLs)];   
end

TTLs = all_ttls; 
ch0_fcv_data = all_ch0_data;
ch1_fcv_data = all_ch1_data;

%create ts for whole session
ts = [0:0.1:size(all_ch0_data,2)/10-0.1]; 

                       
