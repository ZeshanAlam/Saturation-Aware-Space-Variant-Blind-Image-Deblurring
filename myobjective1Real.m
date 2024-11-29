function y = myobjective1Real(x, I, I_deglare, MTF, index, Yu)
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

    %% Simulating LSF for isolated saturated region
    pad_val = 0;

    for cc = 1:3
        [I_g(:, :, cc), I_d(:, :, cc)] = fast_conv_fft(gpuArray((mask)), MTF, pad_val);
    end

    I_glare = gather(I_g);

    % Clipping saturated regions in input image
    I(I > saturationThreshold) = saturationThreshold;

    for ii = 1:size(index, 1)
        T1(ii) = (I_glare(index(ii, 2)));
    end

    len = count;

    %% Simulating glare for isolated unsaturated region
    I(:, :, :) = I(:, :, :) .* ((Im < saturationThreshold));
    Iu = I - I_deglare;

    for ii = 1:size(index, 1)
        T2(ii) = (Iu(index(ii, 2)));
    end

    T2 = T2';
    len2 = size(T1);

    %% Objective function
    X1 = x(1);

    y1 = Yu - T1' - x(len + 1:len + len2)' - T2;
    y = norm(y1(:));
end
