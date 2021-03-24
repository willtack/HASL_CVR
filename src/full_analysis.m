<<<<<<< HEAD
function []=full_analysis(aslpath, m0path, mpragepath, outputdir)
=======
function []=full_analysis(aslpath, m0path, mpragepath, hyperC02, stimulus_start, outputdir)
>>>>>>> 4d0410692edfc486821256d898544b48d4c43d84

%--------------------------------------------------------------------------------------------------
% Step 1
% Preparation: Brain extraction from MPRAGE to get 'MPRAGE_brain.nii'
% Purpose: Realign all phases in ASL to M0
%          create resampled brainmask
%--------------------------------------------------------------------------------------------------
fprintf("Starting Step 1")
subj_folder = outputdir; % data dir
<<<<<<< HEAD
% stimulus_start = str2double(stimulus_start);
% hyperC02 = logical(str2double(hyperC02));
=======
stimulus_start = str2double(stimulus_start);
hyperC02 = logical(str2double(hyperC02));
>>>>>>> 4d0410692edfc486821256d898544b48d4c43d84
% hyperC02_bool = logical(hyperC02);

[~, asl_name, asl_ext] = fileparts(aslpath);
[~, m0_name, m0_ext] = fileparts(m0path);
[~, mprage_name, mprage_ext] = fileparts(mpragepath);

asl_img = nii_load_dimg(aslpath);
asl_phase_num = size(asl_img, 4);

% create output folders
outASLdir = fullfile(subj_folder, 'ASL');
mkdir(outASLdir);
outM0dir = fullfile(subj_folder, 'M0');
mkdir(outM0dir);
outMPRAGEdir = fullfile(subj_folder, 'MPRAGE');
mkdir(outMPRAGEdir);

% copy inputs over to output folder
copyfile(aslpath, outASLdir);
copyfile(m0path, outM0dir);
copyfile(mpragepath, outMPRAGEdir);

% define the analytes (out_*) and derivatives (r*) that are now in or will be in 
% the output folder
% if inputs are gzipped, unzip and reassign out_X_path to
% be the .nii NOT the .nii.gz

out_ASL_path = fullfile(outASLdir, strcat(asl_name, asl_ext));
out_M0_path = fullfile(outM0dir, strcat(m0_name, m0_ext));
out_skullstrippedbrain_path = fullfile(outMPRAGEdir, strcat(mprage_name, mprage_ext)); 
rM0_path = fullfile(outM0dir, strcat('r',m0_name, m0_ext));
rskullstrippedbrain_path = fullfile(outMPRAGEdir, strcat('r',mprage_name, mprage_ext));

gz = false; 
if strcmp(asl_ext, '.gz')
    gunzip(out_ASL_path, outASLdir);
    out_ASL_path = fullfile(outASLdir, asl_name);
    asl_ext = '';
end
if strcmp(m0_ext, '.gz')
    gz = true;
    gunzip(out_M0_path, outM0dir);
    out_M0_path = fullfile(outM0dir, m0_name);
    rM0_path = fullfile(outM0dir, strcat('r',m0_name));
    m0_ext = '';
end
if strcmp(mprage_ext, '.gz')
    gunzip(out_skullstrippedbrain_path, outMPRAGEdir);
    out_skullstrippedbrain_path = fullfile(outMPRAGEdir, mprage_name);
    rskullstrippedbrain_path = fullfile(outMPRAGEdir, strcat('r',mprage_name));
end


% check if M0 contains multiple volumes
[m0_nii_hdr, ~, ~, ~] = load_nii_hdr(out_M0_path);
if m0_nii_hdr.dime.dim(5) > 1
    spm_file_split(out_M0_path, outM0dir);
    if gz 
        [~, m0_basename, m0_ext] = fileparts(m0_name);
    else
        [~, m0_basename, m0_ext] = fileparts(strcat(m0_name, m0_ext));
    end
    m0_basename = strcat(m0_basename, '_00001');
    m0_name = strcat(m0_basename, m0_ext);
    out_M0_path = fullfile(outM0dir, strcat(m0_basename, m0_ext));   
    rM0_path = fullfile(outM0dir, strcat('r',m0_basename, m0_ext));
