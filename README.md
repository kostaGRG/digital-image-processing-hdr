# Digital Image Processing: HDR
## Intro
This project is created for the university class named Digital Image Processing at Aristotle University of Thessaloniki (AUTh). It's the third out of three repositories referenced on the same class.

## General
The term "dynamic range" is a dimensionless quantity that can be used for different physical measures. For images, it is the ratio between the brightest and darkest pixel. For a display, the dynamic range is the ratio of the maximum and minimum brightness it can emit. The dynamic range of a camera is the ratio of the sensor's saturation brightness ('clipping') and the brightness that raises the camera's response slightly above the noise level. In the following image LDR (left) is compared to HDR (right).

![Comparing LDR to HDR image](/images/compare.png)

People, by their nature, can perceive a wide dynamic range in a scene. Cameras, on the other hand, have a low dynamic range (LDR), and to capture the detail that our eyes can see in a photograph, we need to take multiple exposures and combine them to create a high dynamic range (HDR) image.

The purpose of this work is to explore high dynamic range (HDR) imaging from multiple low dynamic range (LDR) captures and tone mapping. HDR imaging aims to create images with precise floating-point values that correspond to scene brightness with a large dynamic range. Tone mapping is the process of compressing the dynamic range of HDR images to a smaller range so that they can be displayed on a screen.

For the more accurate estimation of HDR imaging from multiple LDR captures, radiometric calibration of input images can be performed by estimating the camera's generally nonlinear response curve using the method of Debevec et al.

Furthermore, improving HDR imaging from multiple captures is achieved by aligning the multiple input images (image registration) as a preprocessing step to eliminate corresponding artifacts in the final result.

In the third task of the course, you will implement the following:

Integration of multiple LDR images into an HDR image
Tone mapping
Radiometric calibration according to Debevec
Image registration to improve HDR imaging
Along with the assignment, you will find the images you will use for each question. Each folder contains multiple photographs of the same scene taken at different exposure times, accompanied by an accurate recording of the exposure time.

## Multi-frame HDR imaging
### Task
Commercial cameras are unable to capture scenes with a high dynamic range from a single shot due to the inherent limitations of the imaging sensor, which suffers from saturation in high radiation areas and uncertainty in low-light areas. The goal of this section is to implement an algorithm for merging multiple exposures of a scene with different exposure times for HDR imaging, i.e., for creating images with precise floating-point values that correspond to scene radiation values.

The input to the algorithm is a stack of LDR (Low Dynamic Range) photos taken with different (known) exposure durations tk, k = {1, ..., K}. We will assume that the scene is static and that this process completes quickly enough to safely ignore changes in lighting. Therefore, we can assume that the radiation quantity, Eij, reaching the sensor of a pixel {i, j} is constant. We represent the pixel values as Zkij, where {i, j} is the spatial index of the pixel, and k is the exposure time index tk.

In what follows, each color channel is treated separately and is not included in the notation for simplicity.

The integer value of brightness Zkij for a pixel {i, j} in the image with exposure time index k is related to the unknown and desired quantity of scene radiation ij according to the following relationship:

![Equation 0](/images/equation0.png)

where f is generally a non-linear function that characterizes the image sensor's response, and we call it the camera response curve. If we knew the inverse function f −1(Zkij ) = tkEij , then we could convert the brightness values Zkij to the desired radiation values as a simple multiplication by a constant, given that we know the exposure times. Instead of f −1, we will consider the function g := lnf −1, which maps the pixel values Zkij to radiation values as follows:

![Equation 1](/images/equation1.png)

For robustness and for recovering high dynamic range radiation values, we should use all available exposure times for a specific pixel to estimate its radiation based on equation 2. For this purpose, we can use a weighting function, w(z), to give higher weight to exposures where the pixel value is closer to the center of the dynamic range and not close to saturation or noisy underexposure:

![Equation 2][/images/equation2.png]

There are many possible choices for the weighting function. You will implement the following four:

![Equation 3](/images/equation3.png)

All of the weighting functions above assume that the intensity values are in the range z∈[0,1]. Make sure to normalize your LDR images to this range (e.g., divide by 255, etc.). You can experiment with different clipping values Zmin and Zmax, but we recommend Zmin = 0.01, Zmax = 0.99. Unlike the other schemes, the weights wphoton also depend on the exposure time under which a pixel was captured. Apply all of the above weighting schemes and use them to create HDR images.

![Linear camera response curve with saturation](/images/plot.png)

In the 1st section of the assignment, we will consider a linear camera response curve with saturation. Specifically, assume that in the linear region, it is the identity function f(x) = x. Implement the mergeLDRStack routine, which takes as input a list of K monochromatic images taken at different exposure times and dimensions M × N × 1 each, as well as the corresponding exposure times tk. It returns the radiance map estimated from the HDR rendering through weighted merging of the images. More specifically:

function radianceMap = mergeLDRStack(imgStack, exposureTimes, weightingFcn)

Where:
* imgStack: The list of input monochromatic images with different exposure times and dimensions M × N × 1 each.
* exposureTimes: The list of exposure times, tk, corresponding to the input images.
* radianceMap: The M × N radiance map with floating-point values (double).
* weightingFcn: The argument that specifies which of the 4 weighting functions to use.

Note: During the merging of multiple LDR images, there may be some pixels that have not been correctly exposed in any exposure duration, meaning the sum of weights in the denominator of equation 3 is exactly 0. You can define these pixels to be equal to the maximum or minimum valid pixel value in the HDR image, respectively, for problematic pixels that are always overexposed or underexposed.

For the first demo, you are called upon to present the operation of the mergeLDRStack routine with different weighting functions. For the purposes of the demo, you will use the LDR image stack Image1, which accompanies the assignment. The index in the name of the photos in the LDR stack is in ascending order with respect to exposure times, which are: [1/2500, 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1, 2, 4, 8, 15] seconds.

Present the HDR renderings for each weighting function using the imagesc command for each color separately, in combination with their histograms. Use a colormap of your choice and add a colorbar. (a total of 12 HDR renderings: 1 scene * 4 weighting functions * 3 colors).

Comment on how many of the LDR images for each scene you consider sufficient to satisfactorily estimate the HDR rendering. Comment on how many bits you think each pixel would need to store the HDR rendering.

### Implementations
