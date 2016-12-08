clc
clear all
close all
load('feature_vectors.mat')
load('imageTOfeature_mapping.mat')
ene=[];
ix=1200:50:2000
for i=1200:50:2000
    [C,A,Energy]=vl_kmeans(single(features)',i);
    ene=[ene,Energy]
end
plot(ix,ene)