%% Load Data Files
clear all
load('category_names.mat')
load('imageTOfeature_mapping.mat')
load('feature_vectors.mat')
load('a_100_cluster.mat')
load('image_count.mat')

%%
k=100;          % Change K=number of clusters
mega_hist_new=[];
first_index=1;
l_tot=0;
for i=1:102
    category_name=names{i}
    for j=1:images_count(i)
        l=size(feature_vectors([category_name num2str(j)]))
        l_tot=l_tot+l(2);
        last_index=first_index + l(2) - 1;
        features_im=A(first_index:last_index);
        hist_counts=histcounts(features_im,k);
        mega_hist_new=[mega_hist_new;hist_counts];
        first_index=last_index+1;
    end
end