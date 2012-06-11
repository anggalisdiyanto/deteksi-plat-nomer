function [ output_args ] = RUN_TEST_SHOW_HIST(  )
%UNTITLED1 Summary of this function goes here
%   Detailed explanation goes here
somefolder = 'E:\deteksi plat nomer dengan metode sobel\Matlab\Number Plate Extraction using MATLAB\code\';
filelist = dir(somefolder);
% //the first two in filelist are . and ..
for i=3:size(filelist,1)
    %// filelist is not a folder
    if filelist(i).isdir ~= true
        fname = filelist(i).name;
        %// if file extension is jpg
        if strcmp( fname(size(fname,2)-3:size(fname,2)) ,'.JPG'  ) == 1
            %close all;
            %main([somefolder fname]);   
            showhist([somefolder fname]);            
            pause(2);
        end
    end
end