end

% realign all ASL phases to M0
fprintf("starting realignment")
spm_realign_hasl(out_M0_path, out_ASL_path, asl_phase_num)

% skullstrippedbrain resliced to rM0
fprintf("reslicing to M0")
spm_coreg_reslice({rM0_path},{out_skullstrippedbrain_path},{''});

% save skullstripped mask
rskullstrippedbrain_img = nii_load_dimg(rskullstrippedbrain_path);

rskullstrippedbrain_img(rskullstrippedbrain_img>0)=1;
rskullstrippedbrain_img(rskullstrippedbrain_img<=0)=0;

nii = load_nii(rM0_path);
nii.img = rskullstrippedbrain_img;
save_nii(nii, fullfile(subj_folder,'MPRAGE/brain_mask.nii'))


%--------------------------------------------------------------------------------------------------
% Step 2
% Preparation: Run step1
%              Enter CO2 states according to the timeseries
% Purpose:Decode Hadamard matrix
%         Calculate CBF, transit time and ttCBF in Baseline and HyperCO2 states, save nii
%         Calculate CVR, save change and change% nii
%--------------------------------------------------------------------------------------------------



hasl_asl_filename = strcat('r', asl_name, asl_ext);
hasl_m0_filename = strcat('r', m0_name, m0_ext);
brainmask_filename = 'brain_mask.nii';

hasl_asl_path = fullfile(subj_folder, 'ASL', hasl_asl_filename);
hasl_m0_path = fullfile(subj_folder, 'M0', hasl_m0_filename);
brainmask_path = fullfile(subj_folder, 'MPRAGE', brainmask_filename);
brainmsk = nii_load_dimg(brainmask_path);
m0_path = nii_phase_extract(hasl_m0_path, 'M0', 1);

% % set parameters
<<<<<<< HEAD
asl_para = auxil_asl_para_init();

asl_para.LD = 3.5;
asl_para.PLD = 1;
asl_para.PLD_Num = 7;
asl_para.PLD_Lin = 0.5;
asl_para.T1b = 1.65;
asl_para = auxil_asl_para_proc_state(asl_para);
asl_para = auxil_asl_para_proc_ld_pld(asl_para);

% % smooth kernel
pixel_size = nii_pixel_size(hasl_asl_path);
flt_kernel = auxil_msk_gen_kernel_gaussian(pixel_size, 2.5);
=======
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
smooth_kernel = msk_gen_kernel_gaussian(pixel_size, 4.0);
>>>>>>> 4d0410692edfc486821256d898544b48d4c43d84

% %
asl_img = nii_load_dimg(hasl_asl_path);
m0_img = nii_load_dimg(m0_path);

phase_num = size(asl_img, 4);
state_num = asl_para.State_Num;
loop_num = phase_num./state_num;

<<<<<<< HEAD
%     state = 1:phase_num;
asl_img = auxil_asl_mean(asl_img, asl_para);
pw_img = auxil_hasl_decode(asl_img, asl_para);

pw_img = convn(pw_img, flt_kernel, 'same');

tt_img = auxil_asl_calc_tt(pw_img, brainmsk, asl_para);

cbf_img = auxil_asl_cbf(pw_img, m0_img, brainmsk, asl_para);
cbf_img = auxil_asl_filter_apply(cbf_img, brainmsk, flt_kernel);
% tt_img = auxil_asl_calc_tt(pw_img, brainmsk, asl_para);
% tt_img = auxil_asl_filter_apply(tt_img, brainmsk, flt_kernel);
ttccbf_img = auxil_asl_ttccbf(pw_img, m0_img, tt_img, brainmsk, asl_para);

