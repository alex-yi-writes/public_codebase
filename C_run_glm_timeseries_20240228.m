% prepare data for regression analyses

% This makes a timeseries of the beta effects of particular contrasts in
% glms as e.g. in Boorman 2013 JN, Figure 5
% the key is to make a matrix of time by trials, and then a design matrix of trials by EVs,
% to estimate a matrix of betas within each subject of EVs by time
% 1. Make matrix time after particular trial in an area, read out per
% subject

% this needs time points of relevant events in the trial as input, 

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


% GLM: BelSurGaiLosXtRT_ortho
%% preparation

clear
close all

addpath('/Users/alex/Dropbox/paperwriting/3tpilot/scripts/make_timeseries_data_again')

ids = [2202 2203 2204 2205 2206 2207 2208 2109 2110 2112 2113 2114 2115 2116 2217 2218 2219 2220 ...
    2221 2222 2223 2224 2125 2126 2127 2128 2129 2130 2131 2132 2233 2234 2235 2236 2237 2238 2239 ...
    2240 2142 2143 2144 2145 2146 2147 2148 2249 2250];

% --- list of masks --- %
% masks.Rew_Neu_fb_grey   
% masks.Rew_Neu_stim_grey   
% masks.Rare_Freq_fb_grey
% masks.Rare_Freq_stim_grey 
% masks.Rem_v_Forg_stim_grey 
% 
% masks.Rewards_Rem_v_Forg_stim_grey...
% masks.Rares_Rem_v_Forg_stim_grey...
% masks.Interaction_stim_reward_x_frequency...
% masks.PositiveInteraction_stim_reward_x_frequency...
% masks.PositiveInteraction_stim_frequency_x_memory...
% masks.PositiveInteraction_stim_reward_x_memory...
% masks.PositiveInteraction_stim_reward_x_frequency_SNonly
% 
% masks.LC             
% masks.SN          
% masks.VTA
% masks.NAcc
% 
% masks.SFC_L       
% masks.IFC_R    
% masks.MFC_L    
% masks.Precuneus   
% masks.Precuneus_L
% masks.Fusiform     
% masks.Rem_Rare_v_Freq_dSN

% masks.caudate 
% masks.putamen 
% masks.OFC 
% masks.ACC 
% masks.insula 
% masks.amygdala 
% masks.temporoparietal 


colourflag = 0;
yas = find(ids < 4000);

% namestype = {'FrequentReward';'RareNeutral';'RareReward';'FrequentNeutral'};

% namestype = {'Reward';'Neutral';'Reward vs Neutral'};
% namestype = {'Infrequent';'Frequent';'Infrequent vs Frequent'};

% namestype = {'Remembered';'Forgotten';'Remembered vs Forgotten'};

% namestype = {'Reward Remembered', 'Reward Forgotten', 'Rewards: Remembered vs Forgotten'};
% namestype = {'Infrequent Remembered', 'Infrequent Forgotten', 'Infrequents: Remembered vs Forgotten'}

% namestype ={'Reward', 'Neutral', 'Infrequent', 'Frequent'}; colourflag=1;
% namestype ={'Frequent Reward', 'Infrequent Neutral', 'Infrequent Reward', 'Frequent Neutral'}; colourflag=9;
% namestype ={'Reward', 'Neutral', 'Infrequent', 'Frequent','Remembered Reward > Remembered Rare', 'Remembered Rare > Remembered Reward'}; colourflag=2;

namestype = {'Reward Remembered', 'Neutral Remembered', 'Remembered: Reward vs Neutral'}
% namestype = {'Infrequent Remembered', 'Frequent Remembered', 'Remebered: Infrequent vs Frequent'};

