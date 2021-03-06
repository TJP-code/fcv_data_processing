%data structure for fcv data
% animal.
%           genotype
%           male/female
%           histology
%           session.
%                       
%                       raw_data.
%                                   ch1_data
%                                   ch0_data
%                                   TTLs
%                       target TTL. (eg large_reward)
%                                     params  
%                                     cut_points
%                                     bg_pos
%                                     channel.
%                                                 cut_data
%                                                 cut_TTLs
%                                                 chemometrics.
%                                       

% structure v2
%data structure for fcv data
% general params, i.e. bg 2 seconds prior to TTL event, time cut around event
%animal.
%           genotype
%           male/female
%           histology
%           session.
%                       
%                      target TTL. (eg large_reward)
%                                     param changes from default
%                                     channel.
%                                                 cut_TTLs
%                                                 chemometrics colour plot
%                                                 chemometrics IvsT
%                                                 residuals
%                                                 Q_vals
%                                                 ts!!!!  




%check filtering on chemometric plot
% plot for individual trials 1: colour plot, chemometric colorplot, c vs t (chemometric output),
% TTLS

%plot an average colourplot, average c vs t (smoothed), individual c vs t

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read tarheel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%use header info

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cv match
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fix peak shift - not hardcoded

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualise
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fix ttls

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% bg subtract
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%fix filename issue, shouldn't read a filename, thats what tarheel read is
%for



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run chemometrics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%make into function

%visualisation of individual and average trial data

%verbose mode with command line output

%data output: one version to paste into excel, one data structure 

% plot for individual trials 1: colour plot, chemometric colorplot, c vs t (chemometric output),
% TTLS
% CV - voltage (option to fold over)