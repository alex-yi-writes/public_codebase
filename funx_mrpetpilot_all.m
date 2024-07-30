function [dat,badtr,ssc,tt_dat,event,ssv,sst,conlist,vg,cg,filenamefig] = funx_mrpetpilot_all(S);

% you only need to adjust the path where we read in the temporal data (e.g.
% line 88)


% ps_corr(S)
%
% fields of S:
% S.subjlist = {'subj102' 'subj103' etc.}; REQUIRED
% S.dm_type = 'stim_resp_vals'/'dimensions2'/'reward'; REQUIRED
% S.maskname; REQUIRED
% S.plotcon; which contrasts to plot, REQUIRED
% S.plotT; set to 1 (default) to plot T statistic or 0 to plot mean +/- s.e.
% S.locking = 'relock' [default]/'decide'/'response'/'feedback'
% S.TR; (in seconds; default 3.01s)
% S.upsrate; (fractions of a TR to upsample to; default 10)
% S.tsdir; directory in which timeseries are stored, with %s as subjID then %s as maskname (default '../%s/masks/%s.txt')
% S.EVdir; directory in which EVs are stored, with %s as subjID (default '../../EVs/%s')
% S.remove_artifacts; default 1 (peak to peak, 3 s.d. away from mean)
% S.group_dm/group_con/gc_names - specifies group level design matrix
% S.bc; to baseline correct data
% S.bl_plot; number of seconds of baseline to plot

%% handle input arguments
try subjlist = S.subjlist; catch, error('Must specify S.subjlist'); end
try dm_type = S.dm_type; catch, error('Must specify S.dm_type'); end
try maskname = S.maskname; catch, error('Must specify S.maskname'); end
try plotcon = S.plotcon; catch, error('Must specify S.plotcon'); end
try plotT = S.plotT; catch, plotT = 1; end
try locking = S.locking; catch, locking = 'relock'; end
try TR = S.TR; catch, TR = 3.01; end   % needs to be adjusted 
try upsrate = S.upsrate; catch, upsrate = 10; end
try tsdir = S.tsdir; catch, tsdir = '../%s/masks/%s.txt'; end
try EVdir = S.EVdir; catch, EVdir = '../../EVs/%s'; end
try bc = S.bc; catch, bc = 0; end
try bl_plot = S.bl_plot; catch, bl_plot = 2.5; end
try nuisance = S.nuisance; catch, nuisance = 0; end
try remove_artifacts = S.remove_artifacts; catch, remove_artifacts = 1; end
nS = length(subjlist); %number of subjects

try
    group_dm = S.group_dm;
catch
    group_dm = ones(nS,1);
    S.group_con = 1;
    S.gc_names = {'Group mean'};
end
try group_con = S.group_con; catch, group_con = eye(size(group_dm,2)); end
try gc_names = S.gc_names; catch, gc_names = cell(size(group_dm,2),1); end

%% load in timeseries , %%% modifed

