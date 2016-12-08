clear all;
image_folder_path='/Users/shashankgarg/Desktop/Fall 2016/Machine Learning/Project/101_ObjectCategories';
code_dir='/Users/shashankgarg/Desktop/Fall 2016/Machine Learning/Project/Image-classification';
cd(image_folder_path);
image_folders=dir(image_folder_path);
features=[];
feature_vectors=containers.Map;
interest_points=containers.Map;
n_cat=length(image_folders);
names={};
for i=4:n_cat
    names(i)={image_folders(i,:).name}
    %disp(image_folders(i,:).name)
end
count=0;
images_count=[];
for cat=4:n_cat
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
            [interest_points([cat_name num2str(image)]), feature_vectors([cat_name num2str(image)])] = vl_sift(single(I)) ;
            features=[features;feature_vectors([cat_name num2str(image)])'];
            %feature_vectors([cat_name num2str(image)])=SIFT_feature(image_names(image).name);
            %features=[features;feature_vectors([cat_name num2str(image)])'];
            count=count+1;
            disp(count)
            %fprintf('%s cat %s image\n', cat, image);
        catch
            p_count=p_count+1;
            problem{p_count,1}=cat_name;
            problem{p_count,2}=num2str(image);
        end
    end
    cd(image_folder_path);
end
cd(code_dir);
save('feature_vectors.mat','features');
save('imageTOfeature_mapping.mat', 'feature_vectors');
save('imageTOpoint_mapping.mat', 'interest_points');
%save('problematic_images.mat', 'problem');