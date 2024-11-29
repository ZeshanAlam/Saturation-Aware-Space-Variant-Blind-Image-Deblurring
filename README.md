# Saturation-Aware-Space-Variant-Blind-Image-Deblurring
README: Saturation-Aware Space-Variant Blind Image Deblurring Code
This repository contains MATLAB code for implementing a Saturation-Aware Space-Variant Blind Image Deblurring algorithm. The approach involves isolating saturated regions, estimating true radiance, and recovering images through space-variant deblurring techniques.

Installation Requirements
1. MATLAB
Ensure you have MATLAB installed on your machine with the following toolboxes:

Image Processing Toolbox
Optimization Toolbox 

2. Professional Deblurring Software
This code integrates external professional deblurring software for additional processing. Please download the full version of the deblurring software from the following link:

https://www.cse.cuhk.edu.hk/~leojia/deblurring.htm

Professional Deblurring Software

After installation, ensure the software is properly licensed and functioning.

4. AutoIt v3 (for Windows)
5. 
AutoIt v3 is required to automate certain processes in the deblurring pipeline. Download and install AutoIt from the official link:


Usage Instructions
1. Setup
Place your input images in the .\Images\ folder. 
Ensure the Results folder exists in the project directory. This is where processed images will be stored.
2. Run the Code
Open MATLAB and navigate to the directory containing the code files.
Run the main script (Demo.m) using the command:
processImage
The script will:
Process each image in the .\Images\ folder.
Estimate saturated regions.
Save intermediate and final outputs in the .\Results\ folder.
3. Deblurring Process
The script invokes the Professional Deblurring Software through AutoIt.
Here is an example of how the AutoIt script should look:
Example: deblurScript.au3 

Key Features
Saturation Handling: Isolates saturated regions and estimates true radiance using a dark channel prior.
Space-Variant Deblurring: Integrates professional deblurring software for enhanced results.
Folder Structure
.\Images\: Input images for processing.
.\Results\: Stores intermediate and final output images.
deblurScript.au3: AutoIt script for automating the deblurring process.
Demo.m: Main MATLAB script.

License
This code is provided for research purposes only. Please cite the relevant paper if you use this code in your work.

For queries, feel free to contact the author.