for regtype = 1:length(namestype)
    
    S.dm_type = 'Remembered_Rew_v_Neu';
    S.maskname = 'PositiveInteraction_stim_frequency_x_memory';% mask for effect (ROI)
    S.locking = 'stim'; % which time point is of interest
    S.masknum = 1;

    S.subjlist = cellstr(num2str(ids'));
    S.figurepath = '/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/'; % where to save, adjust
    S.plotcon = 5; % which contrast from the regression run here to plot, intercept is 1 and deleted
    S.plotT = 0; % 0 is Mean and SE, 1 would be t-value
    S.bl_plot = 8.5; %baseline duration, adjust
    S.TR = 3.6; % adjust with study TR
    S.bc = 1;
    S.EVdir = ['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/'];% to be completed for individual within for rlp
    S.tsdir = ['/Users/alex/Dropbox/paperwriting/3tpilot/data/timeseries_collated/'];
    
    % group contrast
    S.group_dm = ones(length(ids),1); % how many people in which group, adjust
    S.group_con = [1];
    S.gc_names = {'none'};
    [dat,badtr,ssc,tt_dat,event,ssv,sst,conlist,vg,cg,filenamefig] = funx_mrpetpilot_all(S);
    sscstore(regtype,:,:,:) = ssc;
    vgstore(regtype,:,:,:) = vg;
    cgstore(regtype,:,:,:) = cg;
    
end
clear vg cg ssc sst ssv
vg = squeeze(nanmean(vgstore));
cg = squeeze(nanmean(cgstore));
ssc = squeeze(nanmean(sscstore));


% alternative plotting

close all

% rainbow = {'-r' '-g' '-b' '-c' '-y' '-k'};
% rainbowoa = {'r' 'g' 'b' 'c' 'y' 'k'};
% rainbowoa = {'r' 'b' 'r' 'b'};
if length(namestype) >= 4
    if colourflag==0
        linecolour=[1 0 0; 0 0 1; 1 0.1 0.1; 0.1 0.1 1];
        shadecolour=[1 0.3 0.3; 0.3 0.3 1; 1 0.5 0.5; 0.5 0.5 1];
    elseif colourflag==1
        linecolour=[255/255 57/255 40/255; 
            36/255 40/255 255/255; 
            255/255 139/255 21/255; 
            42/255 164/255 15/255];
        shadecolour=[234/255 85/255 72/255; 
            66/255 69/255 247/255; 
            241/255 161/255 78/255; 
            88/255 153/255 74/255];
    elseif colourflag==2
        linecolour=[255/255 57/255 40/255; 
            36/255 40/255 255/255; 
            255/255 139/255 21/255; 
            42/255 164/255 15/255;
            1 1 0;
            0.3 0.3 0.3];
        shadecolour=[234/255 85/255 72/255; 
            66/255 69/255 247/255; 
            241/255 161/255 78/255; 
            88/255 153/255 74/255;
            0.6 0.6 0.6;
            0.3 0.3 0.3];

     elseif colourflag==9
        linecolour=[255/255 57/255 40/255; 
            36/255 40/255 255/255; 
            255/255 57/255 40/255; 
            36/255 40/255 255/255];
        shadecolour=[234/255 85/255 72/255; 
            66/255 69/255 247/255; 
            234/255 85/255 72/255; 
            66/255 69/255 247/255];
    end
else
    % rem vs forg
    % linecolour=[0 1 0; 1 0 0; 0.3 0.3 0.3; 0.1 0.1 1];
    % shadecolour=[0.3 1 0.3; 1 0.3 0.3; 0.6 0.6 0.6; 0.5 0.5 1];

    % rew vs neu
    % linecolour=[255/255 57/255 40/255; 
    %         36/255 40/255 255/255; 
    %         0.3 0.3 0.3];
    % shadecolour=[234/255 85/255 72/255; 
    %         66/255 69/255 247/255; 
    %         0.3 0.3 0.3];

    % rare vs freq
    linecolour=[ 255/255 139/255 21/255; 
            42/255 164/255 15/255; 0.3 0.3 0.3];
    shadecolour=[241/255 161/255 78/255; 
            88/255 153/255 74/255;
            0.6 0.6 0.6];
end

linetypes = {'-','-.'}; % dashed is frequent
figure; colcnt=0;


for i = 1:length(namestype)
%     subplot(3,6,i);
    % plot separately for age groups, adjust
    yas = find(str2num(cell2mat(S.subjlist)) < 4000);

    disp(namestype{i})

    if length(namestype) >= 4
        if colourflag==0
            if (i==2) | (i==3)
                lt=1;
            else
                lt=2;
            end
        elseif colourflag==1
            lt=1;
        elseif colourflag==2
            if (i==1) | (i==2) | (i==3) | (i==4)
                lt=1;
            else
                lt=2;
            end

        elseif colourflag==9
            if (i==2) | (i==3) 
                lt=1;
            elseif (i==1) | (i==4)
                lt=2;
            end
        end
    else
        lt=1;
    end

    saveforTstat{i} = squeeze(ssc(yas,i,:));
    
    time=tt_dat;
    meanEffectSize = nanmean(squeeze(ssc(yas,i,:)));
    SE = squeeze(nanstd(ssc(yas,i,:)))./sqrt(length(yas))';
    
    upperBound = meanEffectSize + SE';
    lowerBound = meanEffectSize - SE';
    
    
    % Plotting the mean effect size
    

    hold on;
    if (i==length(namestype)) & (length(namestype) < 4)
        h(i)=plot(time, meanEffectSize, 'LineWidth', 1, 'LineStyle','-.','Color',linecolour(i,:));
        % Adding the shaded area for the standard error
        fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
            shadecolour(i,:), 'FaceAlpha', 0.15, 'EdgeColor', 'none');
    else
        if colourflag==2
            if (i==length(namestype))| (i==(length(namestype)-1))
                h(i)=plot(time, meanEffectSize, 'LineWidth', 1, 'LineStyle','-.','Color',linecolour(i,:));
                % Adding the shaded area for the standard error
                fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
                    shadecolour(i,:), 'FaceAlpha', 0.15, 'EdgeColor', 'none');
            else
                h(i)=plot(time, meanEffectSize, 'LineWidth', 5, 'LineStyle',linetypes{lt},'Color',linecolour(i,:));
                % Adding the shaded area for the standard error
                fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
                    shadecolour(i,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
            end
        else
            h(i)=plot(time, meanEffectSize, 'LineWidth', 5, 'LineStyle',linetypes{lt},'Color',linecolour(i,:));
            % Adding the shaded area for the standard error
            fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
                shadecolour(i,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');
        end
    end



end

% plot events
xl = [min(tt_dat) max(tt_dat)];
set(gca,'XLim',xl,'FontSize',12);
line([xl(1) xl(2)],[0 0],'LineWidth',1,'Color','k');%,'linestyle',':')
yl = get(gca,'Ylim');
for ev = 1:(length(event))
    line([event(ev).time-S.bl_plot event(ev).time-S.bl_plot],[yl(1) yl(2)],'LineWidth',2,'Color',[.5 .5 .5],'linestyle',':');
    t = text(event(ev).time-S.bl_plot, yl(2), event(ev).name, 'HorizontalAlignment', 'right'); % Align text to the right of the line
    set(t, 'Rotation', 90, 'FontSize', 18, 'fontweight', 'bold','VerticalAlignment', 'bottom'); % Rotate 90 degrees and align to the bottom of the text
%     t = text(event(ev).time-S.bl_plot,(yl(2)+.2)*0.55,event(ev).name);
%     set(t,'Rotation',45,'FontSize',14);
end
% xlim(xl);ylim(yl);
xlim([-2 13]);ylim(yl);
clear t xl yl


%==========significance testing===========%

if colourflag==1

% Perform the paired t-test: Rew vs Neu
[H1, P1] = ttest(saveforTstat{1}, saveforTstat{2}); 
sigbar1 = double(H1) * -0.2;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'g', 'LineWidth', 5, 'MarkerFaceColor','g');


