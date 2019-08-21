CVR Hadamard-encoded multi-delay ASL data(HASL_CVR) postprocessing pipeline

To process Hadamard multi-delay ASL data you just need to run the step1 and step2 scripts.
Through this pipeline you can get the CBF, Transit time(TT) and transit time corrected CBF(tcCBF) in Baseline and HyperCO2 states as well as change and change% for CBF, TT and tcCBF.

Step1 is mainly the preprocessing: realign, segmentation, coregisteration etc.
Step2 is the HASL postprocessing.

Notice: 1. Three functions: setpar,batch_segment(PAR),batch_create_mask(PAR)(line11-13) in Step1 are not included in this
           repository because they are not mine, please refer to the 'batch_run.m' from zhengjun.
        2. For step2, I use ASL phase instead of the exact time to divide the different CO2 conditions. 
           It's 12s per phase, 5 phases per ASL decoding loop(1 2 3 4 5), so 1min for one loop. 
           We usually do 3min for one CO2 block, so the ideal condition is 3 loops in each CO2 block, but please change it
           according to the actual condition.
           The decoding will work as long as there is at least one complete loop and it's not necessarily to start from 1. 
        
            
