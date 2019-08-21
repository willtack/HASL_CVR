CVR Hadamard-encoded multi-delay ASL data(HASL_CVR) postprocessing pipline

To processing Hadamard multi-delay ASL data you just need to run the step1 and step2 scripts.

Step1 is mainly the preprocessing procedure: realign, segmentation, coregisteration etc.
Notice: Three functions in Step1(line11-line13) are not included in this repository because they are not mine, I just used them
        PAR = setpar;
        batch_segment(PAR);
        batch_create_mask(PAR); 
