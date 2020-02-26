function [fcv_header, ch0_fcv_data, ch1_fcv_data] = tarheel_read(filename,no_of_channels)

%function [fcv_header, ch1_fcv_data, ch0_fcv_data] = tarheel_read(filename,no_of_channels)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Reads tarheel fcv raw data into a matrix of 1000×samples for a 1 channel reacording
% two 500×samples for two channel recordings (default)
%
% no_of_channels - set to 1 or 2. With 1 channel all data is output in ch0_fcv_data
%
% TJP 20/3/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 2; no_of_channels = 2; end;

tarheel_scaling_constant = 0.0610;

fID = fopen(filename);
if fID < 1
    error('Could not read file, check filename')
end
raw_vec = fread(fID,Inf,'int16',0,'b');
fcv_vec = raw_vec*tarheel_scaling_constant;
fcv_header = fcv_vec(1:5000)/tarheel_scaling_constant;
fcv_vec(1:5000) = [];
samples = length(fcv_vec)/1000;

if no_of_channels == 2
    ch0_vec = fcv_vec(1:2:end,:);
    ch1_vec = fcv_vec(2:2:end,:);       
    ch0_fcv_data = vec2mat(ch0_vec',length(ch0_vec)/samples)'; 
    ch1_fcv_data = vec2mat(ch1_vec',length(ch1_vec)/samples)';
elseif no_of_channels    
    ch0_fcv_data =  vec2mat(fcv_vec',length(fcv_vec)/samples)';
    ch1_fcv_data = [];
end
fclose(fID);