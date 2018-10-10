function [TTL_start, TTL_end] = extract_TTL_times(TTLs)

% function [TTL_start, TTL_end] = extract_TTL_times(TTLs)
%
% Takes TTL file containing n×m matrix scan point by TTL bit number and
% outputs start and end scan numbers of TTL pulses.
%
% input: TTLs - TTL data
%
% output: TTL_start - n×2 matrix containing start scans of TTL data in format [scan number, TTL bit]
%         TTL_end   - n×2 matrix containing end  scans of TTL data in format [scan number, TTL bit]
%
% TJP & MP 09/05/2017
%
%

start_zero = zeros(1,size(TTLs,2));
TTL_shifted = [start_zero ;[TTLs(1:(length(TTLs)-1),:)]];
TTL_diff = TTLs-TTL_shifted;

%for TTL bits extract start and end
[TTL_start(:,1), TTL_start(:,2),~]  = find(TTL_diff == 1);
[TTL_end(:,1), TTL_end(:,2),~] = find(TTL_diff == -1);

%correcting for shift
TTL_end(:,1) = TTL_end(:,1)-1;