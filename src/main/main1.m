%% Bag of Visual Words: Object Recognition
%% Setting Parameters:
close all;
clear vars;

% Adding VLFeat for fast implementations of feature generation and k-means
% clustering:
run('/home/neel/bin/vlfeat-0.9.20/toolbox/vl_setup');

% Set number of categories:
%ncat = 256;
ncat = 101;
%ncat = 4;

% Setting size of codeword dictionary:
k = 20;

% Enter number of CPU Cores (physical, not hyperthreaded). If Hyperthreading
% is not available, use half the number of physical cores for this param:
ncores = 6;

% Setting Path to Image Folders from Caltech 101 or 256:
image_folder_path='/home/neel/Desktop/school/Machine_Learning/Project/101_ObjectCategories';
%image_folder_path='/home/neel/Desktop/school/Machine_Learning/Project/256_ObjectCategories';
%image_folder_path='/home/neel/Desktop/school/Machine_Learning/Project/4_categories';

% Directory for code:
code_dir='/home/neel/Desktop/school/Machine_Learning/Project/hist_100_words';
cd(image_folder_path);
image_folders = dir(image_folder_path);

switch ncat
    case 256
        image_folders = image_folders(3:end);
    case 4
        image_folders = image_folders(3:end);
    case 101
        image_folders = image_folders(4:end);
end

%% SIFT Feature Extraction from Images:

% Other initializations:
features = [];
feature_vectors = containers.Map;
interest_points = containers.Map;
n_cat = length(image_folders);
names = {};
count=0;
images_count=[];

% Getting Category Names:
for i = 1:n_cat
    names(i) = {image_folders(i,:).name};
    %disp(image_folders(i,:).name)
end

% Feature Extraction:
for cat=1:n_cat
    cat_name=image_folders(cat,:).name;
    cd(cat_name);
    current_image_folder=cd;
    image_names=dir(strcat(current_image_folder,'/*.jpg'));
    n_images=length(image_names);
    images_count=[images_count, n_images];
    p_count=0;
    problem={};
    
    for image=1:n_images
        try
            I = imread(image_names(image).name);
            if size(I,3)==3
                I = rgb2gray(I) ;
            end
            
            vl_threads(12);
            [interest_points([cat_name num2str(image)]), feature_vectors([cat_name num2str(image)])] = vl_sift(single(I)) ;
            features = [features;feature_vectors([cat_name num2str(image)])'];
            count=count+1;
        catch
            p_count=p_count+1;
            problem{p_count,1}=cat_name;
            problem{p_count,2}=num2str(image);
        end
    end
    
    cd(image_folder_path);
end

%% Clustering for Codeword Dictionary

for i = 1:size(features,1)
    features(i,:) = features(i,:)./max(features(i,:));
end


vl_threads(2*ncores);
[C,A] = vl_kmeans(single(features'),k);

%% Generating Histogram of Features for every Image:

mega_hist_new=[];
first_index=1;
l_tot=0;
for i=1:ncat
    category_name=names{i};
    for j=1:images_count(i)
        l=size(feature_vectors([category_name num2str(j)]));
        l_tot=l_tot+l(2);
        last_index=first_index + l(2) - 1;
        features_im=A(first_index:last_index);
        hist_counts=histcounts(features_im,k);
        mega_hist_new=[mega_hist_new;hist_counts];
        first_index=last_index+1;
    end
end

mega_hist = mega_hist_new;
clear mega_hist_new;

%% Reordering and Labelling & Splitting into Train and Test:

positions = cumsum(images_count);

% Generating Labels for each feature:
clabels = ones(length(1:positions(1)),1);
for i = 2:ncat
    labels = i*ones(positions(i)-positions(i-1),1);
    clabels = vertcat(clabels,labels);
end
 
cat_hist{1} = mega_hist(1:positions(1),:);
for i = 2:ncat
    cat_hist{i} = mega_hist(positions(i-1):positions(i),:);
end

for i = 1:ncat
    cat_size = size(cat_hist{i},1);
    [trainInd,valInd,testInd] = dividerand(cat_size,0.6,0,0.4);
    traindata{i} = cat_hist{i}(trainInd,:);
    trainlabels{i} = i*ones(size(traindata{i},1),1);
    testdata{i} = cat_hist{i}(testInd,:);
    testlabels{i} = i*ones(size(testdata{i},1),1);
end

%% Converting Cells to Matrices:
traindatamtx = traindata{1};
trainlabelsmtx = trainlabels{1};
testdatamtx = testdata{1};
testlabelsmtx = testlabels{1};
for i = 2:ncat
    traindatamtx = vertcat(traindatamtx,traindata{i});
    trainlabelsmtx = vertcat(trainlabelsmtx,trainlabels{i});
    testdatamtx = vertcat(testdatamtx,testdata{i});
    testlabelsmtx = vertcat(testlabelsmtx,testlabels{i});
end

%% Bag Ensemble-Aggregation Classification

% Generating Classification Model using a 100 weak learners:
model = fitensemble(traindatamtx,trainlabelsmtx,'Bag',100,'Tree','type','classification');

%% Predicting
[predlabel,score] = predict(model,testdatamtx);

%% Evaluating Random Forest Classification

t = predlabel - testlabelsmtx;
n = t(t==0);

% Classification Accuracy:
RFAccuracy = 100*size(n,1)/size(testlabelsmtx,1)

% Confusion Matrix:
conf = confusionmat(testlabelsmtx,predlabel);

%
%% Naive Bayes Classification

nbmodel = fitcnb(traindatamtx,trainlabelsmtx);

% Predicting
[nbpredlabel,nbscore] = predict(nbmodel,testdatamtx);

%% Evaluating NB Classification

nbt = nbpredlabel - testlabelsmtx;
nbn = nbt(nbt==0);
NBAccuracy = 100*size(nbn,1)/size(testlabelsmtx,1)
nbconf = confusionmat(testlabelsmtx,nbpredlabel);


%% Plot ROC for RF:
figure;
for i = 1:size(score,2)
    [X,Y,T,AUCrf{i}] = perfcurve(testlabelsmtx,score(:,i),i);
    plot(X,Y,'linewidth',2); hold on;
end 
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for Classification by Random Forests')
%legend('Faces','Motorbikes','Airplanes', 'Cars');

%% Plot ROC for NB:
figure;
for i = 1:size(nbscore,2)
    [X,Y,T,AUCnb{i}] = perfcurve(testlabelsmtx,nbscore(:,i),i);
    plot(X,Y,'linewidth',2); hold on;
end 
xlabel('False positive rate')
ylabel('True positive rate')
title('ROC for Classification by Naive Bayes')
legend('Faces','Motorbikes','Airplanes', 'Cars');

%%
cd(code_dir)