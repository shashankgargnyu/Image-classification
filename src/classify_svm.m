%% Load Data
clear all
load('image_count.mat')
load('mega_hist.mat')
%% Genrate Train label
train_label=[];
for i=1:length(images_count)
    image_label= i*ones(1,images_count(i));
    train_label=[train_label, image_label];
end

%% SVM
[W B] = vl_svmtrain(mega_hist', train_label, 0.01);