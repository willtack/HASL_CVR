function img = auxil_img_rot_chop_erd(img)

    edge_chop = 8;

    img = rot90(img);
    
    img = auxil_img_chop(img, edge_chop);
    
    msk = zeros(size(img));
    msk(img>0) = 1;
    msk = imerode(msk, strel('sphere',1));
    
    img = img .* msk;

end