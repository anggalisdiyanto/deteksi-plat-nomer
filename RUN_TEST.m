function Y=RUN_TEST()
%RUN_TEST Summary of this function goes here
%   Detailed explanation goes here

somefolder = 'images\';
filelist = dir(somefolder);
% //the first two in filelist are . and ..
for i=3:size(filelist,1)
    %// filelist is not a folder
    if filelist(i).isdir ~= true
        fname = filelist(i).name;
        %// if file extension is jpg
        if strcmp( fname(size(fname,2)-3:size(fname,2)) ,'.JPG'  ) == 1
            close all;
            main([somefolder fname]);            
        end
    end
end
