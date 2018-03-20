function [index] = cellfind(target, data)
%function returns the index of a target string in a cell array
%Output: index - the index in the cell array containing the target
%Input: target  - string containing target text
%       data - cell array containing strings to be searched must be in a
%       cell array, if calling from a a data structure put it in curly
%       braces to make it into a cellarray! e.g. cellfind('GLRA64.1c',{data.subject})

answer = cellfun(@(x) strfind(x,target), data,  'UniformOutput', false );
index = find(~cellfun(@isempty, answer));
