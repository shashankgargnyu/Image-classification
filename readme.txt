Image Classification
	→ demo_main.m (To generate sift features and keypoints )
	→ feature_vectors.mat (It contains all the feature vector of all the images in the dataset ( 		2158239* 128) , Rows= No. of features, columns= length of the descriptor) 
	→ imageTOfeature_mapping.mat (9144*1) , example : feature_vectors([‘Faces’ ‘4’]) 
It means you can access feature_list of  4th image in “Faces’ category.
	→ Image_count.mat  (This stores the number of images in each category from 1 to 102)
	→ category_names.mat ( It contains all the categories name stored in cell) 
Example: Faces={names(1)}
→ clustering.m ( Used K-means to determine the optimum value of k , still running) , 		 suppose k=100 for experiment
→ a_100_cluster.mat ( maps every feature vector to the corresponding cluster)
→ c_100_cluster.mat ( gives the centroid of 100 cluster)
→ mega_histogram.m ( To generate the mega histogram of visual words) . 
→ mega_hist.mat ( generated from mega_histogram.m)  (9144*100)  where, 1*100 is the     	 histogram of 100 visual words of one image
→ classify_svm.m ( Training svm)

Other data can be found at the google drive link below:
https://drive.google.com/a/nyu.edu/file/d/0BzUaoTczb_gSaW1oTEc0OVlvWms/view?usp=sharing

	
