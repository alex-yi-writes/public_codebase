% create behavioral vectors

% needed: Onset in seconds for decision (stimulus), response, feedback, and
% ITI as well as duration which is time in seconds in between stimuli

%% preparation

clear;clc

% paths

paths = [];
paths.parent    = '/Users/alex/Dropbox/paperwriting/3tpilot/data/';
paths.mri       = [paths.parent 'mri_separated'];
paths.behav     = [paths.parent 'behav/'];
paths.masks     = [paths.parent 'masks/'];
paths.analyses  = ['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/'];

% subjects
% load([paths.parent 'subj.mat']);
IDs  = [2202 2203 2204 2205 2206 2207 2208 2109 2110 2112 2113 2114 2115 2116 2217 2218 2219 2220 ...
    2221 2222 2223 2224 2125 2126 2127 2128 2129 2130 2131 2132 2233 2234 2235 2236 2237 2238 2239 ...
    2240 2142 2143 2144 2145 2146 2147 2148 2249 2250];
days = [1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; ...
    1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; ...
    1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2];
d1m  = [1 2; 1 0; 1 2; 1 2; 1 2; 1 0; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 0; 1 2; 1 2; 1 2; 1 2; 1 2]; % 1=immediate 2=delayed
d2m  = [1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 0; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2; 1 2];

% other information
TR = 3.6;
load('/Users/alex/Dropbox/literatures_IKND/length_scan_allsubj.mat')
load('/Users/alex/Desktop/mrpilot_coreg/pilotRT_new/numvol.mat')
length_scan1=length_scan1(:,2);

% behavioual data
expdat = [];
for id = 1:length(IDs)
    for d = 1:2
        if d == 0
            expdat{id,d} = {NaN};
        else
            expdat{id,d} = load([paths.behav num2str(IDs(id)) '_' num2str(d) '.mat']);
            % define contingency
            eval(['contingency{id,d}(1) = str2num(expdat{id,d}.dat.day' num2str(d) '.RewardCategory(9))']);
            if contingency{id,d}(1) == 1
                contingency{id,d}(2) = 2;
            elseif contingency{id,d}(1) == 3
                contingency{id,d}(2) = 4;
            elseif contingency{id,d}(1) == 2
                contingency{id,d}(2) = 1;
            elseif contingency{id,d}(1) == 4
                contingency{id,d}(2) = 3;
            end

            % task info
            clear stim_task stim_del stim_imm stim_del_rem stim_imm_rem accuracies_imm accuracies_del stim_rewards stim_neutrals
            stim_task = eval(['expdat{id,d}.dat.day' num2str(d) '.maintask.config.stim.fname']);
            stim_imm  = eval(['expdat{id,d}.dat.day' num2str(d) '.memorytest.immediate.results.trl(:,[1 4])']);            
            accuracies_imm= eval(['expdat{id,d}.dat.day' num2str(d) '.memorytest.immediate.results.accu']);
            stim_imm_rem  = stim_imm(cell2mat(stim_imm(:,2))==1 & accuracies_imm==1,1); % old items and remembered
            stim_imm_for  = stim_imm(cell2mat(stim_imm(:,2))==1 & accuracies_imm==0,1); % old items and forgotten
            
            stim_task = eval(['expdat{id,d}.dat.day' num2str(d) '.maintask.config.stim.fname']);
            if eval(['d' num2str(d) 'm(id,2)==0'])
            disp('no task data')
            else
            stim_del  = eval(['expdat{id,d}.dat.day' num2str(d) '.memorytest.delayed.results.trl(:,[1 4])']);            
            accuracies_del= eval(['expdat{id,d}.dat.day' num2str(d) '.memorytest.delayed.results.accu']);
            stim_del_rem  = stim_del(cell2mat(stim_del(:,2))==1 & accuracies_del==1,1); % old items and remembered
            stim_del_for  = stim_del(cell2mat(stim_del(:,2))==1 & accuracies_del==0,1); % old items and forgotten
            end
            
            
            for q = 1:length(stim_task)
%                 idx = find(strcmp([C{:}], 'a'))
                ind_remembered_imm(q,1) = {find(strcmp(stim_task{q,1},stim_imm_rem))};
            end            
            tmp = cellfun(@isempty,ind_remembered_imm); indx_remembered_imm = tmp==0;
            
            for q = 1:length(stim_task)
