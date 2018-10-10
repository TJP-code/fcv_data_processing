function [output] = groupstats(grouping, outcome, fun)
%Apply a function to data in a grouping - [input data as columns]
%
%inputs: grouping - a variable that defines the grouping [column data only]
%        outcome - the outcome variable corresponding to the grouping [column data only]
%        fun - the function to be applied to the outcome e.g. @mean or @sum
%        etc...
%   For example, groupstats(Groups, Scores, @mean) returns the mean of scores for each group.
%outputs: an nx2 matrix where n is the unique categories in the grouping
%         variable. column 1 contains grouping variable, column 2 contains the
%         processed outcome variable

[ud,ix,iy] = unique(grouping);
output = [ud, accumarray(iy,outcome,[],fun)];