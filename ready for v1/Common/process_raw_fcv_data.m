function [processed_data] = process_raw_fcv_data(filename,params)

%Applies common Tarheel CV Analysis filters to raw FCV data
%
%[filtered_data] = filter_raw_fcv_data(filename,params)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                               
%   Takes a raw tarheel to text file containing FCV data and mimics processing by tarheel.       
%   Applies background subtract, butterworth filtering and a smoothing kernel.                      
%   Butterworth filter is a Low Pass filter standardly employed in Tarheel 4kHZ is used             
%   for 2 channel recordings, 2 kHz for 1 channel recordings.                                       
%                                                                                                   
% --inputs--                                                                                                
%   raw_data             - raw data file loaded in via tarheel_read(), OR full path and file      
%                          for file output by tarheel-to-text software. Data format m x n matrix.                                                                                     
%                          Data must be waveform×samples e.g. 500 point waveform×1200 samples   
%   params.                                                                                         
%            bg_size     - background subtraction - default is to average across 10 scans.          
%            bg_pos      - position in file to apply background subtraction -                       
%                          default to 15 scans from from start of file.                                                  
%            order       - Butterworth filter param, default 4                                      
%            filt_freq   - filter low pass frequency(Hz), 4000 for 2 channel recording 2000 for     
%                          1 channel, default is 4000                                                  
%            sample_freq - data sample frequency during application of fcv waveform                 
%                          default 58820 for a 500 point file, 117640 for 1000 point file.                                                        
%                                                                                                   
% --outputs--                                                                                       
%   processed_data       - background subtracted, filtered and smoothed data                        
%             
%   Example: 
%       1) Setup parameters as a data structure
%
%           bg_params.bg_size       = 10;
%           bg_params.bg_pos        = 15;
%           bg_params.order         = 4;
%           bg_params.filt_freq     = 2000; 
%           bg_params.sample_freq   = 58820;
%
%       2) Use a matrix of data or identify a filepath to raw FCV data from tarheel
%           filename =
%           'C:\Users\...\fcv_data_processing\test data\46_20170208_02 - Variable reward post\46_148';
%
%    [processed_data] = process_raw_fcv_data(filename,bg_params)
%
%
%            TJP & MP 21/02/2017                                                                    
%                                                                                                   
%            Last edit: Calcuation of sample_freq if not specified, this uses                       
%                       hardcoded parameters for the moment                                         
%                                                                                                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      

%check params
if nargin < 1; error('Need filename'); end;
if nargin < 2; params = []; end;
if ~isfield(params,'bg_size') || isempty(params.bg_size)
    params.bg_size = 10;
end
if ~isfield(params,'bg_pos') || isempty(params.bg_size)
    params.bg_pos = 15;
end
if ~isfield(params,'order') || isempty(params.bg_size)
    params.order = 4;
end
if ~isfield(params,'filt_freq') || isempty(params.bg_size)
    params.filt_freq = 4000;
end


%Load in data
if isa(filename,'char')
    try
        read_data = dlmread(filename)';
        raw_data = read_data;
    catch
        error('Could not read file, check filename')
    end
else 
    raw_data = filename;
end

%calc sample_freq from data
if ~isfield(params,'sample_freq') || isempty(params.bg_size)
    params.sample_freq = size(raw_data,1)/ ((2 *(1.3-(-0.4))/400));
    fprintf('------sample frequence calculated as %dHz --------\n',params.sample_freq);
end


%Background subtraction
background = mean(raw_data(:,params.bg_pos:params.bg_pos+params.bg_size),2);

for i = 1:size(raw_data,2)
    background_sub(:,i) = raw_data(:,i) - background;
end

%Low pass filter data with butterworth filter
[b,a] = butter(params.order,params.filt_freq/(params.sample_freq/2));

for i = 1:size(background_sub,2)
    data_filt_columns(:,i) = filter(b,a,background_sub(:,i));
end

processed_data = data_filt_columns;