% Perform the paired t-test: Rare vs Freq
[H1, P1] = ttest(saveforTstat{3}, saveforTstat{4}); 
sigbar1 = double(H1) * -0.22;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'c', 'LineWidth', 5, 'MarkerFaceColor', 'c');


% Perform the paired t-test: Rare vs Rew
[H1, P1] = ttest(saveforTstat{1}, saveforTstat{3}); 
sigbar1 = double(H1) * -0.24;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'k', 'LineWidth', 5, 'MarkerFaceColor', 'k');



% Perform the paired t-test: Neu vs Freq
[H1, P1] = ttest(saveforTstat{2}, saveforTstat{4}); 
sigbar1 = double(H1) * -0.26;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'y', 'LineWidth', 5, 'MarkerFaceColor', 'y');


elseif colourflag==9

% Perform the paired t-test: Rew vs Neu
[H1, P1] = ttest(saveforTstat{1}, saveforTstat{2}); 
sigbar1 = double(H1) * -0.4;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'g', 'LineWidth', 5, 'MarkerFaceColor','g');


% Perform the paired t-test: Rare vs Freq
[H1, P1] = ttest(saveforTstat{3}, saveforTstat{4}); 
sigbar1 = double(H1) * -0.42;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'c', 'LineWidth', 5, 'MarkerFaceColor', 'c');


