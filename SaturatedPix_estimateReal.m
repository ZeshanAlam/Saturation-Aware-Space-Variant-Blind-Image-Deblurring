%% This code estimates saturated pixels in images using Dark channel prior

function [I1] = SaturatedPix_estimateReal(I, MTF, MTFt, CF, GSFMax, Iorg, D, index, saturationThreshold)

    %% Isolating saturated regions in input image
    AreaMax = 30000000;
    AreaMin = 5000;
    I_return = I;
    maxI = max(I(:));
    Im = mean(I, 3);

    stats = regionprops(Im > saturationThreshold);
    count = 0;
    Iwc = I;

    for i = 1:length(stats)
        if stats(i).Area > AreaMin && stats(i).Area < AreaMax % Archive boxes
            count = count + 1;
            mask = Im * 0;
            I_one = Im * 0;
            I_all = Im > saturationThreshold;

            I_one((stats(i).BoundingBox(2)):floor(stats(i).BoundingBox(2)) + (stats(i).BoundingBox(4)), ...
                  (stats(i).BoundingBox(1)):floor(stats(i).BoundingBox(1)) + (stats(i).BoundingBox(3))) = 1;
            mask = I_all .* I_one;

    
            mask_stack(:, :, count) = mask;

            %% Simulating glare for isolated saturated region
            pad_val = 0;

            for cc = 1:3
                [I_g(:, :, cc), I_d(:, :, cc)] = fast_conv_fft(gpuArray((mask)), MTF, pad_val);
            end

            I_glare = gather(I_g);
            I(I > saturationThreshold) = saturationThreshold; % Clipping saturated regions in input image
        end
    end

    if count > 0
        %% Simulating glare for isolated unsaturated region
        pad_val = 0;
        I(:, :, :) = (I(:, :, :)) .* (Im < saturationThreshold);

        for cc = 1:3 % Approximate unsaturated image by deconvolving clipped saturated image with GSF
            [I_g(:, :, cc), I_d(:, :, cc)] = fast_deconv_fft(gpuArray((I(:, :, cc))), MTF, pad_val);
        end

        I_deglare = gather(I_d);
        Umask = I < 1;
        I_deglare = I_deglare .* Umask;

        %% Estimating all saturated regions in the input image
        ObjectiveFunction = @myobjective1;
        len = count;

        patch = 4;

        X0 = zeros(1, len + patch) + 255; % Starting point
        LB = zeros(1, len + patch) + 1; % Lower bound
        UB = zeros(1, len + patch) + 285; % Upper bound
        X0(len + 1:len + patch) = 0;
        LB(len + 1:len + patch) = 0;
        UB(len + 1:len + patch) = 0.009;

        maxIwc = max(Iwc(:));
        options = optimoptions(@patternsearch, 'MaxIterations', 4, 'TolCon', 1e-6, ...
                               'MaxFunEvals', 2000000 * 12 * 3, 'PlotFcn', @psplotbestf);

        ConstraintFunction = @simpleconstraintreal;
        [x, fval] = patternsearch(@(x) myobjective1Real(double(x), (Iwc), (I_deglare), MTF, double(index), double(D)), ...
                                  double(X0), [], [], [], [], double(LB), double(UB), ...
                                  @(x) ConstraintFunction(double(x), (Iwc), (I_deglare), MTF, double(index), double(D)), options);

        I_region = [];
        A = x(1:len);

        for ii = 1:length(A)
            I_region(:, :, 1, ii) = mask_stack(:, :, ii) * A(ii);
            I_region(:, :, 2, ii) = mask_stack(:, :, ii) * A(ii);
            I_region(:, :, 3, ii) = mask_stack(:, :, ii) * A(ii);
        end

        I_sat = sum(I_region, 4);

        for ii = 1:length(A)
            Iwc(:, :, 1) = (Iwc(:, :, 1)) .* (mask_stack(:, :, ii) == 0);
            Iwc(:, :, 2) = (Iwc(:, :, 2)) .* (mask_stack(:, :, ii) == 0);
            Iwc(:, :, 3) = (Iwc(:, :, 3)) .* (mask_stack(:, :, ii) == 0);
        end

        I1 = Iwc + (I_sat);
        for jj = 1:count
            if A(jj) < saturationThreshold
                I1 = I_return;
            end
        end
    else
        patch = 4;
        I1 = I_return;
        index = [0 0; 0 0; 0 0; 0 0];
    end
end
