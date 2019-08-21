
%--------------------------------------------------------------------------------------------------
% Step 2
% Purpose:Calculate pw, CBF, TT and ttCBF in BL and HC, and save nii
%         Calculate change and change%
% Prep:Run spm_realign.m to realign all phases in ASL to M0:rASL, rM0
%      Run step1 to create brainmask and gray matter masks and coregister them to rM0
%      Enter CO2 states according to the timeseries
%--------------------------------------------------------------------------------------------------

addpath /Users/tianyelin/Desktop/code_github/hasl_function
addpath /Users/tianyelin/Documents/MATLAB/Codes_CO2

normalCO2_state = [1:17, 33:47];
hyperCO2_state = [18:32, 48:60];  % ASL phase numbers

% % set path
subj_folder = '/Users/tianyelin/Desktop/P01';

hasl_asl_filename = 'rASL.nii';
hasl_m0_filename = 'rM0.nii';
brainmask_filename = 'rmask_MPRAGE_P01.nii'; 

hasl_asl_path = fullfile(subj_folder, 'ASL', hasl_asl_filename);
hasl_m0_path = fullfile(subj_folder, 'M0', hasl_m0_filename);
brainmask_path = fullfile(subj_folder, 'MPRAGE', brainmask_filename);
m0_path = nii_phase_extract(hasl_m0_path, 'm0', 1);

% % set parameters
asl_para = hasl_para_init();

asl_para.LD = 3.5; 
asl_para.PLD = 1;
asl_para.PLD_Num = 3;
asl_para.PLD_Lin = 1;
asl_para.T1b = 1.65;

asl_para = hasl_para_proc_state(asl_para);
asl_para = hasl_para_proc_ld_pld(asl_para);

% % smooth kernel
pixel_size = nii_pixel_size(hasl_asl_path);
smooth_kernel = msk_gen_kernel_gaussian(pixel_size, 6.0);

% % 
asl_img = nii_load_dimg(hasl_asl_path);
m0_img = nii_load_dimg(m0_path);

m0_msk = hasl_auto_msk(m0_img, 0.25);
brainmsk = nii_load_dimg(brainmask_path);
mask = m0_msk.* brainmsk;

phase_num = size(asl_img, 4);
state_num = asl_para.State_Num;
loop_num = phase_num./state_num;

% % 
normalCO2stat_img = asl_img(:,:,:,normalCO2_state);  
hyperCO2stat_img = asl_img(:,:,:,hyperCO2_state);  

% % decode hasl
normalCO2_hasl_img = hasl_anymean(normalCO2stat_img, asl_para, normalCO2_state, loop_num);  
normalCO2_hasl_pw = hasl_decode(normalCO2_hasl_img, asl_para);

hyperCO2_hasl_img = hasl_anymean(hyperCO2stat_img, asl_para, hyperCO2_state, loop_num);  
hyperCO2_hasl_pw = hasl_decode(hyperCO2_hasl_img, asl_para);

% %  
nii = load_nii(hasl_m0_path);

% %  CBF,Transit time,ttCBF calculation in different CO2 state
normalCO2cbf_img = hasl_cbf(normalCO2_hasl_pw, m0_img, mask, asl_para);
normalCO2cbf_img = hasl_filter_apply(normalCO2cbf_img, mask, smooth_kernel);  

hyperCO2cbf_img = hasl_cbf(hyperCO2_hasl_pw, m0_img, mask, asl_para);
hyperCO2cbf_img = hasl_filter_apply(hyperCO2cbf_img, mask, smooth_kernel);  

normalCO2tt_img = hasl_calc_tt(normalCO2_hasl_pw, mask, asl_para);
normalCO2tt_img = hasl_filter_apply(normalCO2tt_img, mask, smooth_kernel);

hyperCO2tt_img = hasl_calc_tt(hyperCO2_hasl_pw, mask, asl_para);
hyperCO2tt_img = hasl_filter_apply(hyperCO2tt_img, mask, smooth_kernel);
    
normalCO2ttccbf_img = hasl_ttccbf(normalCO2_hasl_pw, m0_img, normalCO2tt_img, mask, asl_para);
normalCO2ttccbf_img = hasl_filter_apply(normalCO2ttccbf_img, mask, smooth_kernel);

hyperCO2ttccbf_img = hasl_ttccbf(hyperCO2_hasl_pw, m0_img, hyperCO2tt_img, mask, asl_para);
hyperCO2ttccbf_img = hasl_filter_apply(hyperCO2ttccbf_img, mask, smooth_kernel);

% % save nii for normalCO2(BL) and hyperCO2(HC) state CBF, Transit Time and ttCBF
nii.hdr.dime.dim(5)=1; 
nii.img = normalCO2cbf_img(:,:,:,4); 
save_nii(nii, fullfile(subj_folder, 'output/nii/normalCO2_cbf.nii'));
nii.hdr.dime.dim(5)=1;
nii.img = hyperCO2cbf_img(:,:,:,4);
save_nii(nii, fullfile(subj_folder, 'output/nii/hyperCO2_cbf.nii'));

nii.hdr.dime.dim(5)=1;   
nii.img = normalCO2ttccbf_img(:,:,:,4); 
save_nii(nii, fullfile(subj_folder, 'output/nii/normalCO2_ttcbf.nii'));
nii.hdr.dime.dim(5)=1;
nii.img = hyperCO2ttccbf_img(:,:,:,4);
save_nii(nii, fullfile(subj_folder, 'output/nii/hyperCO2_ttcbf.nii'));

normalCO2tt_img = normalCO2tt_img.*1000; % *1000:change unit from 's' to 'ms'
nii.hdr.dime.dim(5)=1;
nii.img = normalCO2tt_img;
save_nii(nii, fullfile(subj_folder,'output/nii/normalCO2_tt.nii'));
hyperCO2tt_img = hyperCO2tt_img.*1000;
nii.hdr.dime.dim(5)=1;
nii.img = hyperCO2tt_img;
save_nii(nii, fullfile(subj_folder,'output/nii/hyperCO2_tt.nii'));


% % save change and change% of CBF, tt and ttCBF between BL and HC
diff_cbf_img = hyperCO2cbf_img(:,:,:,4) - normalCO2cbf_img(:,:,:,4);
nii.img = diff_cbf_img;
save_nii(nii, fullfile(subj_folder, 'output/nii/diff_cbf.nii'));

cbf_ratio_img = (diff_cbf_img./normalCO2cbf_img(:,:,:,4)).*100;
nii.img = cbf_ratio_img;
save_nii(nii, fullfile(subj_folder, 'output/nii/change%_cbf.nii'));

diff_ttccbf_img = hyperCO2ttccbf_img(:,:,:,4) - normalCO2ttccbf_img(:,:,:,4);
nii.img = diff_ttccbf_img;
save_nii(nii, fullfile(subj_folder, 'output/nii/diff_ttcbf.nii'));

ttccbf_ratio_img = (diff_ttccbf_img./normalCO2ttccbf_img(:,:,:,4)).*100;
nii.img = ttccbf_ratio_img;
save_nii(nii, fullfile(subj_folder, 'output/nii/change%_ttcbf.nii'));

diff_tt_img = normalCO2tt_img - hyperCO2tt_img;
nii.img = diff_tt_img;
save_nii(nii, fullfile(subj_folder, 'output/nii/diff_tt.nii'));

tt_ratio_img = (diff_tt_img./normalCO2tt_img).*100;
nii.img = tt_ratio_img;
save_nii(nii, fullfile(subj_folder, 'output/nii/change%_tt.nii'));

