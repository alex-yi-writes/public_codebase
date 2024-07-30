function [dm,con,conlist,badtr] = create_design_matrix_mrpilot(EVdir,subjID,dm_type,badtr,nTr,samp_upS);
%% load in behavioral files relevant for first level glms 

% adjust path
tmp1        = load(['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/' subjID(1:4) '/' subjID(1:4) '_collated.mat' ]);
timedat1    = load(['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/' subjID(1:4) '/' subjID(1:4) '_timeinfo.mat' ]);
behavdat    = tmp1.dat.all;

%% create design matrix

switch dm_type 
    case 'Reward_v_Neutral' % adjust this for your individual, is the name you set in S.dm_type  
        
        nEVs = 2; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;


        % stimvec = cell2mat(behavdat.results(:,3)); % read the trial data
        % stimvec(find(isnan(stimvec)))=[]; % clean up null trials
        % rewards = find(stimvec==1); % label 1 = reward, 0 = neutral
        % neutral = find(stimvec~=1);


        % here more regressors, 
        
%         modeldat = zscore(modelres(wo).prior(:,2)-.5);
%         dum = zeros(1,128);
%         dmdum = nan(length(dum),1);dmdum(trlnotraus)= modeldat;
        % remove first trial in every run and fill only those trials that
        % we have behavioral data on, those are deleted lateron