% Perform the paired t-test: Rare vs Rew
[H1, P1] = ttest(saveforTstat{1}, saveforTstat{3}); 
sigbar1 = double(H1) * -0.44;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'k', 'LineWidth', 5, 'MarkerFaceColor', 'k');



% Perform the paired t-test: Neu vs Freq
[H1, P1] = ttest(saveforTstat{2}, saveforTstat{4}); 
sigbar1 = double(H1) * -0.46;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'y', 'LineWidth', 5, 'MarkerFaceColor', 'y');


else
% Perform the paired t-test
[H1, P1] = ttest(saveforTstat{1}, saveforTstat{2}); 
sigbar1 = double(H1) * -0.0001;  % Scale for visibility
sigbar1(sigbar1 == 0) = NaN;  % Use NaN for non-significant points

% Debug output
disp('Number of significant points:');
disp(sum(~isnan(sigbar1)));

% Plotting significant differences
hold on;
plot(time, sigbar1, 'k', 'LineWidth', 5, 'MarkerFaceColor', 'k');

end
%=========================================%

legend(h, namestype, 'Interpreter', 'none','Location','northeastoutside','FontSize',14);
xlabel('Time (s)','FontSize',20,'FontWeight','bold');
ylabel('Effect size (Mean\pmSE,[a.u.])','FontSize',20,'FontWeight','bold');
set(gca,'YTickLabel');

title([ namestype{end} ', mask ' S.maskname ', ' S.locking '-locked'],'Interpreter', 'none','FontSize',25);

grid on
box on

h = gcf; set(h,'Position',[100 100 1019 434]);
saveas(h,[filenamefig ],'fig');
print('-depsc','-r300',[filenamefig '_']);

%% multi-plotting
% 
% dat_rare=load('/Users/alex/Dropbox/paperwriting/3tpilot/figures/time_series_plots/ROI-PosInteractionFreqXRew_RaresRemForg.mat');
% dat_rew=load('/Users/alex/Dropbox/paperwriting/3tpilot/figures/time_series_plots/ROI-PosInteractionFreqXRew_RewardsRemForg.mat');

dat_rare=load('/Users/alex/Dropbox/paperwriting/3tpilot/figures/time_series_plots/ROI-SN_RaresRem-vs-Forg_stim.mat');
dat_rew=load('/Users/alex/Dropbox/paperwriting/3tpilot/figures/time_series_plots/ROI-SN_RewardsRem-vs-Forg_stim.mat');



% alternative plotting

namestype={'Reward Remembered', 'Reward Forgotten', 'Infrequent Remembered', 'Infrequent Forgotten'};colourflag=1;
% namestype = {'Rare Remembered', 'Rare Forgotten', 'Rares: Remembered vs Forgotten'}

close all

% rainbow = {'-r' '-g' '-b' '-c' '-y' '-k'};
% rainbowoa = {'r' 'g' 'b' 'c' 'y' 'k'};
% rainbowoa = {'r' 'b' 'r' 'b'};
if length(namestype) >= 4
    if colourflag==0
        linecolour=[1 0 0; 0 0 1; 1 0.1 0.1; 0.1 0.1 1];
        shadecolour=[1 0.3 0.3; 0.3 0.3 1; 1 0.5 0.5; 0.5 0.5 1];
    elseif colourflag==1
        linecolour=[255/255 57/255 40/255; 
            36/255 40/255 255/255; 
            255/255 139/255 21/255; 
            42/255 164/255 15/255];
        shadecolour=[234/255 85/255 72/255; 
            66/255 69/255 247/255; 
            241/255 161/255 78/255; 
            88/255 153/255 74/255];
    end
else
    linecolour=[0 1 0; 1 0 0; 0.3 0.3 0.3; 0.1 0.1 1];
    shadecolour=[0.3 1 0.3; 1 0.3 0.3; 0.6 0.6 0.6; 0.5 0.5 1];
    % linecolour=[1 0 0; 0 0 1; 0 1 0; 0.1 0.1 1];
    % shadecolour=[1 0.3 0.3; 0.3 0.3 1; 0.3 1 0.3; 0.5 0.5 1];
end

linetypes = {'-','-.'}; % dashed is frequent
figure; colcnt=0;

%     subplot(3,6,i);
% plot separately for age groups, adjust
yas = find(str2num(cell2mat(S.subjlist)) < 4000);

