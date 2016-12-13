%% Object Localization:
%% Setting Parameters:
close all;
clear vars;
clc;

% Adding VLFeat:
run('C:\Users\ducky\Desktop\NYU\Machine Learning\Project\VLFeat\vlfeat-0.9.20\toolbox\vl_setup');

% Load Caltech classifier:
%load('caltech101results.mat','ncat','model');
%load('caltech256results.mat','ncat','model');
load('k25model4cat.mat','model');
ncat = 4;

% Load test image:
image = imresize(rgb2gray(imread('trump2.jpg')),[600 600]);
image_size(1,:) = [size(image,1) size(image,2)];

% Extracting Feature Vectors for test image:
[loc,D] = vl_sift(single(image));

dsize(1) = 0; dsize(2) = size(D,1)+dsize(1);

% Set number of Levels in the Pyramid:
L = 2;

% Cell array of labels across levels:
pyrLabels = cell(1,L);

% Set number of clusters:
k = 25;

% Get image dimensions:
nrows = image_size(1,1); 
ncols = image_size(1,2);

%% Classifying Blocks and Subblocks:
% l = levels of pyramid
for l = 0:(L-1)
    % pre-initializing:
    l_votes = zeros(2^(2*l),1);
    % i = blocks within level
    for i = 1:2^(2*l)        
        ridx = floor(int32(i-1)/int32(2^l)); 
        cidx = mod(i-1,2^l);
        
        % Bounds of blocks:
        startRow = round(1+ridx*(nrows/2^l));
        endRow = round((ridx+1)*(nrows/2^l));
        startCol = round(1+cidx*(ncols/2^l));
        endCol = round((cidx+1)*(ncols/2^l));
        
        % Finding pixels in blocks:
        blk_px = find(loc(:,1)>=startRow & loc(:,1)<=endRow & loc(:,2)>=startCol & loc(:,2)<=endCol);
        blk_px_idx = find(blk_px>=dsize(1)+1 & blk_px<=dsize(1+1));
        blk_px = blk_px(blk_px_idx);
        
        % Classifying individual blocks:
        if size(blk_px,1) > 0
            counts = histerical(D(blk_px,:),k);
            [index,score] = predict(model,counts);
        else
            index = 0;
        end
        l_votes(i) = index;
    end
    pyrLabels{1,l+1} = l_votes;
end
%% Classifying each Pixel:

% Pre-initializing:
det_mask = zeros(nrows,ncols,3);

% Loop through the image:
for ridx = 1:nrows
    for cidx = 1:ncols
        voteMap = containers.Map(0,0);
        for l=0:(L-1)
            nblk_r = idivide(int32(ridx-1),int32(nrows/2^l));
            nblk_c = idivide(int32(cidx-1),int32(ncols/2^l));
            i = nblk_c + nblk_r*2^l+1;
            
            % Get weight:
            wl = 1/2^(L-l);
            
            % Getting votes:
            temp = pyrLabels{1,l+1}(i);
            if isKey(voteMap,temp)
                voteMap(temp) = voteMap(temp) + wl;
            else
                voteMap(temp) = wl;
            end
        end
        
        % Getting max vote:
        votemapper = voteMap.keys;
        minval = -1e5;
        minkey = -1;
        for p = 1:length(votemapper)
            temp = votemapper{p};
            value = voteMap(temp);
            if value > minval
                minval = value;
                minkey = temp;
            end
        end
        temp = minkey;
        
        % Generating mask:
        if temp==1
            det_mask(ridx,cidx,1) = 255;
        elseif temp==2
            det_mask(ridx,cidx,2) = 255;
        elseif temp==4
            det_mask(ridx,cidx,3) = 255;
        end
    end
end

%% Localizing:
C = imfuse(image,det_mask,'ColorChannels','red-cyan');
figure; imshow(rgb2gray(C),[]);