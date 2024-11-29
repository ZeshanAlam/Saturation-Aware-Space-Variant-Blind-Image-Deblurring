clear all
close all
% Main script to process images
% addpath 'C:\Users\Alamz\Documents\Research\saturate_deblurring_code_data\main_code\'
% Define the directory containing your images
imageDir = '.\Images\'; % Change this to your directory
imageFiles = dir(fullfile(imageDir, '*.jpg')); % Adjust the file extension as needed
patchSize = 150; % Size of the patch
saturationThreshold = 254; % Example threshold, adjust as needed
lowBlurThreshold = 0.00000002; % Define this based on your blur estimation method
someGradientThreshold = 9000; % Define this based on your needs

% Process each image and collect dark pixels
allDarkPixels = {}; % Cell array to store dark pixels from all images
allDarkPixelIndices = {}; % Cell array to store indices of dark pixels from all images

for i = 1:length(imageFiles)
    imagePath = fullfile(imageDir, imageFiles(i).name);
    image = (imread(imagePath));
    % Process the image and get dark pixels and their indices
    [darkPixels, darkPixelIndices] = processImage(image, patchSize, saturationThreshold, lowBlurThreshold, someGradientThreshold);
    darkPixels = darkPixels(darkPixels ~= 0);
    darkPixelIndices = darkPixelIndices(darkPixels ~= 0, :);

    %% Generate the image with estimated saturated region
    [I_decglare] = Saturated_glare(image, darkPixels, darkPixelIndices, saturationThreshold);
    I_decglare = (I_decglare) ./ max(max(max(I_decglare)));
    imwrite((I_decglare), ['.\Results\Interim', imageFiles(i).name]);
    Interim = ['.\Results\Interim', imageFiles(i).name]; % Replace with actual image path
    Proposed = ['.\Results\Proposed-Output', imageFiles(i).name];

    % Define the path to the AutoIt script
    autoItScript = 'deblurScript.au3'; % Replace with actual AutoIt script path

    % Run the AutoIt script with image and save paths as arguments
    system(sprintf('"%s" "%s" "%s"', autoItScript, Interim, Proposed));

    pause(10);
end

%% Generate the image with estimated saturated region
function [darkPixels, darkPixelIndices] = processImage(image, patchSize, saturationThreshold, lowBlurThreshold, sharpnessThreshold)
    % Calculate the centroid of the saturated region
    saturatedRegionCentroid = calculateSaturatedRegionCentroid(image, saturationThreshold);

    % Initialize arrays to store patch information
    patchInfo = [];

    % Split the image into patches and process each patch
    [rows, cols, ~] = size(image);
    for r = 1:patchSize:(rows - patchSize + 1)
        for c = 1:patchSize:(cols - patchSize + 1)
            patch = image(r:(r + patchSize - 1), c:(c + patchSize - 1), :);

            % Calculate the center of the patch
            patchCenter = [r + patchSize / 2, c + patchSize / 2];

            % Calculate local intensity gradient (sharpness measure)
            gradientMagnitude = calculateLocalIntensityGradient(patch);

            % Estimate blur in the patch using blind deconvolution
            estimatedKernel = BlurEstimation(patch);
            blurMeasure = kernel2measure(estimatedKernel);

            % Filter based on blur measure and sharpness (gradient magnitude) threshold
            if blurMeasure <= lowBlurThreshold && gradientMagnitude > sharpnessThreshold
                distance = norm(patchCenter - saturatedRegionCentroid);
                patchInfo = [patchInfo; blurMeasure, distance, r, c, gradientMagnitude];
            end
        end
    end

    % Sort patches based on blur measure (ascending) and then distance to saturated region centroid (ascending)
    sortedPatchInfo = sortrows(patchInfo, [1, 2]);

    % Select top patches based on sorting
    selectedPatches = sortedPatchInfo(1:min(8, size(sortedPatchInfo, 1)), :);

    % Initialize arrays to store dark pixels and their indices
    darkPixels = [];
    darkPixelIndices = [];

    % Process the selected patches and collect dark pixels and their indices
    for j = 1:size(selectedPatches, 1)
        r = selectedPatches(j, 3);
        c = selectedPatches(j, 4);
        patch = image(r:(r + patchSize - 1), c:(c + patchSize - 1), :);

        % Find the darkest pixel in the patch and its index
        [minValue, minIndex] = min(patch(:));
        [rowIdx, colIdx] = ind2sub(size(patch(:, :, 1)), minIndex);
        darkPixels = [darkPixels; minValue];
        darkPixelIndices = [darkPixelIndices; r + rowIdx - 1, c + colIdx - 1];
    end
end

function centroid = calculateSaturatedRegionCentroid(image, saturationThreshold)
    % Find the saturated pixels
    saturatedPixels = any(image >= saturationThreshold, 3);

    % Calculate the centroid of the saturated region
    [rows, cols] = find(saturatedPixels);
    centroid = mean([cols, rows], 1);
end

function gradientMagnitude = calculateLocalIntensityGradient(patch)
    % Convert patch to grayscale if it's a color image
    if size(patch, 3) == 3
        patch_gray = rgb2gray(patch);
    else
        patch_gray = patch;
    end

    % Calculate the gradient
    [gx, gy] = gradient(double(patch_gray));
    gradientMagnitude = sqrt(gx.^2 + gy.^2);

    % Sum up the magnitudes to get a single value for the patch
    gradientMagnitude = sum(gradientMagnitude(:));
end

function blurKernel = BlurEstimation(patch)
    % Perform blind deconvolution on the patch
    initialPSF = ones(5, 5) / 25; % Initial guess for PSF
    numIterations = 30;
    [~, blurKernel] = deconvblind(patch, initialPSF, numIterations);
end

function kernelVariance = kernel2measure(kernel)
    % Calculate the variance of the kernel as a measure of blur
    kernelVariance = var(kernel(:));
end



