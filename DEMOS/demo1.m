clear;
close all;
clc;

%% INITIALIZE VARIABLES AND GET IMAGES
% Read images from folder
location='image1\*.jpg';
datastore = imageDatastore(location);
num_of_images = length(datastore.Files);
images = cell(num_of_images,1);
images_red = cell(num_of_images,1);
images_green = cell(num_of_images,1);
images_blue = cell(num_of_images,1);

% Separate red, green and blue channels of each image
for i=1:num_of_images
    images{i} = imread(string(datastore.Files(i)));
    images{i} = double(images{i})/255;
    images_red{i} = images{i}(:,:,1);
    images_green{i} = images{i}(:,:,2);
    images_blue{i} = images{i}(:,:,3);
end

% order is an array to reorder exposureTimes based on how they are read
% from the folder
order = [1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4, 5, 6, 7, 8, 9];
exposureTimes = [1/2500, 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1, 2, 4, 8, 15];

%% CALCULATE RADIANCE MAPS
count = 1;

colors = ["red","green","blue"];
function_names = ["uniform","tent","gaussian","photon"];

for color=1:3
    for chosen_function=1:4
        % get radiance map for specific color and weighting function
        if color==1
            radianceMaps{count} = mergeLDRStack(images_red,exposureTimes(order),chosen_function,0);
        elseif color==2
            radianceMaps{count} = mergeLDRStack(images_green,exposureTimes(order),chosen_function,0);
        else
            radianceMaps{count} = mergeLDRStack(images_blue,exposureTimes(order),chosen_function,0);
        end
        
        figure(count);
        clf;
        
        % enable colorbar and select colormap based on the represented
        % color
        subplot(1,2,1);
        imagesc(radianceMaps{count});
        colorbar;
     
        if color==1
            colormap autumn;
        elseif color==2
            colormap summer;
        else
            colormap winter;
        end
        
        % histogram of radiance map
        subplot(1,2,2);
        sgtitle(['color='+colors(color)+', function='+function_names(chosen_function)]);
        histogram(radianceMaps{count},'FaceColor',colors(color),'EdgeColor',colors(color),'Normalization','probability');
        
        count = count +1;
    end
end