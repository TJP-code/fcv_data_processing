function [ts,TTLs] = TTLsRead(fileName)

%Extract TTL data from Tarheel data files
%
%[ts,TTLs] = TTLsRead(fileName)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                                                                                                              
%   Extracts TTL values from Tarheel data files. Tarheel Saves FCV data 
%   separately from the accompanying TTLs. TTLs are saved witha  '.txt' 
%   extension. Converts the data from two columns of 8 bit integers into a
%   16 column martix (with a row corresponding to each scan number). 
%   Note that bits are flipped from the MED Output "of on till turned off
%   to off till turned on.", i.e. original TTL takes a value of 1 when OFF
%   and a value of 0 when ON, this is flipped so that a TTL [1 = ON, 0 =
%   OFF]. 
%   Device 2 becomes columns 1-8, and device 1 becomes columns 9-16. THis
%   matches the bit numbers from MED-PC programs.
%
%   function [ts,TTLs] = TTLsRead(fileName)
%                                                                                                   
% Inputs:                                                                                     
%   fileName    - filepath to Tarheel generated .txt file containing TTL data. Type = string.  
%                                                                                                        
% Outputs:                                                                                      
%   ts          - Time Stamps: time (in seconds) of the recording (corresponds to scan number).
%                   [m x 1] vector where m = number of scans. Type = double.
%   TTLs        - TTLs [off,on] coded as [0,1].
%                   [m x 16] matrix where rows m = number of scans (i.e. time points), cols = TTL number 1-16. Type = double.                                                
%                                            
% Author(s):
% Written by ASH 12/2008
% Modified by TJP & MP 21/02/2017                                                                                                   
%                                                                                                   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   




% Deconvolve TTL's

% Import Data

ttls = (importdata(fileName));
ts = ttls(:,1);%tjp edit 18/10/2016
ttls = uint8(ttls(:,2:3));

% Reverse Nums

ttls=255 - ttls;
ttlscopy = ttls;
% Break Out into logicals
logicals = uint8(zeros(length(ttls), 16));

for i = 1:length(ttls)
    
    for j = 1:16
        k = 1 + (j<9);
        logicals(i,j) = mod(ttlscopy(i,k),2); % get 0 or 1
        ttlscopy(i,k) = idivide(ttlscopy(i,k), 2, 'floor'); 
        % chop off the rest
    end
end

TTLs = double(logicals); %TJP edit 08/02/2018

