function img_mosaic = auxil_nimg_disp(img, mosaic_mat)

    img = rot90(flip(img));
    
    img_mosaic = mosaic(img, mosaic_mat);

end