function radianceMap = mergeLDRStack(imgStack, exposureTimes, weightingFnc,g)
%   Parameters zmin and zmax of function, used in weighting function.
    zmin=0.01;
    zmax=0.99;
    
    if g == 0
        g = log(0:255);
    end
    % Initialize arrays
    % weights: array to store total weight for each pixel
    radianceMap = zeros(size(imgStack{1}));
    weights = zeros(size(imgStack{1}));
    
    % Calculate weights of each pixel for each image
    num_of_images = length(imgStack);
    for i=1:num_of_images
        image = imgStack{i};

        temp_weights = select_function(image,zmin,zmax,exposureTimes(i),weightingFnc);
        weights = weights + temp_weights;
        radianceMap = radianceMap + temp_weights.*(g(image.*255+1) - log(exposureTimes(i)));
    end
    
    % Change weight value to maximum, if it has value 0
    maximum_weight = max(weights,[],'all');
    for i=1:size(image,1)
        for j=1:size(image,2)
           if weights(i,j) == 0 
               weights(i,j) = maximum_weight;
           end
        end
    end
    % Divide each pixel with total calculated weight for this pixel
    radianceMap = radianceMap./weights;
    radianceMap = exp(radianceMap);
end