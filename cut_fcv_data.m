function [cut_data, cut_points, cut_TTLs, cut_ts] = cut_fcv_data(fcv_data, TTL_data, ts, params)
%function [cut_data, cut_points, cut_TTLs, cut_ts] = cut_fcv_data(fcv_data, TTL_data, ts, params)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 1- write a help with examples
%
% 2 - window is a stupid name, should be time window or similar - Window
%
% The way the window works is that trials which contain other TTLs within a window around the
% target TTL are included(kept) or excluded(ignored?) i.e. lever press as
% target, trials that have a reward delivery within a window of 2 seconds before or 5 seconds after
%
%
% To-do fix issue of ignoring/excluding instances of the target ttl, i.e.
% isolate a lever press with no other lever presses within the time window (window)
%
% To-do: fix issue when data cut points exceed the duration of the recorded data. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%



%cut parameters

%If any buffers are used, all bits must have a corresponding window

% params.target_bit = 7; TTL to cut a trial around
% params.target_location = 0; %TTLs have a duration, they start when the TTL value goes up and end when it come back down, 
                              %for example a light coming on for 5 seconds. This parameter allows you to choose whether to cut at 
                              %TTL onset (target_location = 0), TTL termination (target_location = 1) or anywhere inbetween e.g. 0.5
                              %0 = start, 1 = end, 0.5 = middle %Rounds up to nearest scan
                              
% cut_params.include.bits = []; %TTLs that must also occur near target TTL
% cut_params.include.window = []; %time(s) around target TTL in which include bits must occur [s before target,time after target];
% cut_params.exclude.bits = []; %If these bits occur near target TTL, exclude this trial
% cut_params.exclude.window = []; %time window around target TTL to look for exclude TTL
% cut_params.ignore_repeats = []; %no of seconds to ignore repeats
% cut_params.sample_rate = 10;
% cut_params.time_align = [10 30]; %window size, [seconds before after]
% cut_params.bg_pos = -2; %seconds relative to target_location


%exclude cut files with more than x center bits???

%--calc cut location--
index = (TTL_data.start(:,2) == params.target_bit);
target_bit_start = TTL_data.start(index,1);
index = (TTL_data.end(:,2) == params.target_bit);
target_bit_end = TTL_data.end(index,1);

if params.target_location == 0
    cut_location = target_bit_start;
elseif params.target_location == 1   
    cut_location = target_bit_end+1;
else
    cut_location = target_bit_start+ceil((target_bit_end-target_bit_start)*params.target_location);
end

%ignore repeats
if ~isempty(params.ignore_repeats)
    k = 1;
    kmax = length(cut_location);
    while k <= kmax
        index = find((cut_location > (cut_location(k)) & (cut_location<cut_location(k)+(params.ignore_repeats*params.sample_rate))));
        cut_location(index) = [];   
        kmax = length(cut_location);
        k = k+1;
    end
end

%calc new data intervals/cut data
cut_points = [cut_location-params.time_align(1)*params.sample_rate,(cut_location-1)+params.time_align(2)*params.sample_rate];

index = find(cut_points(:,2) > size(fcv_data,2));
cut_points(index,2) = size(fcv_data,2);

if isempty(cut_points)
    error('ERROR: No cut points were found. No instance of target bit detected.')
end

time_align_win_length = (params.time_align(1)+params.time_align(2))*10;
s_fpadding = [];s_tpadding = []; s_ts_pad = [];
e_fpadding = [];e_tpadding = []; e_ts_pad = [];

%for each cut point
for i = 1:size(cut_points,1)
    
    %check if data will be less than window (i.e. the start or the end is
    
    actual_win_length = cut_points(i,2)-cut_points(i,1)+1;
    if actual_win_length<time_align_win_length
        s_fpadding = nan(size(fcv_data,1),time_align_win_length-actual_win_length);
        s_tpadding = nan(size(TTL_data.TTLs,2),time_align_win_length-actual_win_length);
        s_ts_pad = nan(1,time_align_win_length-actual_win_length);
    elseif actual_win_length<time_align_win_length
        e_fpadding = nan(size(fcv_data,1),time_align_win_length-actual_win_length);
        e_tpadding = nan(size(TTL_data.TTLs,2),time_align_win_length-actual_win_length);
        e_ts_pad = nan(1,time_align_win_length-actual_win_length);
    else
        s_fpadding = [];s_tpadding = []; s_ts_pad = [];
        e_fpadding = [];e_tpadding = []; e_ts_pad = [];
    end
    
    cut_data{i} = [s_fpadding,fcv_data(:,[cut_points(i,1):cut_points(i,2)]),e_fpadding];
    cut_TTLs{i} = [s_tpadding;TTL_data.TTLs([cut_points(i,1):cut_points(i,2)],:);e_tpadding'];
    cut_ts{i} = [s_ts_pad,ts([cut_points(i,1):cut_points(i,2)]),e_ts_pad];
      
end

rm_list = [];
for i = 1:length(cut_TTLs)
    
    %apply exclusion
    exclude_trial = ...
        include_exclude(params.exclude.window, params.sample_rate, cut_location(i), TTL_data.TTLs, cut_TTLs{i},params.exclude.bits);
    
    %inclusion
    include_trial = ...
        include_exclude(params.include.window, params.sample_rate, cut_location(i), TTL_data.TTLs, cut_TTLs{i},params.include.bits);
    
    %check for included TTLs    
    if exclude_trial == 1 || include_trial == 0
        rm_list = [rm_list,i];
    end
end

cut_data(rm_list) = [];
cut_TTLs(rm_list) = [];
cut_points(rm_list,:) = [];

if isempty(cut_points)
    error('ERROR: No cut points were found with these criteria. Please change criteria and try again.')
end
    


function [result] = include_exclude(window, sample_rate, cut_location, TTLs, cut_TTLs, ie_bits)

%extract segment using window
if ~isempty(window)
    %for each bit
    for j = 1:size(window,1)
        segment = [cut_location-window(j,1)*sample_rate,(cut_location-1)+window(j,2)*sample_rate];
        TTL_window = TTLs([segment(1):segment(2)],:);  
        result(j) = (sum(sum(TTL_window(:,ie_bits(j))))>0);
    end
    result = sum(result)>0;
else
    %no window
    TTL_window = cut_TTLs;
    if ~isempty(ie_bits)
        result = (sum(sum(TTL_window(:,ie_bits)))>0);
    else
        result = -1;
    end
end
        
       