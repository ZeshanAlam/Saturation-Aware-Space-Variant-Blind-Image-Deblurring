function [IG_predicted] = Saturated_glare(IR_glare, Dark, darkPixelIndices, saturationThreshold)
    % Camera params for conversion factor
    Cgain = 16;
    maxExp = 9.765625;
    k = 0.34240133333333334;
    bit_depth = 8;
    Nimages = 0;
    gamma = 2.2;

    %% Loading images
    IR_glare = double(IR_glare);
    Nimages = Nimages + 1;
    I = IR_glare;
    Imax = max(I(:));
    CF = ((2^bit_depth) - 1) / (k * maxExp * Imax * Cgain); % Conversion of radiance values to digital values

    %% Simulating LSF
    if Nimages == 1
        % Camera resolution height
        % camera_res_height = 5320; % Sony
        camera_res_height = 1936; % IDS
        scale_factor = (size(I, 1) / camera_res_height); % Resolution reduction factor (relative to the original camera resolution)
        sz = [size(I, 1), size(I, 2)];
        pad_val = 0;

        % Select camera model
        % selected_gsf = @(R) camera_gsf(R, 'Sony-55mm-F1.8');
        selected_gsf = @(R) camera_gsf(R, 'IDS-APmax');

        GSF = gsf2filter(sz * 2, scale_factor, selected_gsf);
        GSF_gpu = gpuArray(single(GSF));
        MTF = abs(fft2(GSF_gpu));
        MTFt = MTF;
        GSFMax = 1;
    end

    %% Estimate saturated pixels in images
    [IG_predicted] = SaturatedPix_estimateReal(IR_glare, MTF, MTFt, CF, GSFMax, IR_glare, Dark, darkPixelIndices, saturationThreshold);
end
