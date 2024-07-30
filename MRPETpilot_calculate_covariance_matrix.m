%% calculate the covariance matrix

clear;clc

% paths
paths = [];
paths.first     = '/Users/alex/Documents/model_all/1stlvl_CompCor/';
paths.behav     = '/Users/alex/Dropbox/paperwriting/3tpilot/data/';

% subjects
IDs  = [2202 2203 2204 2205 2206 2207 2208 2109 2110 2112 2113 2114 2115 2116 2217 2218 2219 2220 ...
    2221 2222 2223 2224 2125 2126 2127 2128 2129 2130 2131 2132 2233 2234 2235 2236 2237 2238 2239 ...
    2240 2142 2143 2144 2145 2146 2147 2148 2249 2250];

%% averaged covariance matrix

close all;

scene_columns = 1:4;
feedback_columns = 5:8;
num_subjects = length(IDs);

% preassign the mat
sum_cov_matrix = zeros(length(scene_columns), length(feedback_columns));


for id = 1:num_subjects
    
    clear SPM cov_matrix scene_feedback_cov
    
    load([paths.first num2str(IDs(id)) '/SPM.mat']);    
    design_matrix = SPM.xX.X;
    
    scene_regressors = design_matrix(:, scene_columns);
    feedback_regressors = design_matrix(:, feedback_columns);
    all_regressors = [scene_regressors, feedback_regressors];
    
    cov_matrix = cov(all_regressors);
    
    scene_feedback_cov = cov_matrix(1:length(scene_columns), length(scene_columns)+1:end);
    
    sum_cov_matrix = sum_cov_matrix + scene_feedback_cov;
    
end

% calc the average covariance matrix
avg_cov_matrix = sum_cov_matrix / num_subjects;

% labels for heatmap
scene_labels = SPM.xX.name(scene_columns);
feedback_labels = SPM.xX.name(feedback_columns);

% draw the heatmap
figure;
h = heatmap(feedback_labels, scene_labels, avg_cov_matrix, 'ColorbarVisible', 'on','ColorLimits',[-0.005 0.005]);
h.CellLabelFormat = '%.5f';
title({'Covariance Matrix of Scene and Feedback Regressors','Averaged Across All Subjects'});
xlabel('Feedback Predictors');
ylabel('Scene Predictors');
colormap(turbo);
colorbar;
axs = struct(gca); % ignore warning that this should be avoided
cb = axs.Colorbar;
cb.Ruler.Exponent = 0;
% cb.Ruler.TickLabelFormat = '%.5f';
