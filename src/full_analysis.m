function []=full_analysis(aslpath, m0path, mpragepath, outputdir)

%--------------------------------------------------------------------------------------------------
% Step 1
% Preparation: Brain extraction from MPRAGE to get 'MPRAGE_brain.nii'
% Purpose: Realign all phases in ASL to M0
%          create resampled brainmask
%--------------------------------------------------------------------------------------------------
fprintf("Starting Step 1")
subj_folder = outputdir; % data dir

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
asl_para = auxil_asl_para_init();

asl_para.LD = 3.5;
asl_para.PLD = 1.0;
asl_para.PLD_Num = 7;
asl_para.PLD_Lin = 0.5;
asl_para.T1b = 1.65;
asl_para = auxil_asl_para_proc_state(asl_para);
asl_para = auxil_asl_para_proc_ld_pld(asl_para);

% % smooth kernel
pixel_size = nii_pixel_size(hasl_asl_path);
flt_kernel = auxil_msk_gen_kernel_gaussian(pixel_size, 2.5);

% %
asl_img = nii_load_dimg(hasl_asl_path);
m0_img = nii_load_dimg(m0_path);

phase_num = size(asl_img, 4);
state_num = asl_para.State_Num;
loop_num = phase_num./state_num;

%     state = 1:phase_num;
asl_img = auxil_asl_mean(asl_img, asl_para);
pw_img = auxil_hasl_decode(asl_img, asl_para);

pw_img = convn(pw_img, flt_kernel, 'same');

% save perfusion-weighted image
nii = load_nii(hasl_asl_path);
nii.img = pw_img;
nii.hdr.dime.dim(5) = 8; % 7 PLDs + 1 control
save_nii(nii, fullfile(subj_folder, 'pw.nii'))

% ninfo = niftiinfo(m0path);
% ninfo.ImageSize(4) = 7 % 7 PLDs
% niftiwrite(pw_img, fullfile(subj_folder, 'pw'), ninfo);

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
save_nii(nii, fullfile(subj_folder, 'ttcbf4.nii'));

nii.hdr.dime.dim(5)=1;
nii.img = ttccbf_img(:,:,:,1);
save_nii(nii, fullfile(subj_folder, 'ttcbf1.nii'));

nii.hdr.dime.dim(5)=1;
nii.img = ttccbf_img(:,:,:,6);
save_nii(nii, fullfile(subj_folder, 'ttcbf6.nii'));

nii.hdr.dime.dim(5)=1;
nii.img = ttccbf_img(:,:,:,7);
save_nii(nii, fullfile(subj_folder, 'ttcbf7.nii'));

nii.hdr.dime.dim(5)=1;
nii.img = ttccbf_img(:,:,:,7);
save_nii(nii, fullfile(subj_folder, 'ttcbf8.nii'));


tt_img = tt_img.*1000; % *1000:change unit from 's' to 'ms'
nii.hdr.dime.dim(5)=1;
nii.img = tt_img;
save_nii(nii, fullfile(subj_folder,'tt.nii'));