% Reward Remembered
time=tt_dat;
meanEffectSize = nanmean(squeeze(dat_rew.ssc(yas,1,:)));
SE = squeeze(nanstd(dat_rew.ssc(yas,1,:)))./sqrt(length(yas))';
upperBound = meanEffectSize + SE';
lowerBound = meanEffectSize - SE';

% Plotting the mean effect size
hold on;
h(1)=plot(time, meanEffectSize, 'LineWidth', 5, 'LineStyle',linetypes{1},'Color',linecolour(1,:));

% Adding the shaded area for the standard error
fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
    shadecolour(1,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');


% Reward Forgotten
time=tt_dat;
meanEffectSize = nanmean(squeeze(dat_rew.ssc(yas,2,:)));
SE = squeeze(nanstd(dat_rew.ssc(yas,2,:)))./sqrt(length(yas))';
upperBound = meanEffectSize + SE';
lowerBound = meanEffectSize - SE';

% Plotting the mean effect size
hold on;
h(2)=plot(time, meanEffectSize, 'LineWidth', 5, 'LineStyle',linetypes{2},'Color',linecolour(1,:));

% Adding the shaded area for the standard error
fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
    shadecolour(1,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');


% Rare Remembered
time=tt_dat;
meanEffectSize = nanmean(squeeze(dat_rare.ssc(yas,1,:)));
SE = squeeze(nanstd(dat_rare.ssc(yas,1,:)))./sqrt(length(yas))';
upperBound = meanEffectSize + SE';
lowerBound = meanEffectSize - SE';

% Plotting the mean effect size
hold on;
h(3)=plot(time, meanEffectSize, 'LineWidth', 5, 'LineStyle',linetypes{1},'Color',linecolour(3,:));

% Adding the shaded area for the standard error
fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
    shadecolour(3,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');

% Rare Forgotten
time=tt_dat;
meanEffectSize = nanmean(squeeze(dat_rare.ssc(yas,2,:)));
SE = squeeze(nanstd(dat_rare.ssc(yas,2,:)))./sqrt(length(yas))';
upperBound = meanEffectSize + SE';
lowerBound = meanEffectSize - SE';

% Plotting the mean effect size
hold on;
h(4)=plot(time, meanEffectSize, 'LineWidth', 5, 'LineStyle',linetypes{2},'Color',linecolour(3,:));

% Adding the shaded area for the standard error
fill([time, fliplr(time)], [upperBound, fliplr(lowerBound)], ...
    shadecolour(3,:), 'FaceAlpha', 0.3, 'EdgeColor', 'none');









% plot events
xl = [min(tt_dat) max(tt_dat)];
set(gca,'XLim',xl,'FontSize',12);
line([xl(1) xl(2)],[0 0],'LineWidth',1,'Color','k');%,'linestyle',':')
yl = get(gca,'Ylim');
for ev = 1:(length(event))
    line([event(ev).time-S.bl_plot event(ev).time-S.bl_plot],[yl(1) yl(2)],'LineWidth',2,'Color',[.5 .5 .5],'linestyle',':');
    t = text(event(ev).time-S.bl_plot, yl(2), event(ev).name, 'HorizontalAlignment', 'right'); % Align text to the right of the line
    set(t, 'Rotation', 90, 'FontSize', 18, 'fontweight', 'bold','VerticalAlignment', 'bottom'); % Rotate 90 degrees and align to the bottom of the text
%     t = text(event(ev).time-S.bl_plot,(yl(2)+.2)*0.55,event(ev).name);
%     set(t,'Rotation',45,'FontSize',14);
end
% xlim(xl);ylim(yl);
xlim([-2 13]);ylim(yl);
clear t xl yl


% Plotting significant differences
% hold on;
% plot(time, sigbar1, 'k-o', 'LineWidth', 5, 'MarkerFaceColor', 'k');

legend(h, namestype, 'Interpreter', 'none','Location','northeastoutside','FontSize',14);
xlabel('Time (s)','FontSize',20,'FontWeight','bold');
ylabel('Effect size (Mean\pmSE,[a.u.])','FontSize',20,'FontWeight','bold');
set(gca,'YTickLabel');

title([ namestype{end} ', mask PosInteractionFreqXRew' ', ' S.locking '-locked'],'Interpreter', 'none','FontSize',25);

grid on

h = gcf; set(h,'Position',[100 100 1019 434]);
saveas(h,[filenamefig ],'fig');
print('-depsc','-r300',[filenamefig '_']);
