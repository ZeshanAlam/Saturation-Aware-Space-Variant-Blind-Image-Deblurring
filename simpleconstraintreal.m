function [c, ceq, con1] = simpleconstraintreal(x, I, I_deglare, MTF, index, Yu)

    saturationThreshold = 254;
    AreaMax = 30000000;
    AreaMin = 5000;

    % Isolating saturated regions in input image
    maxI = max(I(:));
    Im = mean(I, 3);
    stats = regionprops(Im > saturationThreshold);
    count = 0;

    for i = 1:length(stats)
        if stats(i).Area > AreaMin && stats(i).Area < AreaMax % Data3
            count = count + 1;
            mask = Im * 0;
            I_one = Im * 0;
            I_all = Im > saturationThreshold;

            I_one((stats(i).BoundingBox(2)):floor(stats(i).BoundingBox(2)) + (stats(i).BoundingBox(4)), ...
                 (stats(i).BoundingBox(1)):floor(stats(i).BoundingBox(1)) + (stats(i).BoundingBox(3))) = 1;
            mask = I_all .* I_one * x(count);
            mask_stack(:, :, count) = mask;
        end
    end

    mask = sum(mask_stack, 3);

    %% Simulating glare for isolated saturated region
    pad_val = 0;

    for cc = 1:3
        [I_g(:, :, cc), I_d(:, :, cc)] = fast_conv_fft(gpuArray((mask)), MTF, pad_val);
    end

    I_glare = gather(I_g);
    I(I > saturationThreshold) = saturationThreshold; % Clipping saturated regions in input image

    for ii = 1:size(index, 1)
        T1(ii) = (I_glare(index(ii, 2)));
    end

    len = count;

    %% Simulating glare for isolated unsaturated region
    I(:, :, :) = I(:, :, :) .* (Im < saturationThreshold);
    Iu = I - I_deglare;

    for ii = 1:size(index, 1)
        T2(ii) = (Iu(index(ii, 2)));
    end

    T2 = T2';
    len2 = size(T1);

    %% Objective function
    X1 = x(1);
    X2 = x(2);
    X3 = x(3);
    t3 = (T1) + x(len + 1:len + len2)';

    %% No negative constraint
    A = x(1:len);

    for ii = 1:length(A)
        I_region(:, :, 1, ii) = mask_stack(:, :, ii);
        I_region(:, :, 2, ii) = mask_stack(:, :, ii);
        I_region(:, :, 3, ii) = mask_stack(:, :, ii);
    end

    I_sat = sum(I_region, 4);
    IG_predicted = I .* (I_sat == 0);
    IG_predicted = IG_predicted + I_sat;

    for cc = 1:3
        [I_g1(:, :, cc), I_ddec(:, :, cc)] = fast_deconv_fft(gpuArray(single(IG_predicted(:, :, cc))), MTF, pad_val);
    end

    I_ddecglare = gather(I_ddec);

    %% Constraint check
    ceq = [];
    c = [-x(1) - 255];
end
