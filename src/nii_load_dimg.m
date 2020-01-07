function img = nii_load_dimg(nii_file)

    nii = nifti_utils/load_nii(nii_file);
    img = double(nii.img);

end
