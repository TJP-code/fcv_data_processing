function [splitName] = filenameSplitter(text,delimiter,target,remove)
%FIlename splitter
%

%Split filename into a cellarray based on specified delimiter 
list = strsplit(text, delimiter);
%find index of of cell array containing target
index = find(~cellfun(@isempty,strfind(list, target)));

if remove
    %output
    %splitName = strrep(char(list(index)),target, []);
    splitName =regexprep(char(list(index)),target, '');
else
    %output
    splitName = char(list(index));
end 