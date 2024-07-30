%% create fmri timeseries data (just raw data stacked across volumes)

%% preparation

clear;clc

% paths
paths = [];
paths.parent    = '/Volumes/T7/MRPETpilot/';
paths.mri       = [paths.parent];
paths.behav     = [paths.parent 'behav/'];
paths.masks     = ['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/'];
paths.analyses  = ['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/'];

% subjects
% load([paths.parent 'subj.mat']);
IDs  = [2202 2203 2204 2205 2206 2207 2208 2109 2110 2112 2113 2114 2115 2116 2217 2218 2219 2220 ...
    2221 2222 2223 2224 2125 2126 2127 2128 2129 2130 2131 2132 2233 2234 2235 2236 2237 2238 2239 ...
    2240 2142 2143 2144 2145 2146 2147 2148 2249 2250];
days = [1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; ...
    1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; ...
    1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2];

% load experimental details
expdat = []; onsets_temp=[]; onsets=[];
for id = 1:length(IDs)
    %% gather info
    
    for d = 1:2
        if days(id,d) == 0
            fname_beh{id,d} = {NaN};
            expdat{id,d} = {NaN};
            contingency{id,d} = [];
        else
            fname_beh{id,d}     = [ num2str(IDs(id)) '_' num2str(days(id,d)) '.mat' ];
            expdat{id,d} = load([paths.behav fname_beh{id,d}]);
            
            % define contingency
            eval(['contingency{id,d}(1) = str2num(expdat{id,d}.dat.day' num2str(d) '.RewardCategory(9));']);
            if contingency{id,d}(1) == 1
                contingency{id,d}(2) = 2;
            elseif contingency{id,d}(1) == 3
                contingency{id,d}(2) = 4;
            elseif contingency{id,d}(1) == 2
                contingency{id,d}(2) = 1;
            elseif contingency{id,d}(1) == 4
                contingency{id,d}(2) = 3;
            end
        end
    end
end


% other relevant information
TR = 3.6;

%% masks

