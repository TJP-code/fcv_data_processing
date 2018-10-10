%function_name one line description
%
%[output] = function_name(inputparams)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                               
%   Example description paragraph                                                               
%   Takes a raw tarheel to text file containing FCV data and mimics processing by tarheel.       
%   Applies background subtract, butterworth filtering and a smoothing kernal.                      
%   Butterworth filter is a Low Pass filter standardly employed in Tarheel 4kHZ is used             
%   for 2 channel recordings, 2 kHz for 1 channel recordings.                                       
%                                                                                                   
% Inputs:                                                                                     
%   variable_name        - description (format)
%   raw_data             - raw data file loaded in via tarheel_read(), OR full path and file      
%                          for file output by tarheel-to-text software                                                                                     
%                          Data must be waveform×samples e.g. 500 point waveform×1200 samples   
%   params.                                                                                         
%            bg_size     - background subtraction - default is to average across 10 scans.          
%            bg_pos      - position in file to apply background subtraction -                       
%                          default to 15 scans in.                                                  
%            order       - butterworth filter param, default 4                                      
%            filt_freq   - filter low pass frequency(Hz), 4000 for 2 channel recording 2000 for     
%                          1 channel, default 4000                                                  
%            sample_freq - data sample frequency during application of fcv waveform                 
%                          default 58820 for a 500 point file, 117640 for 1000 point file           
%            point_avg   - number of points for kernal average default 8 - currently disabled       
%                          as of 10/05/2017 TJP                                                     
%                                                                                                   
% Outputs:                                                                                       
%   processed_data       - background subtracted, filtered and smoothed data                     
%                           ([n×m] matrix, m = number of scans, n = points in waveform)             
%                                                                                                   
%                             
% Examples:              (if an example is required/helpful)
%   [output] = function_name(inputparams)
%               

% Author(s):
%    TJP & MP 21/02/2017                                                                    
%                                                                                                       
%                                                                                                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   