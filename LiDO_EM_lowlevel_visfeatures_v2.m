%% calculate and compare low-level visual features
% compares mean luminance, RMS contrast (aditya's suggestion), 
% and colour saturation between emotional and neutral IAPS images used
% in LiDO study datasets.
%
% mean luminance: our stimuli are already luminance controlled, but just in
% case, i calculated again for the mean luminance, which is just the
% arithmetic mean of pixel intensities
% 
% RMS contrast: it is called root mean square contrast. in this script,
% it is calculated based on a number of stackexchange posts 
% (for example this one:
% https://dsp.stackexchange.com/questions/64409/rms-contrast-of-image-interpretation)
% and this publication: Bex, Peter J.; Makous, Walter. (2002). Spatial 
% frequency, phase, and the contrast of natural images. josaa/19/6/josaa-19-6-1096.pdf, 
% 19(6), 1096–0. doi:10.1364/JOSAA.19.001096 
% 
% colour saturation: this measure also seems to be one of the most common
% measures of low-level features according to vision research. the
% calculation of this measure was based on matlab hilfe-center and this
% publication: Wilms, Lisa; Oberfeld, Daniel . (2017). Color and emotion: 
% effects of hue, saturation, and brightness. Psychological Research, 
% (), –. doi:10.1007/s00426-017-0880-8 
% 
% if you have any questions, please contact yeo-jin yi (yyi@med.ovgu.de)
%
%% work log

%   30_01_2026 yeo-jin created the script
%              everything works fine 

%% preparation 

clear; clc; close all;

imgspath = '/Users/alex/Downloads/Images';

outputDir = fullfile(imgspath, 'lowlevel_analysis');
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

%% load imgs and sort conditions

imgFiles    = dir(fullfile(imgspath, '*.bmp'));
nImages     = length(imgFiles);

imgNames    = cell(nImages, 1);
cond        = cell(nImages, 1);

for i = 1:nImages
    imgNames{i} = imgFiles(i).name;   
    if startsWith(imgFiles(i).name, 'emo_')
        cond{i} = 'emotional';
    elseif startsWith(imgFiles(i).name, 'neu_')
        cond{i} = 'neutral';
    end
end

idxEmo      = find(strcmp(cond, 'emotional'));
idxNeu      = find(strcmp(cond, 'neutral'));

%% calc feature metrics

meanlum     = nan(nImages, 1);
RMScont     = nan(nImages, 1);
colsat      = nan(nImages, 1);

for i = 1:nImages

    img = im2double(imread(fullfile(imgspath, imgFiles(i).name)));
    [~, ~, nChannels] = size(img);
    
    % have to change the img to greyscale
    if nChannels == 3
        imggrey = rgb2gray(img);
    else
        imggrey = img;
    end
    
    % mean luminance
    meanlum(i) = mean(imggrey(:));
    
    % RMS contrast
    RMScont(i) = std(imggrey(:));
    
    % colour saturation
    if nChannels == 3
        imgHSV = rgb2hsv(img); % https://de.mathworks.com/matlabcentral/answers/498355-how-to-get-the-hue-saturation-of-a-colourful-images
        colsat(i) = mean(imgHSV(:,:,2), 'all');
    else
        colsat(i) = 0;
    end
end

fprintf('done\n');

%% stats

metricvarname   = {'meanlum', 'RMScont', 'colsat'};
metriclab       = {'Mean Luminance', 'RMS Contrast', 'Colour Saturation'};
metricdat       = {meanlum, RMScont, colsat};

nFeatures       = length(metricvarname);

stats = struct();
stats.meanEmo   = nan(nFeatures, 1);
stats.sdEmo     = nan(nFeatures, 1);
stats.meanNeu   = nan(nFeatures, 1);
stats.sdNeu     = nan(nFeatures, 1);
stats.tstat     = nan(nFeatures, 1);
stats.df        = nan(nFeatures, 1);
stats.pValue    = nan(nFeatures, 1);
stats.cohenD    = nan(nFeatures, 1);

for f = 1:nFeatures
    datEmo      = metricdat{f}(idxEmo);
    datNeu      = metricdat{f}(idxNeu);
    
    stats.meanEmo(f) = mean(datEmo);
    stats.sdEmo(f)   = std(datEmo);
    stats.meanNeu(f) = mean(datNeu);
    stats.sdNeu(f)   = std(datNeu);
    
    [~, p, ~, tstats] = ttest2(datEmo, datNeu);
    stats.tstat(f)    = tstats.tstat;
    stats.df(f)       = tstats.df;
    stats.pValue(f)   = p;
    
    pooledSD = sqrt(((length(datEmo)-1)*var(datEmo) + (length(datNeu)-1)*var(datNeu)) / ...
                    (length(datEmo) + length(datNeu) - 2));
    stats.cohenD(f) = (mean(datEmo) - mean(datNeu)) / pooledSD;
end

%% summary

T = table(metriclab', stats.meanEmo, stats.sdEmo, ...
                     stats.meanNeu, stats.sdNeu, stats.tstat, stats.df, ...
                     stats.pValue, stats.cohenD, ...
    'VariableNames', {'Feature', 'Mean_Emo', 'SD_Emo', 'Mean_Neu', 'SD_Neu', ...
                      't', 'df', 'p', 'Cohen_d'});
disp(T);
writetable(T, fullfile(outputDir, 'lowlevel_feature_comparison.csv')); % in case we want to do some more analyses

%% plot (boxplot only for now)

close all

figure('Position', [100, 100, 900, 300], 'Color', 'w');

for f = 1:nFeatures
    subplot(1, 3, f);
set(gca, 'Position', [0.08 + (f-1)*0.31, 0.18, 0.22, 0.55]);
    
    box on

    datEmo = metricdat{f}(idxEmo);
    datNeu = metricdat{f}(idxNeu);
    
    grp = [ones(size(datEmo)); 2*ones(size(datNeu))];
    data = [datEmo; datNeu];
    
    boxplot(data, grp, 'Labels', {'Emotional', 'Neutral'}, ...
            'Colors', [0.8 0.2 0.2; 0.3 0.5 0.7], 'Widths', 0.5);
    
    hold on;
    jitter = 0.15;
    scatter(ones(size(datEmo)) + jitter*(rand(size(datEmo))-0.5), datEmo, 25, ...
            [0.8 0.2 0.2], 'filled', 'MarkerFaceAlpha', 0.4);
    scatter(2*ones(size(datNeu)) + jitter*(rand(size(datNeu))-0.5), datNeu, 25, ...
            [0.3 0.5 0.7], 'filled', 'MarkerFaceAlpha', 0.4);
    hold off;
    
    % significance are marked with asterisks as usual
    if stats.pValue(f) < 0.001
        sigStr = '***';
    elseif stats.pValue(f) < 0.01
        sigStr = '**';
    elseif stats.pValue(f) < 0.05
        sigStr = '*';
    else
        sigStr = 'n.s.';
    end
    
    title(sprintf('%s\nt(%d) = %.2f, p = %.3f, d = %.2f\n%s', ...
          metriclab{f}, round(stats.df(f)), stats.tstat(f), ...
          stats.pValue(f), stats.cohenD(f), sigStr), 'FontSize', 10);
    ylabel('Value');

    set(gca, 'FontSize', 15);
end

sgtitle('Low-Level Visual Features by Condition', 'FontSize', 20, 'FontWeight', 'bold');


% save for ms
saveas(gcf, fullfile(outputDir, 'feature_comparison.png'));
saveas(gcf, fullfile(outputDir, 'feature_comparison.fig'));
