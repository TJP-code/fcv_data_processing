function [TTL_start, TTL_end] = extract_TTL_times(TTLs)

% extract_TTL_time Extract times when TTLs are on and off
%
% function [TTL_start, TTL_end] = extract_TTL_times(TTLs)
%
% Takes TTL file containing n×m matrix sample by TTL bit number and
% outputs start and end samples numbers of TTL pulses.
% Sample number correspond to fcv scan number.
%
% Inputs:
%       TTLs        - TTL data (n×m matrix, number of samples×number of TTL channels)
%
% Outputs: 
%       TTL_start   - n×2 matrix containing start samples of TTL data in format [sample number, TTL bit]
%       TTL_end     - n×2 matrix containing end  samples of TTL data in format [sample number, TTL bit]
%
% Authors: 
%       TJP & MP 09/05/2017

start_zero = zeros(1,size(TTLs,2));
TTL_shifted = [start_zero ;[TTLs(1:(length(TTLs)-1),:)]];
TTL_diff = TTLs-TTL_shifted;

%for TTL bits extract start and end
[TTL_start(:,1), TTL_start(:,2),~]  = find(TTL_diff == 1);
[TTL_end(:,1), TTL_end(:,2),~] = find(TTL_diff == -1);

%correcting for shift
TTL_end(:,1) = TTL_end(:,1)-1;