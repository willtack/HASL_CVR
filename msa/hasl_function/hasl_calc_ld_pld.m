function [ld, pld] = hasl_calc_ld_pld(ld_tot, pld_tot, pld_num, pld_lin, T1b)

    sig_total = exp(-pld_tot / T1b) * (1-exp(-ld_tot / T1b));
    sig_seg = sig_total / pld_num;
    
    pldE(1) = pld_tot;
    ldE(1) = -T1b * log( 1 - sig_seg*exp( pldE(1) / T1b ) );
    
    for idx = 2: pld_num
        
        pldE(idx) = ldE(idx - 1) + pldE(idx - 1);
        ldE(idx) = -T1b * log( 1 - sig_seg * exp( pldE(idx) / T1b ) );
        
    end
    
    ldL = ld_tot / pld_num;
    pldL = pld_tot: ldL: (pld_tot + ldL * (pld_num - 1) );
    
    pld = pld_lin * pldL + (1 - pld_lin) * pldE;
    ld = pld_lin * ldL + (1 - pld_lin) * ldE;
    
end