function spm_realign_hasl(M0_path, ASL_path)

realign_data = {fullfile(M0_path,',1')};
for i = 1:60  
    f = fullfile([ASL_path, ',', num2str(i)]);
    realign_data{i+1,1} = f;
end

clear matlabbatch
spm('defaults','fmri');
spm_jobman('initcfg');

matlabbatch{1}.spm.spatial.realign.estwrite.data = {
                                                    realign_data
                                                    }';

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = '';
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r';

spm_jobman('run',matlabbatch);
clear matlabbatch

end

