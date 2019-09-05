CVR Hadamard-encoded multi-delay ASL data(HASL) postprocessing pipeline

Through this pipeline you can get the CBF, Transit time(TT) and transit time corrected CBF(ttcCBF) in Baseline and HyperCO2 states as well as change and change% for CBF, TT and ttcCBF.

Step1 is mainly the preprocessing: realign, coregistration, create brainmask. You need to eliminate non-brain tissues on structural image before running this script. 
Step2 is HASL quantification and CVR measurement.

HASL processing code is in the 'hasl_function' folder.

Notice: Please change the code_dir and data_dir as your own path.
        For different CO2 conditions in step2, I use ASL phases instead of the exact time. 
        For the 'test_data', it's 12sec per phase, 5 phases per ASL decoding loop(1 2 3 4 5), so 1 min for one loop. 
        The decoding works as long as there is at least one complete loop and it's not necessary to start from the 1st phase.
       
