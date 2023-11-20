clear;
close all;
clc;

%% INITIALIZE VARIABLES AND GET IMAGES
% Load all images from the folder
location='image1\*.jpg';
datastore = imageDatastore(location);
num_of_images = length(datastore.Files);
images = cell(num_of_images,1);
images_red = cell(num_of_images,1);
images_green = cell(num_of_images,1);
images_blue = cell(num_of_images,1);

% Separate each image to red, green and blue channels
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

%% GET RADIANCE MAPS FOR EVERY COMBINATION OF COLOR/FUNCTION
count = 1;

colors = ["red","green","blue"];
function_names = ["uniform","tent","gaussian","photon"];

% Here we follow the same procedure as in demo1.m
for color=1:3
    for chosen_function=1:4
        toneImage_colors(count) = colors(color);
        toneImage_functions(count) = function_names(chosen_function);
        if color==1
            radianceMaps{count} = mergeLDRStack(images_red,exposureTimes(order),chosen_function,0);
        elseif color==2
            radianceMaps{count} = mergeLDRStack(images_green,exposureTimes(order),chosen_function,0);
        else
            radianceMaps{count} = mergeLDRStack(images_blue,exposureTimes(order),chosen_function,0);
        end
        count = count +1;
    end
end
%% TONE MAPPING
num_of_hdr_images = length(radianceMaps);

gamma = 0.3;
% For each radiance map calculated before, find the tonedImage using
% the toneMapping function and plot the results.
for i=1:num_of_hdr_images
    radianceMap = radianceMaps{i};
    toneImage = toneMapping(radianceMap,gamma);
    figure(i);
    sgtitle(['Color= '+toneImage_colors(i)+', function= '+toneImage_functions(i)+', γ= '+gamma])
    subplot(1,2,1);
    imshow(radianceMap);
    title('Original Image');
    subplot(1,2,2);
    imshow(toneImage);
    title('Image after Gamma Correction');  
end
