clear
close all
clc

%% INITIALIZE VARIABLES AND GET IMAGES FROM THE FIRST FOLDER
figure_counter = 0;
lamda = 15;
gamma = 0.3;

location='image1\*.jpg';
datastore = imageDatastore(location);
num_of_images = length(datastore.Files);
images = cell(num_of_images,1);
images_red = cell(num_of_images,1);
images_green = cell(num_of_images,1);
images_blue = cell(num_of_images,1);

for i=1:num_of_images
    images{i} = imread(string(datastore.Files(i)));
    images{i} = double(images{i})/255;
    images_red{i} = images{i}(:,:,1);
    images_green{i} = images{i}(:,:,2);
    images_blue{i} = images{i}(:,:,3);
end

order = [1, 10, 11, 12, 13, 14, 15, 16, 2, 3, 4, 5, 6, 7, 8, 9];
exposureTimes = [1/2500, 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1, 2, 4, 8, 15];
exposureTimes = exposureTimes(order);

function_names = ["uniform","tent","gaussian","photon"];

%% RESPONSE CURVES AND FINAL HDR IMAGE 1 FOR DIFFERENT WEIGHTING FUNCTIONS

for weighting_function=1:4
%   estimate response curves for each color channel
    responseCurve(:,1) = estimateResponseCurve(images_red, exposureTimes, lamda, weighting_function);
    responseCurve(:,2) = estimateResponseCurve(images_green, exposureTimes, lamda, weighting_function);
    responseCurve(:,3) = estimateResponseCurve(images_blue, exposureTimes, lamda, weighting_function);

%     increase lamda when we use photon weighting
    if weighting_function == 4
        lamda = 30;
    end
    
    figure_counter = figure_counter + 1;
    figure(figure_counter);
    clf;
    plot(responseCurve(:,1),0:255,'r');
    xlabel('log(Number of photons)');
    ylabel('Pixel value Z');
    title('First Image, function= '+function_names(weighting_function)+', lamda = '+lamda);
    hold on;
    plot(responseCurve(:,2),0:255,'g');
    plot(responseCurve(:,3),0:255,'b');

    colors = ["red","green","blue"];

    count=1;
    for color=1:3
        % get radiance map for specific color and weighting function
        if color==1
            radianceMap{count} = mergeLDRStack(images_red,exposureTimes,weighting_function,responseCurve(:,1));
        elseif color==2
            radianceMap{count} = mergeLDRStack(images_green,exposureTimes,weighting_function,responseCurve(:,2));
        else
            radianceMap{count} = mergeLDRStack(images_blue,exposureTimes,weighting_function,responseCurve(:,3));
        end
        
        toneImage{count} = toneMapping(radianceMap{count},gamma);
        count = count + 1;
    end
    
%    Construct an image with the 3 color channels
    finalImage(:,:,1) = toneImage{1};
    finalImage(:,:,2) = toneImage{2};
    finalImage(:,:,3) = toneImage{3};
    figure_counter = figure_counter + 1;
    figure(figure_counter);
    clf;
    imshow(finalImage);
    title('Image 1, function= '+function_names(weighting_function)+', γ= '+gamma)
end

%% INITIALIZE VARIABLES AND GET IMAGES FROM THE SECOND FOLDER

lamda = 10;
gamma = 0.4;

location='image2\*.jpg';
datastore = imageDatastore(location);
num_of_images = length(datastore.Files);
excluded_images = 2;
images = cell(num_of_images,1);
images_red = cell(num_of_images,1);
images_green = cell(num_of_images,1);
images_blue = cell(num_of_images,1);

% Exclude the last 2 images
for i=1:num_of_images
    images{i} = imread(string(datastore.Files(i)));
    images{i} = double(images{i})/255;
    images_red{i} = images{i}(:,:,1);
    images_green{i} = images{i}(:,:,2);
    images_blue{i} = images{i}(:,:,3);
end

exposureTimes = [1/400, 1/250, 1/100, 1/40, 1/25, 1/8, 1/3];

%% RESPONSE CURVES AND FINAL HDR IMAGE 1 FOR DIFFERENT WEIGHTING FUNCTIONS

for weighting_function=1:4
    
    if weighting_function == 4
        lamda = 30;
    end
    
    responseCurve(:,1) = estimateResponseCurve(images_red, exposureTimes, lamda, weighting_function);
    responseCurve(:,2) = estimateResponseCurve(images_green, exposureTimes, lamda, weighting_function);
    responseCurve(:,3) = estimateResponseCurve(images_blue, exposureTimes, lamda, weighting_function);

    figure_counter = figure_counter + 1;
    figure(figure_counter);
    clf;
    plot(responseCurve(:,1),0:255,'r');
    xlabel('log(Number of photons)');
    ylabel('Pixel value Z');
    title('Second Image, function= '+function_names(weighting_function)+', lamda = '+lamda);
    hold on;
    plot(responseCurve(:,2),0:255,'g');
    plot(responseCurve(:,3),0:255,'b');

    colors = ["red","green","blue"];

    count=1;
    for color=1:3
        % get radiance map for specific color and weighting function
        if color==1
            radianceMap{count} = mergeLDRStack(images_red,exposureTimes,weighting_function,responseCurve(:,1));
        elseif color==2
            radianceMap{count} = mergeLDRStack(images_green,exposureTimes,weighting_function,responseCurve(:,2));
        else
            radianceMap{count} = mergeLDRStack(images_blue,exposureTimes,weighting_function,responseCurve(:,3));
        end
        
        toneImage{count} = toneMapping(radianceMap{count},gamma);
        count = count + 1;
    end
    finalImage2(:,:,1) = toneImage{1};
    finalImage2(:,:,2) = toneImage{2};
    finalImage2(:,:,3) = toneImage{3};
    figure_counter = figure_counter + 1;
    figure(figure_counter);
    clf;
    imshow(finalImage2);
    title('Image 2, function= '+function_names(weighting_function)+', γ= '+gamma)
end