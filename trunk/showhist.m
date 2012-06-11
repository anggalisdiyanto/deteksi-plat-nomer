function [ output_args ] = showhist( i )
%SHOWHIST Summary of this function goes here
%   Detailed explanation goes here

  j = imread(i);
  figure;
  subplot(2,1,1);imshow(j);title('test aja');
  j = rgb2gray(j);
  [counts bins] = imhist(j);
  subplot(2,1,2);bar(bins,counts);

end
