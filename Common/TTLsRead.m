function [ts,TTLs] = TTLsRead(fileName)

% Written by ASH
% 12/2008
% Last Modified by ASH
% 12/8/08 (added annotation)

% Used by getSessionTTLs

% Gets the TTL data from a single data file.  Converts the data from two...
% columns of 8 bit integers to a 16 column matrix.  Also, bits are flipped
% from the MED output of on till turned off to off till turned on.  Device
% 2 becomes columns 1 thru 8.  Device 1 becomes columns 9 thru 16.  This
% matches the bit nums from MED-PC programs.

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