nii = load_nii(hasl_m0_path);

% % save nii for CBF, Transit Time and ttCBF
nii.hdr.dime.dim(5)=1;
nii.img = cbf_img(:,:,:,4);
save_nii(nii, fullfile(subj_folder, 'cbf.nii'));

nii.hdr.dime.dim(5)=1;
nii.img = ttccbf_img(:,:,:,4);
save_nii(nii, fullfile(subj_folder, 'ttcbf.nii'));

tt_img = tt_img.*1000; % *1000:change unit from 's' to 'ms'
nii.hdr.dime.dim(5)=1;
nii.img = tt_img;
save_nii(nii, fullfile(subj_folder,'tt.nii'));
=======
nii = load_nii(hasl_m0_path);


% % % % %
if ~hyperC02
    state = 1:phase_num;
    hasl_img = hasl_anymean(asl_img, asl_para, state, loop_num);
    hasl_pw = hasl_decode(hasl_img, asl_para);
    cbf_img = hasl_cbf(hasl_pw, m0_img, brainmsk, asl_para);
    cbf_img = hasl_filter_apply(cbf_img, brainmsk, smooth_kernel);
    tt_img = hasl_calc_tt(hasl_pw, brainmsk, asl_para);
    tt_img = hasl_filter_apply(tt_img, brainmsk, smooth_kernel);
    ttccbf_img = hasl_ttccbf(hasl_pw, m0_img, tt_img, brainmsk, asl_para);
    
    % % save nii for CBF, Transit Time and ttCBF
    nii.hdr.dime.dim(5)=1;
    nii.img = cbf_img(:,:,:,4);
    save_nii(nii, fullfile(subj_folder, 'cbf.nii'));

    nii.hdr.dime.dim(5)=1;
    nii.img = ttccbf_img(:,:,:,4);
    save_nii(nii, fullfile(subj_folder, 'ttcbf.nii'));

    tt_img = tt_img.*1000; % *1000:change unit from 's' to 'ms'
    nii.hdr.dime.dim(5)=1;
    nii.img = tt_img;
    save_nii(nii, fullfile(subj_folder,'tt.nii'));
    
