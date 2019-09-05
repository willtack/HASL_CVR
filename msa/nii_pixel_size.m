function pixel_size = nii_pixel_size(nii_path)

    nii = load_untouch_nii(nii_path);
    
    pixdim = nii.hdr.dime.pixdim;
    
    pixel_size = pixdim(2:4);
    
end