% 1.input image 
% 2.preparing 
%   2.a convert to grayscale 
%   2.b invert color (because i only have black on white templates)
%   2.c detect and cropping license plat number
%       * horizontal edge processing
%       * vertical edge processing
%       * segmentation
%       * region of interest extraction
%       * output image
%   2.d convert to binary
%   2.e Remove all object containing fewer than 70 pixels
%   2.f apply imrode
%   2.g Perform 2-D median filtering

warning off

% just clearing all stufft
clc;
close all;
clear;

% (1).open file dialog
[baseFileName, folder] = uigetfile('*.jpg','Pilih file image');
fullImageFileName = fullfile(folder,baseFileName);
img = imread(fullImageFileName);
figure,imshow(img);title('base image'); %fig.1

%% --------------> PREPARING IMAGE

%(2.a).convert to grayscale
if size(img,3)==3
	img = rgb2gray(img); %RGB image
end
figure,imshow(img);title('grayscale'); %fig.2

%(2.b) clean from noise
img = medfilt2(img);
[f c]=size(img);
img (1,1)=255;
img (f,1)=255;
img (1,c)=255;
img (f,c)=255;
figure,imshow(img);title('remove noise');

% (2.c).invert color
img = imcomplement(img);
figure,imshow(img);title('invert color'); 

%% (2.d).car license plate detection
img = detectplatnumber(img);

% (2.d).grayscale to binary
threshold = graythresh(img);
imagen = im2bw(img,threshold);

% (2.f) apply imrode
SE = strel('line',2,90);
imagen = imerode(imagen,SE);
figure,imshow(imagen);title('apply imerode');

imagen = ~imagen;

% (2.e) Remove all object containing fewer than 35 pixels
imagen = bwareaopen(imagen,50);
%imagen = ~imagen;
imagen = imcomplement(imagen);
figure,imshow(imagen);title('Remove all object containing fewer than 50 pixels');


%%----------------> END PREPARING IMAGE

word=[];%Storage matrix word from image
re=imagen;
fid = fopen('log.txt', 'at');%Opens a text for append in order to store the number plates for log.
while 1
    [fl re]=lines(re);%Fcn 'lines' separate lines in text
    imgn=~fl;
    %*-*Uncomment line below to see lines one by one*-*-*-*
    % figure,imshow(fl);pause(1)
    %*-*--*-*-*-*-*-*-
    %*-*-*-*-*-Calculating connected components*-*-*-*-*-
    L = bwlabel(imgn);
    mx=max(max(L));
    
    % (3). apply sobel
    BW = edge(double(imgn),'sobel');
    figure,imshow(BW);title('apply sobel');
    
    [imx,imy]=size(BW);
    for n=1:mx
        [r,c] = find(L==n);
        rc = [r c];
        [sx sy]=size(rc);
        n1=zeros(imx,imy);
        for i=1:sx
            x1=rc(i,1);
            y1=rc(i,2);
            n1(x1,y1)=255;
        end
        %*-*-*-*-*-END Calculating connected components*-*-*-*-*
        n1=~n1;
        n1=~clip(n1);
        
        SE = strel('line',3,90);
        n1 = imdilate(n1,SE);
        
        % resize clip
        img_r=same_dim(n1);%Transf. to size 42 X 24
        %*-*Uncomment line below to see letters one by one*-*-*-*
        % figure,imshow(img_r);pause(1)
        %*-*-*-*-*-*-*-*
		% read letter
        letter=read_letter(img_r);%img to text
        word=[word letter];
    end
    %fprintf(fid,'%s\n',lower(word));%Write 'word' in text file (lower)
    fprintf(fid,'Number Plate:-%s\nDate:-%s\n',word,date);%Write 'word' in text file (upper)
    fprintf(fid,'------------------------------------\n');
    msgbox(sprintf('Number Plate Extraction successful.\nExtracted Number plate:- %s .\nSee the log.txt file to see the stored number.',word),'Extraction Success');
    word=[];%Clear 'word' variable
    %*-*-*When the sentences finish, breaks the loop*-*-*-*
    if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end
    %*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
end
fclose(fid);

