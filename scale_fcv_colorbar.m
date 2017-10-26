function [vals] = scale_fcv_colorbar(data)

    high_val = max(data(:));
    low_val = min(data(:));
    
    down = floor(low_val) + floor( (low_val-floor(low_val))/0.25) * 0.25;
    
    up = floor(high_val) + ceil( (high_val-floor(high_val))/0.25) * 0.25;
    
    if up/down ~= -1.5
        up = down*-1.5;
    end
    
    vals = [down up];
end