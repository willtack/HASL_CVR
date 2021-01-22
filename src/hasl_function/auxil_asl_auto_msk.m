function [img_msk] = auxil_asl_auto_msk(img_m0, scale)

    if nargin < 2
        scale = 1.0;
    end

    msk_threshold = sum(img_m0(:).^2) / sum(img_m0(:)) * scale;
    img_msk = ones(size(img_m0));
    img_msk(img_m0 <= msk_threshold) = 0;

end