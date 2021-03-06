function progressbar_v2(fractiondone, position, images,tasktxt)
% Description:
%   progressbar(fractiondone,position) provides an indication of the progress of
% some task using graphics and text. Calling progressbar repeatedly will update
% the figure and automatically estimate the amount of time remaining.
%   This implementation of progressbar is intended to be extremely simple to use
% while providing a high quality user experience.
%
% Features:
%   - Can add progressbar to existing m-files with a single line of code.
%   - The figure closes automatically when the task is complete.
%   - Only one progressbar can exist so old figures don't clutter the desktop.
%   - Remaining time estimate is accurate even if the figure gets closed.
%   - Minimal execution time. Won't slow down code.
%   - Random color and position options. When a programmer gets bored....
%
% Usage:
%   fractiondone specifies what fraction (0.0 - 1.0) of the task is complete.
% Typically, the figure will be updated according to that value. However, if
% fractiondone == 0.0, a new figure is created (an existing figure would be
% closed first). If fractiondone == 1.0, the progressbar figure will close.
%   position determines where the progressbar figure appears on screen. This
% argument only has an effect when a progress bar is first created or is reset
% by calling with fractiondone = 0. The progress bar's position can be specifed
% as follows:
%       [x, y]  - Position of lower left corner in normalized units (0.0 - 1.0)
%           0   - Centered (Default)
%           1   - Upper right
%           2   - Upper left
%           3   - Lower left
%           4   - Lower right
%           5   - Random [x, y] position
%   The color of the progressbar is choosen randomly when it is created or
% reset. Clicking inside the figure will cause a random color change.
%   For best results, call progressbar(0) (or just progressbar) before starting
% a task. This sets the proper starting time to calculate time remaining.
%
% Example Function Calls:
%   progressbar(fractiondone,position)
%   progressbar               % Initialize/reset
%   progressbar(0)            % Initialize/reset
%   progressbar(0,4)          % Initialize/reset and specify position
%   progressbar(0,[0.2 0.7])  % Initialize/reset and specify position
%   progressbar(0.5)          % Update
%   progressbar(1)            % Close
%
% Demo:
%   n = 1000;
%   progressbar % Create figure and set starting time
%   for i = 1:n
%       pause(0.01) % Do something important
%       progressbar(i/n) % Update figure
%   end
%
% Author: Steve Hoelzer
%
% Revisions:
% 2002-Feb-27   Created function
% 2002-Mar-19   Updated title text order
% 2002-Apr-11   Use floor instead of round for percentdone
% 2002-Jun-06   Updated for speed using patch (Thanks to waitbar.m)
% 2002-Jun-19   Choose random patch color when a new figure is created
% 2002-Jun-24   Click on bar or axes to choose new random color
% 2002-Jun-27   Calc time left, reset progress bar when fractiondone == 0
% 2002-Jun-28   Remove extraText var, add position var
% 2002-Jul-18   fractiondone input is optional
% 2002-Jul-19   Allow position to specify screen coordinates
% 2002-Jul-22   Clear vars used in color change callback routine
% 2002-Jul-29   Position input is always specified in pixels
% 2002-Sep-09   Change order of title bar text
% 2003-Jun-13   Change 'min' to 'm' because of built in function 'min'
% 2003-Sep-08   Use callback for changing color instead of string
% 2003-Sep-10   Use persistent vars for speed, modify titlebarstr
% 2003-Sep-25   Correct titlebarstr for 0% case
% 2003-Nov-25   Clear all persistent vars when percentdone = 100
% 2004-Jan-22   Cleaner reset process, don't create figure if percentdone = 100
% 2004-Jan-27   Handle incorrect position input
% 2004-Feb-16   Minimum time interval between updates
% 2004-Apr-01   Cleaner process of enforcing minimum time interval
% 2004-Oct-08   Seperate function for timeleftstr, expand to include days
% 2004-Oct-20   Efficient if-else structure for sec2timestr
%

persistent progfig progpatch starttime lastupdate

% Set defaults for variables not passed in
if nargin < 1
    fractiondone = 0;
end
if nargin < 2
    position = 0;
end

