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

#### Demo
For the first demo, you are called upon to present the operation of the mergeLDRStack routine with different weighting functions. For the purposes of the demo, you will use the LDR image stack Image1, which accompanies the assignment. The index in the name of the photos in the LDR stack is in ascending order with respect to exposure times, which are: [1/2500, 1/1000, 1/500, 1/250, 1/125, 1/60, 1/30, 1/15, 1/8, 1/4, 1/2, 1, 2, 4, 8, 15] seconds.

Present the HDR renderings for each weighting function using the imagesc command for each color separately, in combination with their histograms. Use a colormap of your choice and add a colorbar. (a total of 12 HDR renderings: 1 scene * 4 weighting functions * 3 colors).

Comment on how many of the LDR images for each scene you consider sufficient to satisfactorily estimate the HDR rendering. Comment on how many bits you think each pixel would need to store the HDR rendering.

### Implementations
#### Function:
function w = select_function(z, zmin, zmax, t, weightingFnc)

#### Arguments:
* z: Array of points for which we want to calculate the weight
* zmin: The lower bound of allowable values for z
* zmax: The upper bound of allowable values for z
*  t: The exposure time value of the specific photograph. Only used if the photon weighting function is selected.
* weightingFnc: The argument that specifies which of the 4 weighting functions to use.
Takes values 1,2,3,4 with the mapping:
  1. uniform
  2. tent
  3. gaussian
  4. photon

#### Outputs:
* w: The array of calculated weights, of the same dimensions as the input array z.

#### Description:
This function is a helper function. Using the respective arguments, the selection of the appropriate weighting function is done in a simple and understandable way. If the weightingFnc argument does not have one of the 4 values mentioned above, an informative message is returned at the output about the suitable values it can take.

#### Function:
radianceMap = mergeLDRStack(imgStack, exposureTimes, weightingFnc, g)

#### Arguments:
* imgStack: A list of monochromatic input images with different exposure times, each one.
* exposureTimes: A list of exposure times corresponding to the input images.
* weightingFnc: The argument that specifies which of the 4 weighting functions to use.
  It takes values 1, 2, 3, 4 with the following mapping:
  1. uniform
  2. tent
  3. gaussian
  4. photon
* g: The argument 'g' is OPTIONAL. It is a discrete function with a domain in the integer interval [1, 256] and is used as shown in the following formula. If no specific function is given as an argument, then we assume g = log, i.e., it is the natural logarithm.

#### Outputs:
* radianceMap: The radiance map of the scene with floating-point values.

#### Description:
The function is responsible for taking the input images along with their exposure times and applying the appropriate calculations to find the radiance for each point in the scene. Initially, we choose static values for zmin=0.01 and zmax = 0.99 and initialize an array that we will return, along with an array of total weights calculated at each position. Then, we apply the algorithm sequentially for the images until all of them are processed, where in each iteration, the weight of each point is calculated using the appropriate function from the 4 available ones.

After the end of the iteration, we divide each point by the total weight that has been calculated for it, assuming that any point with a zero total weight is given the maximum value of this array. The implementation faithfully follows the assignment, applying the formula while at the end, just before returning, the array is exponentiated based on 'e' to remove the logarithm.

### Results
In the first demo, we use the images located in the "image1" folder of the dataset. After reading these images, we call the "mergeLDRStack" function that we created for all possible color channels (Red, Green, Blue) and weighting functions (uniform, tent, gaussian, photon). This results in 12 different outcomes, which are presented in the following images, representing the program's output. Each image simultaneously displays the colormap and the histogram of each case. The title of each image indicates the color and the function from which it originated.

![color: red, function: uniform](/images/red_uniform.png)
![color: red, function: tent](/images/red_tent.png)
![color: red, function: gaussian](/images/red_gaussian.png)
![color: red, function: photon](/images/red_photon.png)
![color: green, function: uniform](/images/green_uniform.png)
![color: green, function: tent](/images/green_tent.png)
![color: green, function: gaussian](/images/green_gaussian.png)
![color: green, function: photon](/images/green_photon.png)
![color: blue, function: uniform](/images/blue_uniform.png)
![color: blue, function: tent](/images/blue_tent.png)
![color: blue, function: gaussian](/images/blue_gaussian.png)
![color: blue, function: photon](/images/blue_photon.png)

* The first question that arises is how many LDR images are needed to satisfactorily estimate the HDR representation of the scene. The answer to this question cannot be a specific fixed number. Firstly, we need to consider whether we know the camera's response curve or if we need some LDR captures to determine it. Assuming that we are using a linear response curve as we did in demo 1, the number of captures we need depends on the dynamic range we need to cover. For example, a scene that includes the interior of a room with relatively little variation in brightness could be satisfactorily estimated with fewer LDR images compared to a scene that includes more significant changes in brightness, such as external light entering the room. For greater mathematical accuracy, we can say that if the dynamic range of the scene is Δ and the device we are using can represent a range equal to δ, then we will need (Δ/δ + 1) LDR images, where the operation Δ/δ is integer division (rounding the result down).

