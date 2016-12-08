%% Load Data Files
clear all
load('category_names.mat')
load('imageTOfeature_mapping.mat')
load('feature_vectors.mat')
load('a_100_cluster.mat')
load('image_count.mat')

%%
k=100;          % Change K=number of clusters
mega_hist=[];
for i=1:102
    category_name=names{i};
    first_index=1;
    for j=1:images_count(i)
        last_index=length(feature_vectors([category_name num2str(j)]));
        features_im=A(first_index:last_index);
        hist_counts=histcounts(features_im,k);
        mega_hist=[mega_hist;hist_counts];
        first_index=last_index+1;
    end
end