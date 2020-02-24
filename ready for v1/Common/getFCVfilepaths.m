function [filepaths] = getFCVfilepaths(dirpath)
% Author: Marios Panayi
% Date: 24/02/2020
% Created to deal with apple/mac nonsense!
%
% [filepaths] = getFCVfilepaths(dirpath) Return directory results for all
% FCV files in a folder. Note that this deals with the issue of Apple/Mac OS
% creating hidden files beginning with '._'
%   Input: 
%       dirpath - string containing the filepath/directory of folder you want to look in for
%   all your FCV files
%   
%   Output: 
%       filepaths - struct containing file details for all files in the
%       speciufied folder. This is identical to the dir() command except
%       that all folders, and files containing '._' have been removed 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% get all folder and fils in directory path (dirpath)
folderdirectory = dir(dirpath);

% Check to make sure directory path is valid
if (size(folderdirectory) == [0 1])
    error('Invalid path')
end

% Remove all folders and leave only files
filepaths = folderdirectory(~[folderdirectory.isdir]);
% Remove mac hidden files, these start with '._' . N.B. You should not have '._' in any other legitimate part of your filenames when naming files!
% Regexp is used here to find these files, so any instance of '._' ina
% filename will be removed. 
filepaths_name = {filepaths.name};
fileindices = cellfun(@isempty,regexp(filepaths_name,'\._'));
filepaths = filepaths(fileindices);

% Remove all .txt files that accompany tarheel FCV files
filepaths_name = {filepaths.name};
myindices = find(cellfun(@isempty,strfind(filepaths_name,'txt')));
filepaths = filepaths(myindices);
end




