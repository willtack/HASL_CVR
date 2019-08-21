%--------------------------------------------------------------------------------------------------
% Step 1
% Prep:Realign all phases in ASL to M0 in spm GUI
% Purpose: create brainmask 
%--------------------------------------------------------------------------------------------------        

subj_folder = '/Users/tianyelin/Desktop/P01'

addpath /Users/tianyelin/Documents/MATLAB/Codes_CO2

PAR = setpar;
batch_segment(PAR);
batch_create_mask(PAR);  %create brainmask(mask_MPRAGE_P) and skullstripped mask

ASL_path = fullfile(subj_folder, 'ASL/ASL.nii');
M0_path = fullfile(subj_folder, 'M0/M0.nii');

% realign all ASL phases to M0
spm_realign(M0_path, ASL_path);

% set path
rM0_path = fullfile(subj_folder, 'M0/rM0.nii,1');
def2nat_path = fullfile(subj_folder, 'MPRAGE/iy_MPRAGE.nii');
skullstrippedbrain_path = fullfile(subj_folder,'MPRAGE/skullstripped_mMPRAGE.nii');
brainmask_path = fullfile(subj_folder,'MPRAGE/mask_MPRAGE_P01.nii');

% generate brain mask resliced to rM0
spm_coreg_reslice({rM0_path},{skullstrippedbrain_path},{brainmask_path}); % coreg brainmask to rM0