%         dmdum(1:32:end) = [];
        
        % 20200709 comments
        % use the same regressor that was used in SPM GLM
        % try recreating the matrix with actual regressors, rewards as just
        % 1
        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(frequentreward,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(rareneutral,3) = 1;
        dm(rarereward,2) = 1;
        dm(frequentneutral,3) = 1;
        
        to_demean = [];
        to_normalise = [];
        
        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        con(end+1,:) = [0 1 -1];
        conlist ={'Reward', 'Neutral', 'Reward_v_Neutral'};
        
        
    case 'Rare_v_Frequent' % adjust this for your individual, is the name you set in S.dm_type
        
        nEVs = 2; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;


        % stimvec = cell2mat(behavdat.results(:,3)); % read the trial data
        % stimvec(find(isnan(stimvec)))=[]; % clean up null trials
        % rewards = find(stimvec==1); % label 1 = reward, 0 = neutral
        % neutral = find(stimvec~=1);


        % here more regressors, 
        
%         modeldat = zscore(modelres(wo).prior(:,2)-.5);
%         dum = zeros(1,128);
%         dmdum = nan(length(dum),1);dmdum(trlnotraus)= modeldat;
        % remove first trial in every run and fill only those trials that
        % we have behavioral data on, those are deleted lateron
%         dmdum(1:32:end) = [];
        
        % 20200709 comments
        % use the same regressor that was used in SPM GLM
        % try recreating the matrix with actual regressors, rewards as just
        % 1
        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(frequentreward,3) = 1; % regressor data! zscore % nTR - volume, 
        dm(rareneutral,2) = 1;
        dm(rarereward,2) = 1;
        dm(frequentneutral,3) = 1;
        
        to_demean = [];
        to_normalise = [];
        
        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        con(end+1,:) = [0 1 -1];
        conlist ={'Infrequent', 'Frequent', 'Infrequent vs Frequent'};

        
    case 'FullModel'
        
        nEVs = 4;
        
        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;
                        
        % 20200709 comments
        % use the same regressor that was used in SPM GLM
        % try recreating the matrix with actual regressors, rewards as just
        % 1
        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % dm(frequentreward,2) = 1; % regressor data! zscore % nTR - volume, 
        % dm(rareneutral,3) = 1;
        % dm(rarereward,4) = 1;
        % dm(frequentneutral,5) = 1;

        dm(frequentreward,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(rarereward,2) = 1;
        dm(rareneutral,3) = 1;
        dm(frequentneutral,3) = 1;
        dm(rareneutral,4) = 1;
        dm(rarereward,4) = 1;
        dm(frequentreward,5) = 1; % regressor data! zscore % nTR - volume, 
        dm(frequentneutral,5) = 1;
        

        to_demean = [];
        to_normalise = [];
        
        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        conlist ={'Full Model'};


    case 'FullModel2'
        
        nEVs = 4;
        
        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;
                        
        % 20200709 comments
        % use the same regressor that was used in SPM GLM
        % try recreating the matrix with actual regressors, rewards as just
        % 1
        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        dm(frequentreward,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(rareneutral,3) = 1;
        dm(rarereward,4) = 1;
        dm(frequentneutral,5) = 1;

        % dm(frequentreward,2) = 1; % regressor data! zscore % nTR - volume, 
        % dm(rarereward,2) = 1;
        % dm(rareneutral,3) = 1;
        % dm(frequentneutral,3) = 1;
        % dm(rareneutral,4) = 1;
        % dm(rarereward,4) = 1;
        % dm(frequentreward,5) = 1; % regressor data! zscore % nTR - volume, 
        % dm(frequentneutral,5) = 1;
        

        to_demean = [];
        to_normalise = [];
        
        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        conlist ={'Full Model 2'};

    case 'Remembered_v_Forgotten' % adjust this for your individual, is the name you set in S.dm_type  
        
        nEVs = 2; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;

        % memory data
        remembered1  = find(tmp1.dat.all.memory.remembered_all_d1==1);
        forgotten1   = find(tmp1.dat.all.memory.forgotten_all_d1==1);
        remembered2  = find(tmp1.dat.all.memory.remembered_all_d2==1)+180;
        forgotten2   = find(tmp1.dat.all.memory.forgotten_all_d2==1)+180;
        
        % index regressors, original design matrix in this order
        RewRareRem = find((stimvec2==contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        RewFreqRem = find((stimvec1==contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuRareRem = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuFreqRem = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        
        RewRareFor = find((stimvec2==contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;
        RewFreqFor = find((stimvec1==contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuRareFor = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuFreqFor = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;

        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(RewRareRem,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqRem,2) = 1;
        dm(NeuRareRem,2) = 1;
        dm(NeuFreqRem,2) = 1;
        dm(RewRareFor,3) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqFor,3) = 1;
        dm(NeuRareFor,3) = 1;
        dm(NeuFreqFor,3) = 1;

        to_demean = [];
        to_normalise = [];
        
        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        con(end+1,:) = [0 1 -1];
        conlist ={'Remembered', 'Forgotten', 'Remembered vs Forgotten'};

    case 'Remembered_Rew_v_Neu' % adjust this for your individual, is the name you set in S.dm_type
        
        nEVs = 6; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;

        % memory data
        remembered1  = find(tmp1.dat.all.memory.remembered_all_d1==1);
        forgotten1   = find(tmp1.dat.all.memory.forgotten_all_d1==1);
        remembered2  = find(tmp1.dat.all.memory.remembered_all_d2==1)+180;
        forgotten2   = find(tmp1.dat.all.memory.forgotten_all_d2==1)+180;
        
        % index regressors, original design matrix in this order
        RewRareRem = find((stimvec2==contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        RewFreqRem = find((stimvec1==contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuRareRem = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuFreqRem = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        
        RewRareFor = find((stimvec2==contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;
        RewFreqFor = find((stimvec1==contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuRareFor = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuFreqFor = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;

        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(RewRareRem,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqRem,2) = 1;
        dm(NeuRareRem,3) = 1;
        dm(NeuFreqRem,3) = 1;
        dm(RewRareFor,4) = 0; % regressor data! zscore % nTR - volume, 
        dm(RewFreqFor,5) = 0;
        dm(NeuRareFor,6) = 0;
        dm(NeuFreqFor,7) = 0;

        to_demean = [];
        to_normalise = [];

        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        % con(end+1,:) = [0 1 -1];
        con(end+1,:) = [0 1 -1 0 0 0 0];
        con(3:(end-1),:)=[];
        conlist ={'Reward Remembered', 'Neutral Remembered', 'Remebered: Reward vs Neutral'};

    case 'Remembered_Infrequent_v_Frequent' % adjust this for your individual, is the name you set in S.dm_type
        
        nEVs = 6; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;

        % memory data
        remembered1  = find(tmp1.dat.all.memory.remembered_all_d1==1);
        forgotten1   = find(tmp1.dat.all.memory.forgotten_all_d1==1);
        remembered2  = find(tmp1.dat.all.memory.remembered_all_d2==1)+180;
        forgotten2   = find(tmp1.dat.all.memory.forgotten_all_d2==1)+180;
        
        % index regressors, original design matrix in this order
        RewRareRem = find((stimvec2==contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        RewFreqRem = find((stimvec1==contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuRareRem = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuFreqRem = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        
        RewRareFor = find((stimvec2==contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;
        RewFreqFor = find((stimvec1==contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuRareFor = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuFreqFor = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;

        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(RewRareRem,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqRem,3) = 1;
        dm(NeuRareRem,2) = 1;
        dm(NeuFreqRem,3) = 1;
        dm(RewRareFor,4) = 0; % regressor data! zscore % nTR - volume, 
        dm(RewFreqFor,5) = 0;
        dm(NeuRareFor,6) = 0;
        dm(NeuFreqFor,7) = 0;

        to_demean = [];
        to_normalise = [];

        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        % con(end+1,:) = [0 1 -1];
        con(end+1,:) = [0 1 -1 0 0 0 0];
        con(3:(end-1),:)=[];
        conlist ={'Infrequent Remembered', 'Frequent Remembered', 'Remebered: Infrequent vs Frequent'};

    case 'Rewards_Remembered_v_Forgotten' % adjust this for your individual, is the name you set in S.dm_type  
        
        nEVs = 6; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;

        % memory data
        remembered1  = find(tmp1.dat.all.memory.remembered_all_d1==1);
        forgotten1   = find(tmp1.dat.all.memory.forgotten_all_d1==1);
        remembered2  = find(tmp1.dat.all.memory.remembered_all_d2==1)+180;
        forgotten2   = find(tmp1.dat.all.memory.forgotten_all_d2==1)+180;
        
        % index regressors, original design matrix in this order
        RewRareRem = find((stimvec2==contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        RewFreqRem = find((stimvec1==contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuRareRem = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuFreqRem = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        
        RewRareFor = find((stimvec2==contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;
        RewFreqFor = find((stimvec1==contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuRareFor = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuFreqFor = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;

        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(RewRareRem,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqRem,2) = 1;
        dm(NeuRareRem,4) = 0;
        dm(NeuFreqRem,5) = 0;
        dm(RewRareFor,3) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqFor,3) = 1;
        dm(NeuRareFor,6) = 0;
        dm(NeuFreqFor,7) = 0;

        to_demean = [];
        to_normalise = [];

        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        % con(end+1,:) = [0 1 -1];
        con(end+1,:) = [0 1 -1 0 0 0 0];
        con(3:(end-1),:)=[];
        conlist ={'Reward Remembered', 'Reward Forgotten', 'Rewards: Remembered vs Forgotten'};


    case 'Rares_Remembered_v_Forgotten' % adjust this for your individual, is the name you set in S.dm_type

        nEVs = 6; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials

        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);


        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials

        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;

        % memory data
        remembered1  = find(tmp1.dat.all.memory.remembered_all_d1==1);
        forgotten1   = find(tmp1.dat.all.memory.forgotten_all_d1==1);
        remembered2  = find(tmp1.dat.all.memory.remembered_all_d2==1)+180;
        forgotten2   = find(tmp1.dat.all.memory.forgotten_all_d2==1)+180;

        % index regressors, original design matrix in this order
        RewRareRem = find((stimvec2==contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        RewFreqRem = find((stimvec1==contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuRareRem = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuFreqRem = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;

        RewRareFor = find((stimvec2==contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;
        RewFreqFor = find((stimvec1==contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuRareFor = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuFreqFor = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;

        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(RewRareRem,2) = 1; % regressor data! zscore % nTR - volume,
        dm(RewFreqRem,4) = 0;
        dm(NeuRareRem,2) = 1;
        dm(NeuFreqRem,5) = 0;
        dm(RewRareFor,3) = 1; % regressor data! zscore % nTR - volume,
        dm(RewFreqFor,6) = 0;
        dm(NeuRareFor,3) = 1;
        dm(NeuFreqFor,7) = 0;

        to_demean = [];
        to_normalise = [];

        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        % con(end+1,:) = [0 1 -1];
        con(end+1,:) = [0 1 -1 0 0 0 0];
        con(3:(end-1),:)=[];
        conlist ={'Infrequent Remembered', 'Infrequent Forgotten', 'Infrequents: Remembered vs Forgotten'};


    case 'RemRewNeu_RemRareFreq' % adjust this for your individual, is the name you set in S.dm_type  
        
        nEVs = 8; % this maybe has to be 4

        % big reward day
        stimvec1 = cell2mat(tmp1.dat.day1.results.trl(:,2)); % read the trial data
        stimvec1(find(isnan(stimvec1)))=[]; % clean up null trials
      
        contingency1=str2num(tmp1.dat.day1.RewardCategory(9));
        frequentreward = find(stimvec1==contingency1); % label 1 = reward, 2 = neutral
        rareneutral = find(stimvec1~=contingency1);
        
        
        % small reward day
        stimvec2 = cell2mat(tmp1.dat.day2.results.trl(:,2)); % read the trial data
        stimvec2(find(isnan(stimvec2)))=[]; % clean up null trials
        
        contingency2=str2num(tmp1.dat.day2.RewardCategory(9));
        rarereward = find(stimvec2==contingency2)+180; % label 1 = reward, 2 = neutral
        frequentneutral = find(stimvec2~=contingency2)+180;

        % memory data
        remembered1  = find(tmp1.dat.all.memory.remembered_all_d1==1);
        forgotten1   = find(tmp1.dat.all.memory.forgotten_all_d1==1);
        remembered2  = find(tmp1.dat.all.memory.remembered_all_d2==1)+180;
        forgotten2   = find(tmp1.dat.all.memory.forgotten_all_d2==1)+180;
        
        % index regressors, original design matrix in this order
        RewRareRem = find((stimvec2==contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        RewFreqRem = find((stimvec1==contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuRareRem = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.remembered_all_d1==1));
        NeuFreqRem = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.remembered_all_d2==1))+180;
        
        RewRareFor = find((stimvec2==contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;
        RewFreqFor = find((stimvec1==contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuRareFor = find((stimvec1~=contingency1)&(tmp1.dat.all.memory.forgotten_all_d1==1));
        NeuFreqFor = find((stimvec2~=contingency2)&(tmp1.dat.all.memory.forgotten_all_d2==1))+180;

        dm = zeros(nTr,nEVs+1);
        dm(:,1) = ones(nTr,1); % insert intercept

        % stim regressors
        dm(RewRareRem,2) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqRem,2) = 1;
        dm(NeuRareRem,3) = 1;
        dm(NeuFreqRem,3) = 1;

        dm(RewRareRem,4) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqRem,5) = 1;
        dm(NeuRareRem,4) = 1;
        dm(NeuFreqRem,5) = 1;

        dm(RewRareFor,6) = 1; % regressor data! zscore % nTR - volume, 
        dm(RewFreqFor,7) = 1;
        dm(NeuRareFor,8) = 1;
        dm(NeuFreqFor,9) = 1;

        to_demean = [];
        to_normalise = [];
        
        con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
        % con(end+1,:) = [0 1 -1];

        con(end+1,:) = [0 1 0 -1 0 0 0 0 0];
        con(end+1,:) = [0 -1 0 1 0 0 0 0 0];
        con(5:(end-2),:)=[];

        conlist ={'Reward', 'Neutral', 'Infrequent', 'Frequent','Remembered Reward > Remembered Rare', 'Remembered Rare > Remembered Reward'};

    otherwise
        error('Unrecognised dm_type');
end



% =========== LEGACY CODE =========== %
% switch dm_type % 
%     case 'placebelief' % adjust this for your individual, is the name you set in S.dm_type  
%         nEVs = 2;
%         modeldat = zscore(modelres(wo).prior(:,2)-.5);
%         dum = zeros(1,128);
%         dmdum = nan(length(dum),1);dmdum(trlnotraus)= modeldat;
%         % remove first trial in every run and fill only those trials that
%         % we have behavioral data on, those are deleted lateron
%         dmdum(1:32:end) = [];
%         dm = nan(nTr,nEVs);
%         dm(:,1) = ones(nTr,1);
%         dm(:,2) = dmdum;clear dum dmdum
%         
%         to_demean = [];
%         to_normalise = [];
%         
%         con =  eye(size(dm,2)); con(1,:) = []; %everything except main effect, same contrasts as in individual GLM on first level
%         conlist ={'place belief'};
%         
%         
%     otherwise
%         error('Unrecognised dm_type');
% end

%% demean/normalise appropriate regressors
dm(:,to_demean) = do_nonzero_demean(dm(:,to_demean)); % - repmat(nanmean(dm(:,to_demean),1),nTr,1);
dm(:,to_normalise) = (dm(:,to_normalise) - repmat(nanmean(dm(:,to_normalise),1),nTr,1))...
    ./repmat(nanstd(dm(:,to_normalise),[],1),nTr,1);
if exist('to_demean_nonzeros','var')
    for i = 1:length(to_demean_nonzeros)
        r = to_demean_nonzeros(i);
        if any(to_demean==r)
            error('cannot have same regressor in to_demean and to_demean_nonzeros');
        end
        nZ = (dm(:,r)~=0)&(~isnan(dm(:,r)));
        dm(nZ,r) = dm(nZ,r) - repmat(mean(dm(nZ,r)),sum(nZ),1);
    end
end

end


%%
function regr = load_regressor(fname)
tmp = load(fname);
regr = tmp(:,3);
end

function out = do_nonzero_demean(in)

if ndims(in)>2
    error('too many dims')
end


out = in;
for i = 1:size(in,2)
    ind = in(:,i)~=0&~isnan(in(:,i));
    mn = mean(in(ind,i),1);
    out(ind,i) = in(ind,i) - mn;
end

end