else
    
    normalCO2_state = 1:stimulus_start-3;
    hyperCO2_state = stimulus_start:phase_num;  % ASL phase numbers

    % %
    normalCO2stat_img = asl_img(:,:,:,normalCO2_state);
    hyperCO2stat_img = asl_img(:,:,:,hyperCO2_state);

    % % decode hasl
    normalCO2_hasl_img = hasl_anymean(normalCO2stat_img, asl_para, normalCO2_state, loop_num);
    normalCO2_hasl_pw = hasl_decode(normalCO2_hasl_img, asl_para);

    hyperCO2_hasl_img = hasl_anymean(hyperCO2stat_img, asl_para, hyperCO2_state, loop_num);
    hyperCO2_hasl_pw = hasl_decode(hyperCO2_hasl_img, asl_para);

    % %  CBF,Transit time,ttCBF calculation in different CO2 state
    normalCO2cbf_img = hasl_cbf(normalCO2_hasl_pw, m0_img, brainmsk, asl_para);
    normalCO2cbf_img = hasl_filter_apply(normalCO2cbf_img, brainmsk, smooth_kernel);

    hyperCO2cbf_img = hasl_cbf(hyperCO2_hasl_pw, m0_img, brainmsk, asl_para);
    hyperCO2cbf_img = hasl_filter_apply(hyperCO2cbf_img, brainmsk, smooth_kernel);

    normalCO2tt_img = hasl_calc_tt(normalCO2_hasl_pw, brainmsk, asl_para);
    normalCO2tt_img = hasl_filter_apply(normalCO2tt_img, brainmsk, smooth_kernel);

    hyperCO2tt_img = hasl_calc_tt(hyperCO2_hasl_pw, brainmsk, asl_para);
    hyperCO2tt_img = hasl_filter_apply(hyperCO2tt_img, brainmsk, smooth_kernel);

    normalCO2ttccbf_img = hasl_ttccbf(normalCO2_hasl_pw, m0_img, normalCO2tt_img, brainmsk, asl_para);
    normalCO2ttccbf_img = hasl_filter_apply(normalCO2ttccbf_img, brainmsk, smooth_kernel);

    hyperCO2ttccbf_img = hasl_ttccbf(hyperCO2_hasl_pw, m0_img, hyperCO2tt_img, brainmsk, asl_para);
    hyperCO2ttccbf_img = hasl_filter_apply(hyperCO2ttccbf_img, brainmsk, smooth_kernel);

    % % save nii for normalCO2(BL) and hyperCO2(HC) state CBF, Transit Time and ttCBF
    nii.hdr.dime.dim(5)=1;
    nii.img = normalCO2cbf_img(:,:,:,4);
    save_nii(nii, fullfile(subj_folder, 'normalCO2_cbf.nii'));
    nii.hdr.dime.dim(5)=1;
    nii.img = hyperCO2cbf_img(:,:,:,4);
    save_nii(nii, fullfile(subj_folder, 'hyperCO2_cbf.nii'));

    nii.hdr.dime.dim(5)=1;
    nii.img = normalCO2ttccbf_img(:,:,:,4);
    save_nii(nii, fullfile(subj_folder, 'normalCO2_ttcbf.nii'));
    nii.hdr.dime.dim(5)=1;
    nii.img = hyperCO2ttccbf_img(:,:,:,4);
    save_nii(nii, fullfile(subj_folder, 'hyperCO2_ttcbf.nii'));

    normalCO2tt_img = normalCO2tt_img.*1000; % *1000:change unit from 's' to 'ms'
    nii.hdr.dime.dim(5)=1;
    nii.img = normalCO2tt_img;
    save_nii(nii, fullfile(subj_folder,'normalCO2_tt.nii'));
    hyperCO2tt_img = hyperCO2tt_img.*1000;
    nii.hdr.dime.dim(5)=1;
    nii.img = hyperCO2tt_img;
    save_nii(nii, fullfile(subj_folder,'hyperCO2_tt.nii'));


    % % save change and change% of CBF, tt and ttCBF between BL and HC
    diff_cbf_img = hyperCO2cbf_img(:,:,:,4) - normalCO2cbf_img(:,:,:,4);
    nii.img = diff_cbf_img;
    save_nii(nii, fullfile(subj_folder, 'diff_cbf.nii'));

    cbf_ratio_img = (diff_cbf_img./normalCO2cbf_img(:,:,:,4)).*100;
    nii.img = cbf_ratio_img;
    save_nii(nii, fullfile(subj_folder, 'change%_cbf.nii'));

    diff_ttccbf_img = hyperCO2ttccbf_img(:,:,:,4) - normalCO2ttccbf_img(:,:,:,4);
    nii.img = diff_ttccbf_img;
    save_nii(nii, fullfile(subj_folder, 'diff_ttcbf.nii'));

    ttccbf_ratio_img = (diff_ttccbf_img./normalCO2ttccbf_img(:,:,:,4)).*100;
    nii.img = ttccbf_ratio_img;
    save_nii(nii, fullfile(subj_folder, 'change%_ttcbf.nii'));

    diff_tt_img = normalCO2tt_img - hyperCO2tt_img;
    nii.img = diff_tt_img;
    save_nii(nii, fullfile(subj_folder, 'diff_tt.nii'));

    tt_ratio_img = (diff_tt_img./normalCO2tt_img).*100;
    nii.img = tt_ratio_img;
    save_nii(nii, fullfile(subj_folder, 'change%_tt.nii'));
end
>>>>>>> 4d0410692edfc486821256d898544b48d4c43d84