for id = 1:length(IDs)
    
    % select ROIs (keep adding structures here in case something turns out to be interesting)
    % masks.Resp              = [paths.masks 'Resp_Intercept_p001_c281.nii'];
    masks.Rew_Neu_fb_grey       = [paths.masks num2str(IDs(id)) '/fb_rew_v_neu_greymasked_binary.nii'];
    masks.Rew_Neu_stim_grey     = [paths.masks num2str(IDs(id)) '/stim_rew_v_neu_greymasked_binary.nii'];
    masks.Rare_Freq_fb_grey     = [paths.masks num2str(IDs(id)) '/fb_rare_v_freq_greymasked_binary.nii'];
    masks.Rare_Freq_stim_grey   = [paths.masks num2str(IDs(id)) '/stim_rare_v_freq_greymasked_binary.nii'];
    masks.Rem_v_Forg_stim_grey  = [paths.masks num2str(IDs(id)) '/STIM_rem_v_forg_greymasked_binary.nii'];

    masks.Rewards_Rem_v_Forg_stim_grey...
        = [paths.masks num2str(IDs(id)) '/StimRewards_Rem_v_Forg_binary.nii'];
    masks.Rares_Rem_v_Forg_stim_grey...
        = [paths.masks num2str(IDs(id)) '/StimRares_Rem_v_Forg_binary.nii'];
    masks.Interaction_stim_reward_x_frequency...
        = [paths.masks num2str(IDs(id)) '/Interaction_rarefreqXrewneu_brainstem_binary.nii'];
    masks.PositiveInteraction_stim_reward_x_frequency...
        = [paths.masks num2str(IDs(id)) '/PositiveInteraction_rewneuXrarefreq_binary.nii'];
    masks.PositiveInteraction_stim_frequency_x_memory...
        = [paths.masks num2str(IDs(id)) '/PositiveInteraction_Frequency_X_Memory_binary.nii'];
    masks.PositiveInteraction_stim_reward_x_memory...
        = [paths.masks num2str(IDs(id)) '/PositiveInteraction_rewneuXremforg_binary.nii'];

    masks.LC                    = [paths.masks num2str(IDs(id)) '/LC.nii'];
    masks.SN                    = [paths.masks num2str(IDs(id)) '/SN.nii'];
    masks.VTA                   = [paths.masks num2str(IDs(id)) '/VTA.nii'];

    masks.SFC_L                 = [paths.masks num2str(IDs(id)) '/SFC_L.nii']; % rem: rare vs freq
    masks.IFC_R                 = [paths.masks num2str(IDs(id)) '/IFC_R.nii']; % rem: rare vs freq
    masks.MFC_L                 = [paths.masks num2str(IDs(id)) '/MFC_L.nii']; % rem: rew vs neu
    masks.Precuneus             = [paths.masks num2str(IDs(id)) '/Precuneus_overlap.nii']; % rew/rare: rem vs forg
    masks.Fusiform              = [paths.masks num2str(IDs(id)) '/Fusiform_overlap.nii']; % rew/rare: rem vs forg
    masks.Rem_Rare_v_Freq_dSN   = [paths.masks num2str(IDs(id)) '/dSN.nii'];
    masks.Precuneus_L

    
    % masks.Rew_Neu_stim_NAcc = [paths.masks 'Rew_Neu_stim_p01_c0_NACC.nii'];
    % masks.Rew_Null_fb_BS    = [paths.masks 'Rew_Null_FB_p001_c0_brainstem.nii'];
    % masks.stim_null_occi    = [paths.masks 'Stim_Fix_p001_c272_Occi.nii'];
    
    % create analyses information reservoir
    analyses = fieldnames(masks); maskimage=[]; maskname=[];
    for a1 = 1:length(analyses) % for the length of the analyses you mean to do
        maskimage{id,1}{a1,1} = masks.(analyses{a1}); % the path to this specific mask
        maskname{id,1}{a1,1} = analyses{a1}; % the name of this analysis
    end
    
    
    
    % average signal intensities within the assigned masks
    for a2 = 1:length(analyses) % for the number of analyses
        clear subjectpath dat tmp % clear workspace
        
        subject_path = paths.mri; % where is the fMRI?
        tmp = spm_vol([subject_path '/s3func' num2str(IDs(id)) '.nii']); % read how many volumes it has
        for vol = 1:length(tmp) % for the number of volumes
            dat{vol,1} = [tmp(vol).fname ',' num2str(vol)]; % make a list recognisable by SPM
        end
        
        dat =  spm_summarise(dat,maskimage{id,1}{a2,1},@mean); % average the signal within the mask
        mkdir([paths.analyses num2str(IDs(id)) '/']) % where does the data go?
        save([paths.analyses num2str(IDs(id)) '/' maskname{id,1}{a2,1} '.mat'],'dat') % here
        
    end
    
end

disp('timeseries done')



%%
%% masks - Extra!

for id = 1:length(IDs)

    clear dat

    % select ROIs (keep adding structures here in case something turns out to be interesting)
    masks.temporoparietal = [paths.masks num2str(IDs(id)) '/temporoparietal.nii']; 
    
    % create analyses information reservoir
    analyses = fieldnames(masks); maskimage=[]; maskname=[];
    for a1 = 1:length(analyses) % for the length of the analyses you mean to do
        maskimage{id,1}{a1,1} = masks.(analyses{a1}); % the path to this specific mask
        maskname{id,1}{a1,1} = analyses{a1}; % the name of this analysis
    end
    
   
    % average signal intensities within the assigned masks
    for a2 = 1:length(analyses) % for the number of analyses
        clear subjectpath dat tmp % clear workspace
        
        subject_path = paths.mri; % where is the fMRI?
        tmp = spm_vol([subject_path '/s3func' num2str(IDs(id)) '.nii']); % read how many volumes it has
        for vol = 1:length(tmp) % for the number of volumes
            dat{vol,1} = [tmp(vol).fname ',' num2str(vol)]; % make a list recognisable by SPM
        end
        
        dat =  spm_summarise(dat,maskimage{id,1}{a2,1},@mean); % average the signal within the mask
        save([paths.analyses num2str(IDs(id)) '/' maskname{id,1}{a2,1} '.mat'],'dat') % here
        
    end
    
end

disp('timeseries done')
