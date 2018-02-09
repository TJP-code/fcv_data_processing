function interp_data = interpolate_vector(data, interp_index)
% interp_data = interpolate_vector(data, interp_index)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Write the help lad
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

query = [1:1:length(data)];
sample = query(interp_index);
values = data(interp_index);

%run interp
interp_data = interp1(sample, values, query);