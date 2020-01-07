function msk = msk_gen_kernel_gaussian(voxel_xyz, radius_r)

    radius_xyz = radius_r * ones(size(voxel_xyz));

    size_xyz = ceil( radius_xyz ./ voxel_xyz ) * 2 + 1;
    
    center_xyz = (size_xyz + 1)/2;

    dist = zeros(size_xyz);
    
    for ix = 1:size_xyz(1)
        for iy = 1:size_xyz(2)
            for iz = 1:size_xyz(3)
                
                dist_curr = 0;
                
                dist_curr = dist_curr + ( ( ix - center_xyz(1) ) * voxel_xyz(1) )^2;
                dist_curr = dist_curr + ( ( iy - center_xyz(2) ) * voxel_xyz(2) )^2;
                dist_curr = dist_curr + ( ( iz - center_xyz(3) ) * voxel_xyz(3) )^2;
                
                dist_curr = sqrt(dist_curr);
                
                dist(ix, iy, iz) = dist_curr;
                
            end
        end
    end

    msk = exp( - dist.^2 / radius_r^2 );
    
    msk = msk / sum(msk(:));
    
end