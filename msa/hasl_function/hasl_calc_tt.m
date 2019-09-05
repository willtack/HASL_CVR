function img_tt = hasl_calc_tt(img_pw, img_msk, asl_para)

    funcname = 'hasl_calc_tt';

    T1b = asl_para.T1b;
    T1t = asl_para.T1t;

    LD_arr = asl_para.LD_arr;
    PLD_arr = asl_para.PLD_arr;
    
    if asl_para.PLD_Num == 1
        error(['#### ', funcname, ': TT needs Multi-Delay ASL']);
    end
    
    [wsum, tt] = hasl_gen_wsum(LD_arr(1:end-1), PLD_arr(1:end-1), T1b, T1t);
    
    pw_sum = zeros(size(img_msk));
    
    pw_pld_sum = zeros(size(img_msk));
    
    img_tt = zeros(size(img_msk));
    
    for pld_idx = 1: size(img_pw, 4)
        
        pw_sum = pw_sum + img_pw(:,:,:,pld_idx);
        pw_pld_sum = pw_pld_sum + img_pw(:,:,:,pld_idx) * PLD_arr(pld_idx);
        
    end
    
    pld_wsum = pw_pld_sum ./ (abs(pw_sum) + eps);
    
    wsum_min = min(wsum);
    wsum_max = max(wsum);
    
    pld_wsum(pld_wsum < wsum_min) = wsum_min;
    pld_wsum(pld_wsum > wsum_max) = wsum_max;
    
    msk_ind = find(img_msk > 0);
    
    img_tt(msk_ind) = interp1(wsum, tt, pld_wsum(msk_ind));

end