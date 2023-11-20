function tonedImage = toneMapping(radianceMap, gamma)
    minimumValue = min(radianceMap,[],'all');
    maximumValue = max(radianceMap,[],'all');

    % transform each pixel value to [0,1] and after that apply gamma
    % correction and scale the output to [0,255] integers.
    tonedImage = (radianceMap-minimumValue)./(maximumValue-minimumValue);
    tonedImage = tonedImage.^gamma;
    tonedImage = uint8(255*tonedImage);
end