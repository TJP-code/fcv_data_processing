function [bout] = TTL_BoutAnalysis(data, target_TTL, end_TTL, reward_TTL)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[bout] = TTL_BoutAnalysis(data, target_TTL, end_TTL, reward_TTL)
%
%   Bout analysis function to analyse timestamp events. Analyses timestamped data to extract repeated
%   bouts of a behaviour that end when another action is performed e.g. multiple lever presses that occur before a magazine checking behaviour. 
%
%Inputs:
%       data - nx2 matrix containing event TTLs (col 1) and their timestamps (col 2)
%       target_TTL - target event TTL to characterise repeated bouts (e.g. Lever presses)
%       end_TTL - TTL event that indicates that a bout has ended (e.g. a magazine entry)
%       reward_TTL - TTL event indiacting reward delivery to tag whetehr a reward was delivered during the course of the bout
%
%Outputs: Data structure
%   bout.
%       .StartEndTimes - nx2 matrix containing start (col 1) and and end (col 2)timestamps for each bout (rows)
%       .boutData - cell array containing the event TTLs and timestamps involved in each bout
%       .size - number of target TTLs involved in each bout
%       .rewarded - indicates whether a reward TTL is present during the bout [0,1]
%
%   Marios Panayi - 06/02/2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%Initialise vars
bout_Start = 0;
bout_Num = 0;
bout.StartEndTimes = []; % 2 columns[bout start time, bout end time]

%make sure data is sorted in chronological order
data = sortrows(data,2);

%%
%Find bout start/end times
for i = 1:size(data,1)
    %If a bout is underway, end if a magEntry/Exit occurs
    if bout_Start
        if data(i,1) == end_TTL
            bout_Start = 0;
            bout.StartEndTimes(bout_Num, 2) = data(i, 2);
        end
        
    elseif data(i,1) == target_TTL && ~bout_Start
        bout_Start = 1;
        bout_Num = bout_Num+1;
        bout.StartEndTimes(bout_Num, 1) = data(i, 2);
    end
    %End bout if session is over
    if i == size(data,1)
        bout.StartEndTimes(bout_Num, 2) = data(i, 2);
    end
end

%%
%Extract bout data based on start/end times
for i = 1:size(bout.StartEndTimes,1)
    index = find(data(:,2)>= bout.StartEndTimes(i,1) & data(:,2)<= bout.StartEndTimes(i,2));
    bout.boutData{i} = data(index,:);
    bout.size(i) = sum(data(index,1) == target_TTL);
    bout.rewarded(i) = sum(data(index,1) == reward_TTL);
end

