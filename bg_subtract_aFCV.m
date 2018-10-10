
function processed_data = bg_subtract_aFCV(cut_data, params, bg_params)

%set bg
bg_pos = ones(length(cut_data),1);
bg_pos = bg_pos*((params.target_pos+params.bg_pos)*params.sample_rate);

%%bg subtract/plot
for i = 1:length(cut_data)
    bg_params.bg_pos  = bg_pos(i);
    [processed_data{i}] = process_raw_fcv_data(cut_data{i}, bg_params);

end