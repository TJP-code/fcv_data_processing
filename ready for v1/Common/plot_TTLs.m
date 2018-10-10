function h = plot_TTLs(TTLs, ts, TTLnames)

%plot_TTLs plots TTL data
%
%function h = plot_TTLs(TTLs)
%
% Takes TTL data read from tarheel file using TTLsRead and plots.
%
% Inputs:
%   TTLs        - data read from tarheel .txt file using TTLsRead (1×n Cell array containing i x j (time×TTL number)matrices )
%   ts          - time stamps from tarheel .txt file using TTLsRead (1×n matrix)
%   TTLnames    - Cell array of TTL names (1×16) e.g.
%                 {'Reward', 'Head Entry', 'Head Exit', 'Left Lever Press', 'Left Lever Out', 'Right Lever Press', 'Right Lever Out',
%                 'Fan', '9', '10', '11', '12', '13', '14', '15', '16'}
%                 OR Default {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16'}
% Outputs:
%   h           - handle to figure
%
% Authors:
%   TJP & MP


if nargin < 2; ts = [0:0.1:(size(TTLs,1)/10)-0.1]; end;
if nargin < 3; TTLnames = []; end;

%Modify TTLs to allow for separate lines
TTLs_plot = TTLs * 0.5;
for i = 1:size(TTLs,2)
    TTLs_plot(:,i) = TTLs_plot(:,i) + i;
end

h = plot(ts,TTLs_plot);
title('TTLs');xlim([ts(1),max(ts)]);xlabel('Times(s)');
set(gca,'YTick',1:size(TTLs,2));

%Add custom specified labels for each TTL N.B. newer functions used in Matlab 2016a+
if ~isempty(TTLnames)
    set(gca,'yticklabel',TTLnames);
end