* The second question that arises is how many bits will be needed for the storage of this HDR image. The easy and obvious answer is that it will certainly require more bits than an LDR image used to create it. Indeed, if we decide to store the HDR image as it is, then we will need to store a floating-point number value in each pixel, which in the best case will consist of 32 bits, four times more than a simple input image that has a numeric value of type uint8 (an integer ranging from 0 to 255). Because there will be 3 channels for each pixel, one for each color, each pixel in the image will require 12 bytes of storage space.

## Tone Mapping
### Task
After estimating the HDR image, the process of tone mapping is required to represent it as a photograph. Tone mapping maps a set of colors to another to approximate the appearance of HDR images on a medium with a more limited dynamic range, such as a screen or printer. There are many tone mapping methods, and for reference, without being required for the task, we suggest reading the method of Reinhard et al. [4].

In the context of the task, we will apply the method of global tone mapping with gamma correction, which has the form Vout = V^gamma_in, where Vin ∈ [0, 1], and Vout ∈ [0, 1]. Implement the tone mapping function that applies gamma correction to an HDR image per color.

function tonedImage = toneMapping(radianceMap, gamma)

Where:
* tonedImage: Output image with 256 quantization levels (uint8)
* radianceMap: The M × N scene radiance map with floating-point values (double).
* gamma: Gamma coefficient.

#### Demo
From the HDR maps you estimated in the previous section for Image1, choose a pointwise transformation for tone mapping so that the result appears attractive. You can start by trying with γ = 0.8 or γ = 1.4 and then experiment further. You don't need to be concerned about accurate color representation. Present the image with your chosen γ and comment on the results.

