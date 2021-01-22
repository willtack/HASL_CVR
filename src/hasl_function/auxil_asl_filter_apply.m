function img_out = auxil_asl_filter_apply(img_in, img_msk, kernel)

    kernel = kernel / sum(kernel(:));
    
    img_out = convn(img_in, kernel, 'same');
    
    img_out(img_msk <= 0) = 0;

end