if S.masknum > 1
    for i = 1:nS
        dumdat = [];
        for m = 1:S.masknum
            load([EVdir, subjlist{i}, filesep, maskname{m}, '.mat']); % needs to be adjusted 
            dumdat = [dumdat dat];clear dat
        end
        dat = nanmean(dumdat')';
        ts{i} = dat;clear dat
        nV(i) = length(ts{i}); %number of volumes
    end
    masknamesuff = 'aver';
else
    for i = 1:nS
        load([EVdir, subjlist{i}, filesep, maskname, '.mat']); % needs to be adjusted 
        ts{i} = dat;clear dat
        nV(i) = length(ts{i}); %number of volumes
    end
    masknamesuff = '';
end


%% load in times, %%% modified (mean instead of median and loading in of data)

for i = 1:nS
    disp(['PROCESSING ' subjlist{i}]);
    
    load([EVdir subjlist{i} '/' subjlist{i} '_timeinfo.mat']); % needs to be adjusted
    
    %load in decide times
    dectimes{i} = onsets.stim; %times (in s) of decide onset
    decdur{i} = durations.stim; %duration (in s) of decision
    meddecdur(i) = mean(decdur{i}); %median duration of decision for subject i
    nTr(i,1) = size(dectimes{i},1); %number of trials, based on decision EV
    
    %load in response times
%     load([EVdir subjlist{i} '/model/rflp/response_onset.mat']); % needs to be adjusted 
    resptimes{i} = onsets.response;
    respdur{i} = durations.response;
    medrespdur(i) = mean(respdur{i});
    nTr(i,2) = size(resptimes{i},1);

    %load in dot separator
    dottimes{i} = onsets.dot;
    dotdur{i} = durations.dot;
    meddotdur(i) = mean(dotdur{i});
    nTr(i,3) = size(dottimes{i},1);
    
    %load in feedback times
%     load([EVdir subjlist{i} '/model/rflp/feedback_onset.mat']); % needs to be adjusted 
    fbtimes{i} = onsets.feedback;
    fbdur{i} = durations.feedback;
    medfbdur(i) = mean(fbdur{i});
    nTr(i,4) = size(fbtimes{i},1);
    
    %load in ITI times
%     load([EVdir subjlist{i} '/model/rflp/ITI_onset.mat']); % needs to be adjusted 
    ITItimes{i} = onsets.trial;
    ITIdur{i} = durations.trial;
    medITIdur(i) = mean(ITIdur{i});
    nTr(i,5) = size(ITItimes{i},1);

    
    if length(unique(nTr(i,:)))~=1
        error('Different numbers of trials in decide/response/feedback/ITI EVs, subject %s',subjlist{i});
    end
end

nTr = nTr(:,1); %number of good trials for each subject


%% create upsampled time-locked data matrix
%find length of time for which to plot data
TR_ups = TR/upsrate; %TR of upsampled data

switch locking
    case 'stim'
        relock_gap = 0; %gap (in seconds) to place between decide-locked timeseries and feedback-locked timeseries
        if relock_gap ~=0
            warning('trying to place gap between decide/feedback epochs - not yet tested');
        end
        dec_baseline = bl_plot; %baseline period (in seconds) to place before decide-locked timeseries (5)
        
        dur_declock = ceil((mean(meddecdur)+mean(medrespdur)+mean(meddotdur)+mean(medfbdur)+mean(medITIdur))/TR_ups); %how many (upsampled) samples to include after dec onset
        dur_fblock = dur_declock;  %how many (upsampled) samples to include after feedback onset
        
        event(1).name = 'Scene'; event(1).time = dec_baseline;
        event(2).name = 'Response'; event(2).time = event(1).time+mean(meddecdur);
        event(3).name = 'Baseline'; event(3).time = event(2).time+mean(medrespdur);
        event(4).name = 'Feedback'; event(4).time = event(3).time+mean(meddotdur)+relock_gap;
        
        event(5).name = 'ITI'; event(5).time = event(4).time+mean(medfbdur);
        event(6).name = 'Next trial start'; event(6).time = event(1).time+mean(medITIdur);
        
        relock_gap = round(relock_gap/TR_ups); %convert to TRs
        dec_baselineR = round(dec_baseline/TR_ups); %convert to TRs
        
    case 'response'
        dec_baseline = bl_plot; %baseline period (in seconds) to place before decide-locked timeseries (10)
        dur_declock = 15; %duration (in seconds) to include after dec onset (15)
        
        event(1).name = 'Response'; event(1).time = dec_baseline;
        event(2).name = 'Feedback'; event(2).time = event(1).time+mean(medrespdur);
        
        event(3).name = 'ITI'; event(3).time = event(1).time+mean(medfbdur);
        event(4).name = 'Scene'; event(4).time = event(3).time+mean(medITIdur);

        event(5).name = 'Response'; event(5).time = event(4).time+mean(meddecdur);
        event(6).name = 'Baseline'; event(6).time = event(5).time+mean(medrespdur);
        
        dec_baselineR = round(dec_baseline/TR_ups); %convert to TRs
        dur_declock = round(dur_declock/TR_ups); %convert to TRs
        
    case 'feedback'
        dec_baseline = bl_plot; %baseline period (in seconds) to place before decide-locked timeseries (8)
        dur_declock = 15; %duration (in seconds) to include after dec onset (8)
        
        event(1).name = 'Feedback'; event(1).time = dec_baseline;
        event(2).name = 'ITI'; event(2).time = event(1).time+mean(medfbdur);

        event(3).name = 'Scene'; event(3).time = event(2).time+mean(medITIdur);
        event(4).name = 'Response'; event(4).time = event(3).time+mean(meddecdur);

        event(5).name = 'Baseline'; event(5).time = event(4).time+mean(medrespdur);
        event(6).name = 'Feedback'; event(6).time = event(5).time+mean(meddotdur);
        
        dec_baselineR = round(dec_baseline/TR_ups); %convert to TRs
        dur_declock = round(dur_declock/TR_ups); %convert to TRs
        
    otherwise
        error('not yet implemented')
end


for i = 1:nS
    
    %demean and upsample timeseries
    ts{i}=ts{i}-mean(ts{i}); %demeaned data for subject i
    x=1:nV(i);
    xx=1:(1/upsrate):nV(i);
    ts_ups{i}=spline(x,ts{i},xx); %upsampled demeaned data for subject i
    nV_ups(i) = length(ts_ups{i}); %number of volumes in upsampled data for subject i
    clear x xx;
    
    %obtain time of each volume, in seconds
    tt_ups = 0:TR_ups:(nV_ups(i)-1)*TR_ups;
    
    %create appropriate matrix of time indices
    switch locking
        case 'stim'
            [decsamp_ups] = findc(tt_ups,dectimes{i}); %decsamp_ups is when dectimes occured in tt_ups
            [fbsamp_ups] = findc(tt_ups,fbtimes{i}); %decsamp_ups is when dectimes occured in tt_ups
            badtr{i} = logical(zeros(nTr(i),1));
            tind = [];
            for tr = 1:nTr(i)
                %calculate indices of interest in upsampled data:
                tind(tr,:) = [decsamp_ups(tr)-dec_baselineR:decsamp_ups(tr)+dur_declock fbsamp_ups(tr):fbsamp_ups(tr)+dur_fblock];
                if any(tind(tr,:)<1)|any(tind(tr,:)>nV_ups(i))
                    badtr{i}(tr) = true; %indexes trials that stretch outside the sampled timeseries
                end
            end
            samp_upS = decsamp_ups; % alex added - why was it missing here?
            
        case 'response'
            [decsamp_ups] = findc(tt_ups,dectimes{i}); %decsamp_ups is when dectimes occured in tt_ups
            badtr{i} = logical(zeros(nTr(i),1));
            tind = [];
            for tr = 1:nTr(i)
                %calculate indices of interest in upsampled data:
                tind(tr,:) = [decsamp_ups(tr)-dec_baselineR:decsamp_ups(tr)+dur_declock];
                if any(tind(tr,:)<1)|any(tind(tr,:)>nV_ups(i))
                    badtr{i}(tr) = true; %indexes trials that stretch outside the sampled timeseries
                end
            end
            samp_upS = decsamp_ups;

        case 'feedback'
            [fbsamp_ups] = findc(tt_ups,fbtimes{i}); %decsamp_ups is when dectimes occured in tt_ups
            badtr{i} = logical(zeros(nTr(i),1));
            tind = [];
            for tr = 1:nTr(i)
                %calculate indices of interest in upsampled data:
                tind(tr,:) = [fbsamp_ups(tr)-dec_baselineR:fbsamp_ups(tr)+dur_declock];
                if any(tind(tr,:)<1)|any(tind(tr,:)>nV_ups(i))
                    badtr{i}(tr) = true; %indexes trials that stretch outside the sampled timeseries
                end
            end
            samp_upS = fbsamp_ups;
    end
    
    %create data matrix, leaving nans in place on 'bad' trials (removed later, in regression)
    dat{i} = nan(size(tind));
    dat{i}(~badtr{i},:) = ts_ups{i}(tind(~badtr{i},:));
    
    %baseline correct, if requested
    if bc
        bl = nanmean(dat{i}(:,1:dec_baselineR),2); %baseline for each trial
        bl = repmat(bl,1,size(dat{i},2));
        dat{i} = dat{i} - bl;
    end
    
    %create vector of time indices
    tt_dat = -dec_baseline:TR_ups:(size(dat{i},2)-1)*TR_ups-dec_baseline;
    
    %optional artifact rejection
    if remove_artifacts
        Sa = [];
        Sa.method = 'peak2peak';
        arttr{i} = detect_artifacts(dat{i},Sa);
        badtr{i} = badtr{i}|arttr{i};
        dat{i}(arttr{i},:) = nan;
        clear Sa
    end
end

clear *times *dur *samp_ups i tind tmp tr tt_ups


%% create design matrix for each subject

if nuisance
    Sa = [];
    Sa.method = 'peak2peak';
end
for i = 1:nS
    [dm{i},con,conlist,badtr{i}] = create_design_matrix_mrpilot(EVdir,subjlist{i},dm_type,badtr{i},nTr(i),samp_upS);
    if nuisance % add in nuisance regressors, if requested
        [arttr,metric] = detect_artifacts(dat{i},Sa);
        %lasttr_p2p = [metric.mnmeas; metric.meas(1:end-1)];
        lasttr_p2p = metric.meas;
        lasttr_p2p(isnan(lasttr_p2p)) = metric.mnmeas;
        dm{i}(:,end+1) = normalise(lasttr_p2p);
        con(:,end+1) = 0;
        con(end+1,end) = 1;
        conlist{end+1} = 'nuisance';
    end
end

%% run regression on each subject

for i = 1:nS
    [c(i,:,:),v(i,:,:),t(i,:,:)] = ols(dat{i}(~badtr{i},:),dm{i}(~badtr{i},:),con);
end



%% do group analysis

nLC = size(con,1); %number of lower level contrasts
nSamp = size(c,3); %number of samples in timeseries
nHC = size(group_con,1); %number of higher level contrasts

c = reshape(c,nS,nLC*nSamp);
[cg,vg,tg] = ols(c,group_dm,group_con);

cg = reshape(cg,nHC,nLC,nSamp);
vg = reshape(vg,nHC,nLC,nSamp);
tg = reshape(tg,nHC,nLC,nSamp);


if nargout>=3
    ssc = reshape(c,nS,nLC,nSamp);
end
if nargout>=6
    ssv = reshape(v,nS,nLC,nSamp);
end
if nargout>=7
    sst = reshape(t,nS,nLC,nSamp);
end

%% do plotting

rainbow = {'-k' '-g' '-b' '-c' '-y' '-k'};    % younger adults
rainbowoa = {':k' ':g' ':b' ':c' ':y' ':k'};  % older adults
%  color_cond1 = [0.8500 0.3250 0.0980];
%             color_cond2 = [0, 0, 1];
%             color_cond3 = [0.9290, 0.6940, 0.1250];
%             color_cond4 = [0.3010, 0.7450, 0.9330];

brightred = [1 , 0 , 0]; % red is first condition
brightblue = [0 , 0 , 1];
darkred = [0.5 , 0 , 0];
darkblue = [0 , 0 , 0.5];

% figure;
% for i = 1:nLC
%     
%     subplot(3,6,i);
%     
%     % plot separately for age groups
%     yas = find(str2num(cell2mat(subjlist)) < 4000);
%     oas = find(str2num(cell2mat(subjlist)) > 4000);
%     
%     %     if plotT
%     %         h = plot(tt_dat,squeeze(tg(1,i,:)),'LineWidth',2);hold on
%     %     else
%     %         hold on;
%     %         tmp = shadedErrorBar(tt_dat,squeeze(cg(1,i,:)),squeeze(sqrt(vg(1,i,:))),'-r',0);
%     %
%     %         tmp = shadedErrorBar(tt_dat,squeeze(cg(1,i,:)),squeeze(sqrt(vg(1,i,:))),...
%     %             'lineprops',{'-','LineWidth',10,'color',brightred,'markerfacecolor',brightred});
%     % %         tmp = shadedErrorBar(tt_dat,squeeze(cg(1,i,:)),squeeze(sqrt(vg(1,i,:))),'lineprops',{{'-','LineWidth',10,'color',brightred,'markerfacecolor',brightred}});
%     %         h(i) = tmp.mainLine;
%     %         set(h(i),'LineWidth',2);
%     %
%     % %          tmp = shadedErrorBar(tt_dat,nanmean(squeeze(ssc(yas,i,:))),squeeze(nanstd(ssc(yas,i,:)))./sqrt(length(yas)),rainbow{1},0);   % younger adults
%     %         tmp = shadedErrorBar(tt_dat,nanmean(squeeze(ssc(yas,i,:))),squeeze(nanstd(ssc(yas,i,:)))./sqrt(length(yas)),'lineprops',{'-','LineWidth',10,'color',[0 0 0],'markerfacecolor',[0.5 0.5 0.5]});
%     %
%     % %         tmp = shadedErrorBar(tt_dat,nanmean(squeeze(ssc(yas,i,:))),squeeze(nanstd(ssc(yas,i,:)))./sqrt(length(yas)),'lineprops',{{'-','LineWidth',10,'color',[0 0 0],'markerfacecolor',[0.5 0.5 0.5]}});
%     %         h(i) = tmp.mainLine;
%     %         set(h(i),'LineWidth',2);
%     %         hold on
%     %
%     % %         tmp = shadedErrorBar(tt_dat,nanmean(squeeze(ssc(oas,i,:))),squeeze(nanstd(ssc(oas,i,:)))./sqrt(length(oas)),rainbowoa{1},0);  % older adults
%     %
%     %         tmp = shadedErrorBar(tt_dat,nanmean(squeeze(ssc(oas,i,:))),squeeze(nanstd(ssc(oas,i,:)))./sqrt(length(oas)),'lineprops',{':','LineWidth',10,'color',[0 0 0],'markerfacecolor',[0.5 0.5 0.5]});
%     %
%     % %         tmp = shadedErrorBar(tt_dat,nanmean(squeeze(ssc(oas,i,:))),squeeze(nanstd(ssc(oas,i,:)))./sqrt(length(oas)),'lineprops',{{':','LineWidth',10,'color',[0 0 0],'markerfacecolor',[0.5 0.5 0.5]}});
%     %         h(i) = tmp.mainLine;
%     %         set(h(i),'LineWidth',2);
%     %         hold on
%     %
%     %     end
%     %
%     if plotT
%         h = plot(tt_dat,squeeze(tg(1,i,:)),'LineWidth',2);
%     else
%         hold on;
%         
%         % Plot mean line
%         h(i) = plot(tt_dat, squeeze(cg(1,i,:)), '-', 'LineWidth', 2, 'Color', brightred); % Assuming brightred is defined elsewhere
%         hold on;
%         
%         % Plot error bands for younger adults
%         yas_mean = nanmean(squeeze(ssc(yas,i,:)));
%         yas_std = nanstd(squeeze(ssc(yas,i,:))) / sqrt(length(yas));
%         fill([tt_dat, fliplr(tt_dat)], [yas_mean + yas_std, fliplr(yas_mean - yas_std)], 'b', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%         
%         % Plot error bands for older adults
%         oas_mean = nanmean(squeeze(ssc(oas,i,:)));
%         oas_std = nanstd(squeeze(ssc(oas,i,:))) / sqrt(length(oas));
%         fill([tt_dat, fliplr(tt_dat)], [oas_mean + oas_std, fliplr(oas_mean - oas_std)], 'g', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
%         
%         hold on;
%         
%     end
%     
%     %plot events
%     xl = [max(-bl_plot,-dec_baseline) max(tt_dat)];
%     set(gca,'XLim',xl,'FontSize',12);
%     line([xl(1) xl(2)],[0 0],'LineWidth',2,'Color','k')
%     yl = get(gca,'Ylim');
%     for ev = 1:length(event)
%         line([event(ev).time-dec_baseline event(ev).time-dec_baseline],[yl(1) yl(2)]*0.5,'LineWidth',2,'Color','k');
%         t = text(event(ev).time-dec_baseline,(yl(2)+.2)*0.55,event(ev).name);
%         set(t,'Rotation',45,'FontSize',14);
%     end
%     clear t xl yl
%     
%     xlabel('Time (s)','FontSize',16);
%     if plotT
%         ylabel('T-statistic','FontSize',16);
%     else
%         ylabel('Effect size ( mean +/- s.e.; a.u. )','FontSize',16);
%     end
%     
%     if plotT
%         annotate_tmap(nS-1,gca); %%%%%%
%     else
%         set(gca,'YTickLabel',[]);
%     end
%     title(conlist{i});
% end

if size(maskname,1) > 1
    masknameplot = maskname{1};
elseif size(maskname,1) == 1
    masknameplot = maskname;
end

%h = gcf; %set(h,'Position',[100 100 1200 1200]);
%saveas(h,[S.figurepath masknameplot dm_type masknamesuff locking 'all_regr'],'fig');
% print('-depsc','-r300',[S.figurepath masknameplot dm_type masknamesuff locking 'all_regr']); % conlist{i}
filenamefig = [S.figurepath masknameplot dm_type masknamesuff locking 'all_regr'];
% close all