function interp_data = interpolate_vector(data, interp_index)
% interp_data = interpolate_vector(data, interp_index)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Write the help lad
%
% interp_index:     values that aren't nan 
%                   e.g. interp_index = isnan(fcv_IT);
%                   interp_data = interpolate_vector(fcv_IT, ~interp_index);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

query = [1:1:length(data)];
sample = query(interp_index);
values = data(interp_index);

%run interp
interp_data = interp1(sample, values, query);