%                 idx = find(strcmp([C{:}], 'a'))
                ind_forgotten_imm(q,1) = {find(strcmp(stim_task{q,1},stim_imm_for))};
            end            
            tmp = cellfun(@isempty,ind_forgotten_imm); indx_forgotten_imm = tmp==0;
            
            
            if eval(['d' num2str(d) 'm(id,2)==0'])
            disp('no task data')
            else
            for q = 1:length(stim_task)
%                 idx = find(strcmp([C{:}], 'a'))
                ind_remembered_del(q,1) = {find(strcmp(stim_task{q,1},stim_del_rem))};
            end            
            tmp = cellfun(@isempty,ind_remembered_del); indx_remembered_del = tmp==0;
            
            for q = 1:length(stim_task)
%                 idx = find(strcmp([C{:}], 'a'))
                ind_forgotten_del(q,1) = {find(strcmp(stim_task{q,1},stim_del_for))};
            end            
            tmp = cellfun(@isempty,ind_forgotten_del); indx_forgotten_del = tmp==0;
            end
            
            memoryindex_sep{id,d}.remembered_imm = indx_remembered_imm==1;
            memoryindex_sep{id,d}.remembered_del = indx_remembered_del==1;
            memoryindex_sep{id,d}.remembered_all = indx_remembered_imm==1 | indx_remembered_del==1;
            memoryindex_sep{id,d}.forgotten_imm = indx_forgotten_imm==1;
            memoryindex_sep{id,d}.forgotten_del = indx_forgotten_del==1;
            memoryindex_sep{id,d}.forgotten_all = indx_forgotten_imm==1 | indx_forgotten_del==1;
            
            % sort onsets
            if eval(['d' num2str(d) 'm(id,2)==0']) % there is no delayed bit
            disp('no task data')
            onsets_temp{id,d}.stim.remembered  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(indx_remembered_imm==1 )-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.stim.forgotten   = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(indx_forgotten_imm==1 )-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.fb.remembered  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.cue(indx_remembered_imm==1 )-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.fb.forgotten   = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.cue(indx_forgotten_imm==1 )-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.stim.reward_rem  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.stim.reward_for  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.stim.neutral_rem = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.stim.neutral_for = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.fb.reward_rem    = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.fb.reward_for    = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);

            onsets_temp{id,d}.fb.neutral_rem   = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.fb.neutral_for   = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            
            
            else % there is delayed bit
                
            onsets_temp{id,d}.stim.remembered  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(indx_remembered_imm==1 | indx_remembered_del==1)-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.stim.forgotten   = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(indx_forgotten_imm==1 | indx_forgotten_del==1)-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.fb.remembered  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.cue(indx_remembered_imm==1 | indx_remembered_del==1)-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.fb.forgotten   = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.cue(indx_forgotten_imm==1 | indx_forgotten_del==1)-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.stim.reward_rem  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.stim.reward_for  = eval(['expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.stim.neutral_rem = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.stim.neutral_for = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.fb.reward_rem    = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.fb.reward_for    = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);

            onsets_temp{id,d}.fb.neutral_rem   = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            onsets_temp{id,d}.fb.neutral_for   = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
            
            end
            
            onsets_temp{id,d}.fixX         = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.fix-(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.trig_1st);']);
            
            onsets_temp{id,d}.resp         = eval...
                (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim+2.5-(expdat{id,d}.dat.day' num2str(d)...
                '.maintask.results.SOT.raw.trig_1st);']);
            
            
            if d==1
                if d1m(id,2)==0 % there is no delayed bit
                disp('no task data')
                onsets_temp{id,d}.stim.FreqReward_rem  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.FreqReward_for  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.stim.RareNeutral_rem = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.RareNeutral_for = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.FreqReward_rem    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.FreqReward_for    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.RareNeutral_rem   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.RareNeutral_for   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                else
                onsets_temp{id,d}.stim.FreqReward_rem  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.FreqReward_for  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.stim.RareNeutral_rem = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.RareNeutral_for = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.FreqReward_rem    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.FreqReward_for    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.RareNeutral_rem   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.RareNeutral_for   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                end
                
            elseif d==2
                if d2m(id,2)==0 % there is no delayed bit
                disp('no task data')
                onsets_temp{id,d}.stim.RareReward_rem  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.RareReward_for  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.stim.FreqNeutral_rem = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.FreqNeutral_for = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.RareReward_rem    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.RareReward_for    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.FreqNeutral_rem   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.FreqNeutral_for   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 ))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                else
                onsets_temp{id,d}.stim.RareReward_rem  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.RareReward_for  = eval(['expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.stim.FreqNeutral_rem = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.stim.FreqNeutral_for = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.stim(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.RareReward_rem    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.RareReward_for    = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(1) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                
                onsets_temp{id,d}.fb.FreqNeutral_rem   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_remembered_imm==1 | indx_remembered_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                onsets_temp{id,d}.fb.FreqNeutral_for   = eval...
                    (['expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.cue(cell2mat(expdat{id,d}.dat.day' num2str(d)...
                    '.maintask.results.trl(:,2))==contingency{id,d}(2) & (indx_forgotten_imm==1 | indx_forgotten_del==1))-(expdat{id,d}.dat.day' num2str(d) '.maintask.results.SOT.raw.trig_1st);']);
                end
                
            end
        end

    end

    % merge onsets
    if days(id,1) == 0
        %Freq reward and rare neutral
        
        %remembered
        onsetsmem{id,1}.stim.remembered      = [0];
        onsetsmem{id,1}.fb.remembered        = [0];
        onsetsmem{id,1}.stim.rewardFreq_rem  = [0];
        onsetsmem{id,1}.stim.neutralRare_rem = [0];
        onsetsmem{id,1}.fb.rewardFreq_rem    = [0];
        onsetsmem{id,1}.fb.neutralRare_rem   = [0];
        
        %forgotten
        onsetsmem{id,1}.stim.forgotten       = [0];
        onsetsmem{id,1}.fb.forgotten         = [0];
        onsetsmem{id,1}.stim.rewardFreq_for  = [0];
        onsetsmem{id,1}.stim.neutralRare_for = [0];
        onsetsmem{id,1}.fb.rewardFreq_for    = [0];
        onsetsmem{id,1}.fb.neutralRare_for   = [0];
        
        %remembered
        onsetsmem{id,1}.stim.rewardRare_rem  = [onsets_temp{id,2}.stim.reward_rem+length_scan1(id)];
        onsetsmem{id,1}.stim.neutralFreq_rem = [onsets_temp{id,2}.stim.neutral_rem+length_scan1(id)];
        onsetsmem{id,1}.fb.rewardRare_rem    = [onsets_temp{id,2}.fb.reward_rem+length_scan1(id)];
        onsetsmem{id,1}.fb.neutralFreq_rem   = [onsets_temp{id,2}.fb.neutral_rem+length_scan1(id)];
        
        %forgotten
        onsetsmem{id,1}.stim.rewardRare_for  = [onsets_temp{id,2}.stim.reward_for+length_scan1(id)];
        onsetsmem{id,1}.stim.neutralFreq_for = [onsets_temp{id,2}.stim.neutral_for+length_scan1(id)];
        onsetsmem{id,1}.fb.rewardRare_for    = [onsets_temp{id,2}.fb.reward_for+length_scan1(id)];
        onsetsmem{id,1}.fb.neutralFreq_for   = [onsets_temp{id,2}.fb.neutral_for+length_scan1(id)];
        
        onsetsmem{id,1}.fixX         = [onsets_temp{id,2}.fixX+length_scan1(id)];
        onsetsmem{id,1}.resp         = [onsets_temp{id,2}.resp+length_scan1(id)];
        
    elseif days(id,2) == 0
        %Freq reward and rare neutral
        
        %remembered
        onsetsmem{id,1}.stim.remembered      = [onsets_temp{id,1}.stim.remembered];
        onsetsmem{id,1}.fb.remembered        = [onsets_temp{id,1}.fb.remembered];
        onsetsmem{id,1}.stim.rewardFreq_rem  = [onsets_temp{id,1}.stim.reward_rem];
        onsetsmem{id,1}.stim.neutralRare_rem = [onsets_temp{id,1}.stim.neutral_rem];
        onsetsmem{id,1}.fb.rewardFreq_rem    = [onsets_temp{id,1}.fb.reward_rem];
        onsetsmem{id,1}.fb.neutralRare_rem   = [onsets_temp{id,1}.fb.neutral_rem];
        %forgotten
        onsetsmem{id,1}.stim.forgotten       = [onsets_temp{id,1}.stim.forgotten];
        onsetsmem{id,1}.fb.forgotten         = [onsets_temp{id,1}.fb.forgotten];
        onsetsmem{id,1}.stim.rewardFreq_for  = [onsets_temp{id,1}.stim.reward_for];
        onsetsmem{id,1}.stim.neutralRare_for = [onsets_temp{id,1}.stim.neutral_for];
        onsetsmem{id,1}.fb.rewardFreq_for    = [onsets_temp{id,1}.fb.reward_for];
        onsetsmem{id,1}.fb.neutralRare_for   = [onsets_temp{id,1}.fb.neutral_for];
        
        %remembered
        onsetsmem{id,1}.stim.rewardRare_rem  = [0];
        onsetsmem{id,1}.stim.neutralFreq_rem = [0];
        onsetsmem{id,1}.fb.rewardRare_rem    = [0];
        onsetsmem{id,1}.fb.neutralFreq_rem   = [0];
        %forgotten
        onsetsmem{id,1}.stim.rewardRare_for  = [0];
        onsetsmem{id,1}.stim.neutralFreq_for = [0];
        onsetsmem{id,1}.fb.rewardRare_for    = [0];
        onsetsmem{id,1}.fb.neutralFreq_for   = [0];
        
        onsetsmem{id,1}.fixX         = [onsets_temp{id,1}.fixX];
        onsetsmem{id,1}.resp         = [onsets_temp{id,1}.resp];
        
    else
        %Freq reward and rare neutral
        
        onsetsmem{id,1}.stim.remembered = [onsets_temp{id,1}.stim.remembered; onsets_temp{id,2}.stim.remembered+length_scan1(id)];
        onsetsmem{id,1}.stim.forgotten  = [onsets_temp{id,1}.stim.forgotten; onsets_temp{id,2}.stim.forgotten+length_scan1(id)];
        onsetsmem{id,1}.fb.remembered = [onsets_temp{id,1}.fb.remembered; onsets_temp{id,2}.fb.remembered+length_scan1(id)];
        onsetsmem{id,1}.fb.forgotten  = [onsets_temp{id,1}.fb.forgotten; onsets_temp{id,2}.fb.forgotten+length_scan1(id)];

        %remembered
        onsetsmem{id,1}.stim.rewardFreq_rem  = [onsets_temp{id,1}.stim.reward_rem];
        onsetsmem{id,1}.stim.neutralRare_rem = [onsets_temp{id,1}.stim.neutral_rem];
        onsetsmem{id,1}.fb.rewardFreq_rem    = [onsets_temp{id,1}.fb.reward_rem];
        onsetsmem{id,1}.fb.neutralRare_rem   = [onsets_temp{id,1}.fb.neutral_rem];
        %forgotten
        onsetsmem{id,1}.stim.rewardFreq_for  = [onsets_temp{id,1}.stim.reward_for];
        onsetsmem{id,1}.stim.neutralRare_for = [onsets_temp{id,1}.stim.neutral_for];
        onsetsmem{id,1}.fb.rewardFreq_for    = [onsets_temp{id,1}.fb.reward_for];
        onsetsmem{id,1}.fb.neutralRare_for   = [onsets_temp{id,1}.fb.neutral_for];
        
        %remembered
        onsetsmem{id,1}.stim.rewardRare_rem  = [onsets_temp{id,2}.stim.reward_rem+length_scan1(id)];
        onsetsmem{id,1}.stim.neutralFreq_rem = [onsets_temp{id,2}.stim.neutral_rem+length_scan1(id)];
        onsetsmem{id,1}.fb.rewardRare_rem    = [onsets_temp{id,2}.fb.reward_rem+length_scan1(id)];
        onsetsmem{id,1}.fb.neutralFreq_rem   = [onsets_temp{id,2}.fb.neutral_rem+length_scan1(id)];
        %forgotten
        onsetsmem{id,1}.stim.rewardRare_for  = [onsets_temp{id,2}.stim.reward_for+length_scan1(id)];
        onsetsmem{id,1}.stim.neutralFreq_for = [onsets_temp{id,2}.stim.neutral_for+length_scan1(id)];
        onsetsmem{id,1}.fb.rewardRare_for    = [onsets_temp{id,2}.fb.reward_for+length_scan1(id)];
        onsetsmem{id,1}.fb.neutralFreq_for   = [onsets_temp{id,2}.fb.neutral_for+length_scan1(id)];
        
        onsetsmem{id,1}.fixX         = [onsets_temp{id,1}.fixX; onsets_temp{id,2}.fixX+length_scan1(id)];
        onsetsmem{id,1}.resp         = [onsets_temp{id,1}.resp; onsets_temp{id,2}.resp+length_scan1(id)];

        memoryindex{id,1}.remembered_imm = [memoryindex_sep{id,1}.remembered_imm; memoryindex_sep{id,2}.remembered_imm];
        memoryindex{id,1}.remembered_imm_d1  = memoryindex_sep{id,1}.remembered_imm;
        memoryindex{id,1}.remembered_imm_d2  = memoryindex_sep{id,2}.remembered_imm;

        memoryindex{id,1}.remembered_del = [memoryindex_sep{id,1}.remembered_del; memoryindex_sep{id,2}.remembered_del];
        memoryindex{id,1}.remembered_del_d1  = memoryindex_sep{id,1}.remembered_del;
        memoryindex{id,1}.remembered_del_d2  = memoryindex_sep{id,2}.remembered_del;

        memoryindex{id,1}.remembered_all = [memoryindex_sep{id,1}.remembered_all; memoryindex_sep{id,2}.remembered_all];
        memoryindex{id,1}.remembered_all_d1 = memoryindex_sep{id,1}.remembered_all;
        memoryindex{id,1}.remembered_all_d2 = memoryindex_sep{id,2}.remembered_all;

        memoryindex{id,1}.forgotten_imm = [memoryindex_sep{id,1}.forgotten_imm; memoryindex_sep{id,2}.forgotten_imm];
        memoryindex{id,1}.forgotten_imm_d1  = memoryindex_sep{id,1}.forgotten_imm;
        memoryindex{id,1}.forgotten_imm_d2  = memoryindex_sep{id,2}.forgotten_imm;

        memoryindex{id,1}.forgotten_del = [memoryindex_sep{id,1}.forgotten_del; memoryindex_sep{id,2}.forgotten_del];
        memoryindex{id,1}.forgotten_del_d1  = memoryindex_sep{id,1}.forgotten_del;
        memoryindex{id,1}.forgotten_del_d2  = memoryindex_sep{id,2}.forgotten_del;

        memoryindex{id,1}.forgotten_all = [memoryindex_sep{id,1}.forgotten_all; memoryindex_sep{id,2}.forgotten_all];
        memoryindex{id,1}.forgotten_all_d1 = memoryindex_sep{id,1}.forgotten_all;
        memoryindex{id,1}.forgotten_all_d2 = memoryindex_sep{id,2}.forgotten_all;


    end
end


%% run

clear id d

for id = 1:length(IDs) % open subject id loop
    
    % mkdir([paths.analyses num2str(IDs(id))])   
    
    % empty trial info
    %             nulls = eval(['expdat{id,d}.dat.day' num2str(d) '.maintask.config.stim.rewmat_nulls(1,:)']);
    breaks1 = find(isnan(expdat{id,1}.dat.day1.maintask.config.timing.fixation1));
    breaks2 = find(isnan(expdat{id,2}.dat.day2.maintask.config.timing.fixation1));
    
    % load RTs and set them in seconds
    rts1 = expdat{id,1}.dat.day1.maintask.results.rt/1000;
    rts2 = expdat{id,2}.dat.day2.maintask.results.rt/1000;
    
    rts1=rts1'; rts2=rts2'; % remove null trials
    answered1 = find(~isnan(rts1));
    answered2 = find(~isnan(rts2));
    
    % make vectors of relevant events: stimuli-rts-feedback-ITI
    
    %%%%%%%%%%%% orders of the task events (for alex) %%%%%%%%%%%%
    
    % first scanner trigger -> ... fifth -> fixation cross 0 ->
    % first stimuli(2.5s) -> first resp(2s) -> first dot(jitters)
    % -> first feedback(1.5s) -> first fixation cross(jitters) ->
    % (repeats from stim on) ...
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % make onset variables
    
    % ======== day 1 ======== %
    
    clear tmponset tmp1 tmp2
    tmponset = expdat{id,1}.dat.day1.maintask.results.SOT.raw; % make workspace
    tmp1 = tmponset.resp; tmp2=nan(length(rts1),1);
    tmp2(answered1)=tmp1;
    tmponset.resp = tmp2;
    
    % make onset variables
    onsets1 = [];
    onsets1.stim     = tmponset.stim - tmponset.trig_1st; % sync matlab-recorded onsets to the scan start
    onsets1.feedback = tmponset.cue - tmponset.trig_1st;
    onsets1.fix      = tmponset.fix - tmponset.trig_1st; onsets1.fix(breaks1+1) = []; %onsets.fix(nulls) = []; % remove break fixs, remove null trials
    onsets1.response = tmponset.resp - tmponset.trig_1st;
    onsets1.RT       = onsets1.response + rts1'; % when the subject pressed the button
    onsets1.dot      = onsets1.response + expdat{id,1}.dat.day1.maintask.config.timing.response;
    onsets1.trial    = [tmponset.t0_fix0 - tmponset.trig_1st; onsets1.fix(1:end-1,1)]; % concatenate the fix0 and the rest of the fix;
    
    % make duration variables
    durations1 = [];
    durations1.stim      = repmat(2.5,length(onsets1.stim),1);
    durations1.feedback  = repmat(1.5,length(onsets1.feedback),1);
    durations1.response  = repmat(2,length(onsets1.response),1);
    durations1.fix       = expdat{id,1}.dat.day1.maintask.config.timing.fixation1/1000; durations1.fix(breaks1) = []; %durations.fix(nulls) = []; % remove breaks
    durations1.dot       = expdat{id,1}.dat.day1.maintask.config.timing.dot/1000; %durations.dot(nulls) = [];
    durations1.trial     = [durations1.fix' + 6 + durations1.dot'];
    
    
    % ======== day 2 ======== %

    clear tmponset tmp1 tmp2
    tmponset = expdat{id,2}.dat.day2.maintask.results.SOT.raw; % make workspace
    tmp1 = tmponset.resp; tmp2=nan(length(rts2),1);
    tmp2(answered2)=tmp1;
    tmponset.resp = tmp2;
    
    onsets2 = [];
    onsets2.stim     = tmponset.stim - tmponset.trig_1st + length_scan1(id); % sync matlab-recorded onsets to the scan start
    onsets2.feedback = tmponset.cue - tmponset.trig_1st + length_scan1(id);
    onsets2.fix      = tmponset.fix - tmponset.trig_1st + length_scan1(id); onsets2.fix(breaks1+1) = []; %onsets.fix(nulls) = []; % remove break fixs, remove null trials
    onsets2.response = tmponset.resp - tmponset.trig_1st + length_scan1(id);
    onsets2.RT       = onsets2.response + rts2'  + length_scan1(id); % when the subject pressed the button
    onsets2.dot      = onsets2.response + expdat{id,2}.dat.day2.maintask.config.timing.response + length_scan1(id);
    onsets2.trial    = [tmponset.t0_fix0 - tmponset.trig_1st + length_scan1(id); onsets2.fix(1:end-1,1)];%  + length_scan1(id); % concatenate the fix0 and the rest of the fix;
    
    % make duration variables
    durations2 = [];
    durations2.stim      = repmat(2.5,length(onsets2.stim),1);
    durations2.feedback  = repmat(1.5,length(onsets2.feedback),1);
    durations2.response  = repmat(2,length(onsets2.response),1);
    durations2.fix       = expdat{id,2}.dat.day2.maintask.config.timing.fixation1/1000; durations2.fix(breaks1) = []; %durations.fix(nulls) = []; % remove breaks
    durations2.dot       = expdat{id,2}.dat.day2.maintask.config.timing.dot/1000; %durations.dot(nulls) = [];
    durations2.trial     = [durations2.fix' + 6 + durations2.dot'];

    
    % ======== now combine ======== %

    onsets = [];

    onsets.stim     = [onsets1.stim;onsets2.stim]; % sync matlab-recorded onsets to the scan start
    onsets.feedback = [onsets1.feedback;onsets2.feedback];
    onsets.fix      = [onsets1.fix;onsets2.fix]; %onsets.fix(nulls) = []; % remove break fixs, remove null trials
    onsets.response = [onsets1.response;onsets2.response];
    onsets.RT       = [onsets1.RT;onsets2.RT]; % when the subject pressed the button
    onsets.dot      = [onsets1.dot;onsets2.dot];
    onsets.trial    = [onsets1.trial;onsets2.trial]; % concatenate the fix0 and the rest of the fix;

    onsets.stim_remembered  = onsetsmem{id,1}.stim.remembered;
    onsets.fb_remembered    = onsetsmem{id,1}.fb.remembered;
    onsets.stim_forgotten   = onsetsmem{id,1}.stim.forgotten;
    onsets.fb_forgotten     = onsetsmem{id,1}.fb.forgotten;

    onsets.stim_rewardFreq_rem = onsetsmem{id,1}.stim.rewardFreq_rem;
    onsets.stim_rewardFreq_for = onsetsmem{id,1}.stim.rewardFreq_for;
    onsets.fb_rewardFreq_rem   = onsetsmem{id,1}.fb.rewardFreq_rem;
    onsets.fb_rewardFreq_for   = onsetsmem{id,1}.fb.rewardFreq_for;
    onsets.stim_rewardRare_rem = onsetsmem{id,1}.stim.rewardRare_rem;
    onsets.stim_rewardRare_for = onsetsmem{id,1}.stim.rewardRare_for;
    onsets.fb_rewardRare_rem   = onsetsmem{id,1}.fb.rewardRare_rem;
    onsets.fb_rewardRare_for   = onsetsmem{id,1}.fb.rewardRare_for;

    onsets.stim_neutralFreq_rem = onsetsmem{id,1}.stim.neutralFreq_rem;
    onsets.stim_neutralFreq_for = onsetsmem{id,1}.stim.neutralFreq_for;
    onsets.fb_neutralFreq_rem   = onsetsmem{id,1}.fb.neutralFreq_rem;
    onsets.fb_neutralFreq_for   = onsetsmem{id,1}.fb.neutralFreq_for;
    onsets.stim_neutralRare_rem = onsetsmem{id,1}.stim.neutralRare_rem;
    onsets.stim_neutralRare_for = onsetsmem{id,1}.stim.neutralRare_for;
    onsets.fb_neutralRare_rem   = onsetsmem{id,1}.fb.neutralRare_rem;
    onsets.fb_neutralRare_for   = onsetsmem{id,1}.fb.neutralRare_for;
    
    durations = [];

    durations.stim      = [durations1.stim;durations2.stim];
    durations.feedback  = [durations1.feedback;durations2.feedback];
    durations.response  = [durations1.response;durations2.response];
    durations.fix       = [durations1.fix';durations2.fix']; %durations.fix(nulls) = []; % remove breaks
    durations.dot       = [durations1.dot';durations2.dot']; %durations.dot(nulls) = [];
    durations.trial     = [durations1.trial;durations2.trial];
    
    
    %% save collated trial information
    
    clear dat1 dat2 dat
    
    dat1 = expdat{id,1}.dat.day1.maintask;
    dat2 = expdat{id,2}.dat.day2.maintask;
    
    dat1.RewardCategory = expdat{id,1}.dat.day1.RewardCategory;
    dat2.RewardCategory = expdat{id,2}.dat.day2.RewardCategory;
    
    dat.day1 = dat1;
    dat.day2 = dat2;
    dat.all = [];
    
    clear tmp1 tmp2
    tmp1 = dat1.results.trl;
    tmp2 = dat2.results.trl;
    
    dat.all.results = [tmp1;tmp2];
    dat.all.memory = memoryindex{id,1};

    save([paths.analyses num2str(IDs(id)) '/'...
        num2str(IDs(id)) '_collated.mat'],'dat')

    %% save data
    save([paths.analyses num2str(IDs(id)) '/'...
        num2str(IDs(id)) '_timeinfo.mat'],'onsets','durations')
    
end

