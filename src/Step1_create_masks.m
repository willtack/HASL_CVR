%--------------------------------------------------------------------------------------------------
% Step 1
% Preparation: Brain extraction from MPRAGE to get 'MPRAGE_brain.nii'
% Purpose: Realign all phases in ASL to M0
%          create resampled brainmask
%--------------------------------------------------------------------------------------------------        

code_dir = pwd;
addpath(fullfile(code_dir, 'nifti_utils'))
subj_folder = '/home/will/Desktop/input'; % data dir

ASL_path = fullfile(subj_folder, 'ASL/ASL.nii');
M0_path = fullfile(subj_folder, 'M0/M0.nii');

asl_img = nii_load_dimg(ASL_path);
asl_phase_num = size(asl_img, 4);

% realign all ASL phases to M0
spm_realign_hasl(M0_path, ASL_path, asl_phase_num);

% set path
rM0_path = fullfile(subj_folder, 'M0/rM0.nii,1');
skullstrippedbrain_path = fullfile(subj_folder,'MPRAGE/MPRAGE_brain.nii');

% skullstrippedbrain resliced to rM0
spm_coreg_reslice({rM0_path},{skullstrippedbrain_path},{''}); 

% save skullstripped mask
rskullstrippedbrain_path = fullfile(subj_folder,'MPRAGE/rMPRAGE_brain.nii');
rskullstrippedbrain_img = nii_load_dimg(rskullstrippedbrain_path);

rskullstrippedbrain_img(rskullstrippedbrain_img>0)=1;
rskullstrippedbrain_img(rskullstrippedbrain_img<=0)=0;

nii = load_nii(fullfile(subj_folder, 'M0/rM0.nii'),[1]);
nii.img = rskullstrippedbrain_img;
save_nii(nii, fullfile(subj_folder,'MPRAGE/brain_mask.nii'))
