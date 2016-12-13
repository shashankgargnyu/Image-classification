function [ mega_hist ] = histerical(features,k)
[~,A] = vl_kmeans(single(features),k);
mega_hist = histcounts(A,k);
end



