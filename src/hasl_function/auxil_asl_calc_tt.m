function img_tt = auxil_asl_calc_tt(img_pw, img_msk, asl_para)
% calculate transit time map based using the weighted sum method
% 
% FORMAT: [img_tt] = auxil_asl_calc_tt(img_pw, img_msk, asl_para)
% 
% INPUT:
%   img_pw - perfusion weighted volume/slice array
%   img_msk - image volume
%   asl_para - ASL sequence parameter structure
%
% OUTPUT:
%   img_tt - transit time map
%                         
% -------------------------------------------------------------------------
% DESCRIPTION:  ...
% -------------------------------------------------------------------------
% EXAMPLE:      ...
% -------------------------------------------------------------------------
%                                           Jianxun Qu, @jianxun_qu@163.com
% -------------------------------------------------------------------------

    T1b = asl_para.T1b;
    T1t = asl_para.T1t;

    LD_arr = asl_para.LD_arr;
    PLD_arr = asl_para.PLD_arr;
    
    PLD_num = length(PLD_arr);
    
    [wsum, tt] = auxil_asl_gen_wsum(LD_arr, PLD_arr, T1b, T1t);
    
    pw_sum = zeros(size(img_msk));
    
    pw_pld_sum = zeros(size(img_msk));
    
    img_tt = zeros(size(img_msk));
    
    for pld_idx = 1: PLD_num
        
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