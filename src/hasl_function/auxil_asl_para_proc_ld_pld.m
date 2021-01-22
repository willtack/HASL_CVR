function asl_para = auxil_asl_para_proc_ld_pld(asl_para)

    ld_tot  = asl_para.LD;
    pld_tot = asl_para.PLD;
    pld_num = asl_para.PLD_Num;
    pld_lin = asl_para.PLD_Lin;
    T1b     = asl_para.T1b;
    
    [ld_arr, pld_arr] = auxil_asl_calc_ld_pld(ld_tot, pld_tot, pld_num, pld_lin, T1b);
    
    asl_para.LD_arr = [ld_arr, ld_tot];
    asl_para.PLD_arr = [pld_arr, pld_tot];

end