try
    % Access progfig to see if it exists ('try' will fail if it doesn't)
    dummy = get(progfig,'UserData');
    % If progress bar needs to be reset, close figure and set handle to empty
    if fractiondone == 0
        delete(progfig) % Close progress bar
        progfig = []; % Set to empty so a new progress bar is created
    end
catch
    progfig = []; % Set to empty so a new progress bar is created
end

% If task completed, close figure and clear vars, then exit
percentdone = floor(100*fractiondone);
if percentdone == 100 % Task completed
    delete(progfig) % Close progress bar
    clear progfig progpatch starttime lastupdate % Clear persistent vars
    return
end

%select image
%images = {'progressbar1.jpg','progressbar2.jpg','progressbar3.jpg','progressbar4.jpg','progressbar5.jpg','progressbar6.jpg'};    
r = randi(10,1,1); 
if r == 1
    selected = randi(length(images),1,1);
else
    selected = 1;
end

% Create new progress bar if needed
if isempty(progfig)
    
    % Calculate position of progress bar in normalized units
    img=1;
    if img
        R=imread(images{selected});
        imgwidth = size(R,1);
        imgheight = size(R,2);
    end
    
        scrsz = [0 0 1 1];
        
        oldwidth = scrsz(3)/5;
        oldheight = scrsz(4)/6;
%TJP EDIT
        screen_w = 1200;
        screen_h = 1920;
        
        width = imgwidth/screen_w; %0.5 = 1200*0.5=600      
        height = imgheight/screen_h; %0.5 = 1920
    if (length(position) == 1)
        hpad = scrsz(3)/64; % Padding from left or right edge of screen
        vpad = scrsz(4)/24; % Padding from top or bottom edge of screen
        left   = scrsz(3)/2 - width/2; % Default
        bottom = scrsz(4)/2 - height/2; % Default
        switch position
            case 0 % Center
                % Do nothing (default)
            case 1 % Top-right
                left   = scrsz(3) - width  - hpad;
                bottom = scrsz(4) - height - vpad;
            case 2 % Top-left
                left   = hpad;
                bottom = scrsz(4) - height - vpad;
            case 3 % Bottom-left
                left   = hpad;
                bottom = vpad;
            case 4 % Bottom-right
                left   = scrsz(3) - width  - hpad;
                bottom = vpad;
            case 5 % Random
                left   = rand * (scrsz(3)-width);
                bottom = rand * (scrsz(4)-height);
            otherwise
                warning('position must be (0-5). Reset to 0.')
        end
        %TJP edit
        position = [left bottom];
%         position = [500 200];
    elseif length(position) == 2
        % Error checking on position
        if (position(1) < 0) | (scrsz(3)-width < position(1))
            position(1) = max(min(position(1),scrsz(3)-width),0);
            warning('Horizontal position adjusted to fit on screen.')
        end
        if (position(2) < 0) | (scrsz(4)-height < position(2))
            position(2) = max(min(position(2),scrsz(4)-height),0);
            warning('Vertical position adjusted to fit on screen.')
        end
    else
        error('position is not formatted correctly')
    end
    
    % Initialize progress bar 
            
    progfig = figure(...
        'NumberTitle',      'off',...
        'Resize',           'off',...
        'MenuBar',          'none',...
        'BackingStore',     'off' );
    
    imshow(R)

    h = gca;
    set(h,'Visible','off');
    progpatch=patch( 'XData' ,[ 0 size(R,2) size(R,2) 0 ],...
               'YData' ,[ 0 0 size(R,1) size(R,1)],...%'erasemode','normal',...
               'facecolor',[0 0 0],...
               'EdgeColor',[0 0 0],...
               'Userdata',R );
    
  
    set(progfig,  'ButtonDownFcn',{@changecolor,progpatch});
%    set(progaxes, 'ButtonDownFcn',{@changecolor,progpatch});
    set(progpatch,'ButtonDownFcn',{@changecolor,progpatch});
    changecolor(0,0,progpatch)
    
    % Set time of last update to ensure a redraw
    lastupdate = clock - 1;
    
    % Task starting time reference
    if isempty(starttime) | (fractiondone == 0)
        starttime = clock;
    end
    
end

% Enforce a minimum time interval between updates
if etime(clock,lastupdate) < 0.01
    return
end

% Update progress patch
R=get(progpatch,'userdata');
set(progpatch,'XData',[size(R,2) fractiondone*size(R,2) fractiondone*size(R,2) size(R,2)])


% Update progress figure title bar
if (fractiondone == 0)
    titlebarstr = '0% complete';
else
    runtime = etime(clock,starttime);
    timeleft = runtime/fractiondone - runtime;
    timeleftstr = sec2timestr(timeleft);
    titlebarstr = sprintf('%s ~%2d%%    %s remaining',tasktxt,percentdone,timeleftstr);
end
set(progfig,'Name',titlebarstr)

% Force redraw to show changes
drawnow

% Record time of this update
lastupdate = clock;


% ------------------------------------------------------------------------------
function changecolor(h,e,progpatch)
% Change the color of the progress bar patch

colorlim = 2.8; % Must be <= 3.0 - This keeps the color from being too light
thiscolor = rand(1,3);
while sum(thiscolor) > colorlim
    thiscolor = rand(1,3);
end
set(progpatch,'FaceColor',[1 1 1 ]);
set(progpatch,'EdgeColor',[1 1 1 ]);

% ------------------------------------------------------------------------------
function timestr = sec2timestr(sec)
% Convert a time measurement from seconds into a human readable string.

% Convert seconds to other units
d = floor(sec/86400); % Days
sec = sec - d*86400;
h = floor(sec/3600); % Hours
sec = sec - h*3600;
m = floor(sec/60); % Minutes
sec = sec - m*60;
s = floor(sec); % Seconds

% Create time string
if d > 0
    if d > 9
        timestr = sprintf('%d day',d);
    else
        timestr = sprintf('%d day, %d hr',d,h);
    end
elseif h > 0
    if h > 9
        timestr = sprintf('%d hr',h);
    else
        timestr = sprintf('%d hr, %d min',h,m);
    end
elseif m > 0
    if m > 9
        timestr = sprintf('%d min',m);
    else
        timestr = sprintf('%d min, %d sec',m,s);
    end
else
    timestr = sprintf('%d sec',s);
end