To confirm the correctness of the representation, you can optionally try the following. In the scene of Image1, there is a color palette on a shelf, the right column of which contains boxes with different shades of gray, starting from white (bottom) to black (top). The gray palette is designed so that each box has double reflectance (i.e., the material's ability to reflect light) compared to the one above it. Therefore, in a faithful monochromatic representation of the scene, the brightness in the pixels of each box increases linearly. Identify these 6 pixels and plot them together with the line connecting the highest and lowest values. The brightness of pixels from an RGB image is given by the rgb2gray function. Repeat the step for the HDR image without gamma correction (simple scaling in the [0,1] range) and with gamma correction. Present the two plots and report which γ value the six points closest to the line approximate.

### Implementations
#### Function:
function tonedImage = toneMapping (radianceMap, gamma)

#### Arguments:
* radianceMap: The scene radiance map with floating-point values.
* gamma: The gamma coefficient.

#### Outputs:
* tonedImage: Output image with 256 quantization levels (uint8)

#### Description:
The function first scales the input values provided in the radianceMap argument to the [0,1] range, and then raises them all to the power of gamma. Finally, the result is multiplied by 255 so that each pixel of tonedImage has an integer value between [0,255].

### Results
In this demo, we use the toneMapping function for each of the 12 HDR images calculated in the previous demo. By selecting the desired gamma value within the code, we apply the gamma correction methodology. These images are recalculated to ensure that this file is not dependent on demo1. As an example, we provide 4 of the output images from this demo, while running the file generates all 12 images in the output:

![color: red, function: uniform, γ=0.3](/images/red_uniform2.png)
![color: green, function: tent, γ=0.3](/images/green_tent2.png)
![color: blue, function: gaussian, γ=0.3](/images/blue_gaussian2.png)
![color: red, function: photon, γ=0.3](/images/red_photon2.png)

In the title of each image, the color channel presented, the weighting function used, and the gamma coefficient are mentioned. In all examples, the value of gamma = 0.3 was used. It appears that the gamma correction technique is particularly effective and significantly improves the results, always comparing them to the images on the left, which are the HDR images immediately before the application of this technique. However, the choice of this gamma coefficient is subjective and not binding, so another value of the coefficient may be considered better by another user.

## Radiometric Calibration: Camera's Response Curve estimation
### Task
The camera response curve, f, is generally nonlinear and is a characteristic of the sensor. In order to merge multiple LDR (Low Dynamic Range) exposures with known exposure times, radiometric calibration is necessary to correct for the nonlinearity of the camera sensor. In this section, we will estimate the characteristic camera response curve using the method described by Debevec et al. [2]. We describe how the method works below, but we encourage you to read at least Section 2.1 of this work, where the method is explained in detail.

Given that the domain of the desired function g := lnf^−1 is the discrete intensity values {0, . . . , 255}, the function g can be described by 256 parameters, essentially forming a vector of 256 positions. Solving equation 2 for these 256 values may seem impossible because we do not know g or Eij. However, if the imaged scene remains static during the exposure stack, we can take advantage of the fact that the value Eij is constant in all LDR images. Then, we can recover g by solving the following least squares optimization problem:

![Equation 4](/images/equation4.png)

As discussed in Section 1, the weights w(z) are related to the fact that the estimations should rely more on image elements with good exposure than on image elements with low or excessive exposure. Additionally, when using these weights for linearization, adjust them to operate in the range [0, 255], and set Zmin = 0 and Zmax = 255.

The second term in Equation 4 is related to the expectation that g should be smooth, and therefore, we 'penalize' solutions g that have large second derivative values. Given that g is discrete, the second derivative can be approximated as ∇²g(z) = g(z + 1) - 2g(z) + g(z - 1). Note that when using weights for optimal photons w_photon that require knowledge of the exposure time, you can set the weights of the regularization term to a constant (e.g., w(z) = 1).

Solve the least squares optimization problem of the equation by expressing the linear equations from different pixels and different exposure times in the form of Ax = b. Refer to the MATLAB manual for the mldivide operator, .

NOTE: In Appendix A of Debevec et al.'s [2] work, MATLAB code is provided. If you choose to use this implementation, explain the steps followed in your report.

The pointwise transformation g that will be estimated can then be used to convert the brightness values of the LDR images Z_k_ij into values calibrated with respect to the camera response curve:

![Equation 5](/images/equation5.png)

For each color channel, the routine will be applied separately, estimating a characteristic camera curve for each color.

function responseCurve = estimateResponseCurve(imgStack, exposureTimes, smoothingLambda, weightingFcn)

Where:
* responseCurve: The estimated characteristic camera curve in the form of a lookup table. A vector of size 256 × 1.
* imgStack: The list of input images from different exposure times and dimensions M × N × 1 for each.
* exposureTimes: The list of exposure times, tk, corresponding to the input images.
* smoothingLambda: Estimation coefficient.
* weightingFcn: The argument that specifies which of the 4 weighting functions to use.

#### Demo
Design the camera response curve separately for the three colors for scenes Image1 and Image2. The axes of the curve should be the same as those in the figure ??.

Then, using the functions mergeLDRStack and toneMapping, present the result of merging the LDR images for Image1 and Image2. Experiment with the parameters to generate the visual result that you find satisfactory. Please note that for estimating the characteristic camera curve, you will choose a weighting function, and the same weighting function should be used in the merging of the LDR images.

The index in the name of the photos in the LDR stack for Image2 is in ascending order with respect to the exposure times, which are: [1/400, 1/250, 1/100, 1/40, 1/25, 1/8, 1/3] seconds.

### Implementations
#### Function:
function [g, lE] = gsolve(Z, B, l, w)

#### Arguments:
* Z: A matrix of dimensions (P x E), where P is the number of selected points, and E is the number of different images. It contains the pixel values in the respective image.
* B: A matrix (E x 1) with the values of the logarithms of exposure times for each image.
* l: The parameter λ, used for curve regularization.
* W: A matrix of dimensions (256 x 1) with the values of the weight function for each possible Z value.
#### Outputs:
* g: A matrix with the logarithms of camera responses for each input value. It has dimensions (256 x 1).
* lE: A matrix with radiance values for the selected pixels provided as input.

#### Description:
The function is called to compute multiple unknowns, the g matrix with 256 unknowns, and the values of E for each pixel and each image, based on the following criterion:

![Equation 6](/images/equation6.png)

To achieve this, it uses the least squares method and creates two matrices, which are named A and b, so that the matrix operation can be performed as follows:
𝛢 * 𝑥 = 𝑏
Matrix A has dimensions (P*e+n+1,n+P), while matrix b is one-dimensional with a length equal to the first dimension of matrix A. Both matrices are initialized with values of 0 for each element.

Recalling that P is the number of pixels, e is the number of different images, and n is the number of different values a pixel can have, where n=256 (a constant).

The equation shown above is implemented in two stages. In the first stage, we will implement the first part of the equation without considering the λ coefficient. Matrix A can be imagined to be divided into parts, as shown in the illustration on the next page:
* In the first (P x e) rows, the minimization function shown in the equation above is implemented. Only two columns of matrix A are filled with values other than zero:
   1. The column with an index equal to the value of the pixel in the given image, which takes the output of the weight function for that value.
   2. The column corresponding to that pixel in the second part of this divided matrix. Additionally, the corresponding row of matrix b takes a value equal to the exposure time so that the photo with the weight corresponding to that pixel is considered.

To understand how these three values are obtained, it is enough to look at the minimization function and the coefficients that need to be provided. In front of the unknown value g, the coefficient is the weight, in front of the unknown radiance, the coefficient is again the weight but with a negative sign. And since we separate the known part of the equation on the right side, the product of weight and exposure time will have a positive value (not negative as in the formula above).
* After this process is completed (the first for loop of the algorithm), we need the next row of matrix A to set the requirement: g(128) = 0.
* In the remaining n rows, the second part of the equation is also applied, which includes the regularization coefficient λ. The second derivative of g, since we are referring to discrete values, is approximated as:

![Equation 7](/images/equation7.png)

Now, in each row of matrix A, 3 consecutive columns are filled, starting from the column with an index equal to the current iteration i. The corresponding rows of matrix b do not receive any values; they retain the initial value of 0 since we don't have a right-hand member that we haven't already filled in.

After solving the system, which can be solved if and only if our data, which is equal to P * e, is greater than the unknowns, we separate the unknowns of matrix X: the first 256 values are the g matrix, and the rest are the radiance values E. It is worth noting again that the returned values of g are logarithms, which is why they can take negative values.

NOTE: As mentioned earlier, there is a differentiation in the case that the fourth weight function is chosen. Thus, we perform the necessary check and assign the appropriate value to the variable Wij.

#### Function:
function responseCurve = estimateResponseCurve (imgStack, exposureTimes, smoothingLamda, weightingFnc)

#### Arguments:
* imgStack: The list of input images from different exposure times and dimensions M × N × 1 each.
* exposureTimes: The list of exposure times corresponding to the input images.
* smoothingLamda: Estimation coefficient.

#### Outputs:
* responseCurve: The camera characteristic curve estimated in the form of a lookup table. A vector of dimensions 256 × 1.

#### Description:
The function initially selects zmin = 0, zmax = 255, and the variable k that indicates how many points will be selected on each axis to be provided as data to the function responsible for calculating the camera response. For example, if k=30, then 900 pixels will be provided as data. The selection of pixels in the function is not random but attempts to be uniformly selected from the entire scene. For each image sequentially, we calculate the values of these pixels and store them in separate columns of a matrix Z. To perform the final calculation of the camera response curve, we use the ready-made gsolve function presented in the paper accompanying the assignment, which we analyze here more extensively than the others, as it is particularly strict in certain points. We pay attention to the case where we have chosen the fourth weighting function, then the w matrix we provide as an argument is two-dimensional since the weight value is influenced by the exposure time of each image.

### Results
In demo 3, we are called to utilize the estimateResponseCurve function that we created to find the device's response curve for both images. Then, we repeat the process we performed in demo 2, initially calculating the HDR image by combining the LDR images and then applying gamma correction. The parameters we can change to observe different results in the output are:
* Parameter λ for the smoothness of the response curve.
* Weighting function with 4 possible choices.
* Parameter γ for the gamma correction process.

In each chart/image that follows, the parameters used are mentioned in the title. The choice of parameters is a subjective process, and we ensure that the λ parameter is sufficiently large to make the response curve relatively smooth. We also make sure to use the same weighting function in the calculation of HDR images. The response curves and images that result from each weighting function follow.

For the first image:

![Image 1, uniform, λ=15](/images/image1_uniform1.png)
![Image 1, uniform, γ=0.3](/images/image1_uniform2.png)
![Image 1, tent, λ=15](/images/image1_tent1.png)
![Image 1, tent, γ=0.3](/images/image1_tent2.png)
![Image 1, gaussian, λ=15](/images/image1_gaussian1.png)
![Image 1, gaussian, γ=0.3](/images/image1_gaussian2.png)
![Image 1, photon, λ=30](/images/image1_photon1.png)
![Image 1, uniform, γ=0.3](/images/image1_photon2.png)

For the second image:

![Image 2, uniform, λ=10](/images/image2_uniform1.png)
![Image 2, uniform, γ=0.4](/images/image2_uniform2.png)
![Image 2, tent, λ=10](/images/image2_tent1.png)
![Image 2, tent, γ=0.4](/images/image2_tent2.png)
![Image 2, gaussian, λ=10](/images/image2_gaussian1.png)
![Image 2, gaussian, γ=0.4](/images/image2_gaussian2.png)
![Image 2, photon, λ=30](/images/image2_photon1.png)
![Image 2, uniform, γ=0.4](/images/image2_photon2.png)

Observation: In this second image, if we observe closely, there seems to be a slight degree of motion blur. The reason for its existence is that we take into account the rotated image.
