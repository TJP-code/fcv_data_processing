function h = plot_TTLs(TTLs, ts, TTLnames)
%function h = plot_TTLs(TTLs)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   plot_TTLs
%
%   Takes TTL data read from tarheel file using TTLsRead and plots.
%
%   inputs:
%           TTLs - data read from tarheel .txt file using TTLsRead (1 x n Cell array containing i x j (time x TTL number)matrices )
%           ts   - time stamps from tarheel .txt file using TTLsRead (1 x n matrix)
%           TTLnames - Cell array of TTL names (1 x 16) e.g.
%           {'Reward', 'Head Entry', 'Head Exit', 'Left Lever Press', 'Left Lever Out', 'Right Lever Press', 'Right Lever Out', 'Fan', '9', '10', '11', '12', '13', '14', '15', '16'}
%           OR
%   Default {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16'}
%   output:
%           h = handle to figure
%
%
%   future feature:
%                   extra parameter to describe TTL channels
%                   customise title?
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 3; TTLnames = []; end;

%Modify TTLs to allow for separate lines
TTLs_plot = TTLs * 0.5;
for i = 1:size(TTLs,2)
    TTLs_plot(:,i) = TTLs_plot(:,i) + i;
end

plot(ts,TTLs_plot)
title('TTLs');xlim([ts(1),max(ts)]);xlabel('Times(s)');
set(gca,'YTick',1:size(TTLs,2));

%Add custom specified labels for each TTL N.B. newer functions used in Matlab 2016a+
if ~isempty(TTLnames)
    set(gca,'yticklabel',TTLnames);
end
