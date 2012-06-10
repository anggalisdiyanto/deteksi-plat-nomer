function Y = main(x)
warning off

if isempty(x)
    x = 'N';
end

if strcmp(x,'N') == 1
    % open file dialog
    [baseFileName, folder] = uigetfile('*.jpg','Pilih file image');
    fullImageFileName = fullfile(folder,baseFileName);
else
    fullImageFileName = x;
end

img = imread(fullImageFileName);
figure,imshow(img);title('base image'); %fig.1

%% --------------> PREPARING IMAGE

%.convert to grayscale
if size(img,3)==3
	img = rgb2gray(img); %RGB image
end
figure,imshow(img);title('grayscale'); %fig.2

% clean from noise
img = medfilt2(img);
[f c]=size(img);
img (1,1)=255;
img (f,1)=255;
img (1,c)=255;
img (f,c)=255;
figure,imshow(img);title('remove noise');

%[R C] = size(img);
%for i = 1:R
%    for j = 1:C
%        if img(i,j) <= (255 / 2)
%            img(i,j) = 0;
%        else
%            img(i,j) = img(i,j);
%        end
%    end
%end

%clean again
%img = medfilt2(img);
%figure,imshow(img);title('filtering + median filter');

% invert color
img = imcomplement(img);
figure,imshow(img);title('invert color'); 

%% START Car License Plate Detection
img = detectplatnumber(img);
%% END


% grayscale to binary
threshold = graythresh(img);
img = im2bw(img,threshold);

% apply imrode (http://www.mathworks.com/help/toolbox/images/ref/imerode.html)
SE = strel('line',2,45);
img = imerode(img,SE);
figure,imshow(img);title('apply imerode');
 

%% ----------------> END PREPARING IMAGE

%% OCR (Ing.Diego Barragán Guerrero - www.matpic.com)
word=[];%Storage matrix word from image 
re=img;
fid = fopen('log.txt', 'at');%Opens a text for append in order to store the number plates for log.
while 1
    [fl re]=lines(re);%Fcn 'lines' separate lines in text
    imgn=~fl;
    %*-*Uncomment line below to see lines one by one*-*-*-*
    % figure,imshow(fl);pause(1)
    %*-*--*-*-*-*-*-*-

    % Remove all object containing fewer than 70 pixels
    imgn = bwareaopen(imgn,70);
    figure,imshow(imgn);title('Remove all object containing fewer than 70 pixels');
    
    %*-*-*-*-*-Calculating connected components*-*-*-*-*-    
    L = bwlabel(imgn,4);
    mx=max(max(L));
    
    % apply sobel
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
       
        % resize clip
        img_r=same_dim(n1);%Transf. to size 42 X 24
        %*-*Uncomment line below to see letters one by one*-*-*-*
        figure,imshow(img_r);pause(1)
        %*-*-*-*-*-*-*-*
		% read letter
        letter=read_letter(img_r);%img to text
        word=[word letter];
    end
    %fprintf(fid,'%s\n',lower(word));%Write 'word' in text file (lower)
    fprintf(fid,'Number Plate:-%s\nDate:-%s\n',word,date);%Write 'word' in text file (upper)
    fprintf(fid,'------------------------------------\n');
    fprintf(sprintf('Number Plate Extraction successful.\nExtracted Number plate:- %s .\nSee the log.txt file to see the stored number.',word),'Extraction Success');
    pause(1);
    word=[];%Clear 'word' variable
    %*-*-*When the sentences finish, breaks the loop*-*-*-*
    if isempty(re)  %See variable 're' in Fcn 'lines'
        break
    end
    %*-*-*-*-*--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
end
fclose(fid);
end