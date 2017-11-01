

function  voltages = voltagesweep(no_of_channels, waveform_start, waveform_peak)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Function to generate list of volatges for the triangular waveform during FCV [Tarheel]
% This function will become redundant when Tarheel header data is accessible
%inputs:    num_channels -  Specify the number of channels used during recording [usually 1,2]
%           waveform_start - starting voltage of the waveform [if no input, default to -0.4]
%           waveform_peak - peak voltage of the waveform [if no input, default to +1.3]
%
%outputs:   voltages - list of voltages for the specified triangular waveform 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%check inputs
if nargin < 1; error('Error: Specify number of channels'); end;
if nargin < 2; waveform_start = -.4; waveform_peak = 1.3;; end;

%Calculate 
num_points = 1000/no_of_channels;
start = -.4;
peak = 1.3;
peak - start;
abs_voltage = 2*(peak - start);
volt_per_scan = abs_voltage/num_points;
waveform_voltages_up = [start:volt_per_scan:peak];
waveform_voltages_down = [peak-volt_per_scan:-volt_per_scan:start];
waveform_voltages = [waveform_voltages_up waveform_voltages_down];

%output - column of voltages
voltages = waveform_voltages(2:size(waveform_voltages,2));
