function img = nii_load_dimg(nii_file)

    nii = load_nii(nii_file);
    img = double(nii.img);

end