
function [TTLs, ch0_fcv_data, ch1_fcv_data, ts] = read_whole_tarheel_session(datapath, no_of_channels)
% function [TTLs, ch0_fcv_data, ch1_fcv_data] = read_whole_tarheel_session(datapath, no_of_channels)
%
% TJP & MP 09/05/2017
% todo: write help
%
% no_of_channels - set to 1 or 2. With 1 channel all data is output in ch0_fcv_data
% 10/1/2018 - added ts for whole session
%
if nargin < 2; no_of_channels = 2; end


% % Code below replaced by getFCVfilepaths() function velow which also deals
% % with mac/apple hidden files
% filelist = dir(datapath);
% if (size(filelist) == [0 1])
%     error('Invalid path')
% end
% files = {filelist.name};
% isfolder = cell2mat({filelist.isdir});
% files(isfolder)=[];
% myindices = find(~cellfun(@isempty,strfind(files,'txt')));
% files([myindices])=[]; 

% Find filenames for all FCV files in folder [as specificed by 'datapath']
filepaths = getFCVfilepaths(datapath);
files = {filepaths.name};


all_ch0_data = []; all_ch1_data = [];all_ttls = [];
%for each datafile
for i = 1:length(files)
    %initialise variables
    temp_ch0_fcv_data = [];
    temp_ch1_fcv_data = [];
    tempTTLs = [];
    %load raw tarheel & TTLS
    [~, temp_ch0_fcv_data, temp_ch1_fcv_data] = tarheel_read([datapath files{i}],no_of_channels);
    [~, tempTTLs] = TTLsRead([datapath files{i} '.txt']);
    
    %If a file was stopped early in Tarheel then the length of the
    %extracted TTLs will match the intended recording length, whereas the
    %length fo the FCV data will match the actual recorded data length.
    %Check this, then fix the length of the TTLs and give the user a
    %warning message.
    if size(tempTTLs,1) > size(temp_ch0_fcv_data,2)
       tempTTLs = tempTTLs(1:size(temp_ch0_fcv_data,2),:);
       warning('Recording %s (file %i of %i) stopped earlier than intended recording length in Tarheel.',files{i}, i, length(files))
    end
    
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

                       
