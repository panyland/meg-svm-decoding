clc;
clear;
close all;

% Define the base directory where the subject folders are located
baseDir = pwd; 

% Define the specific subject, condition, and finger
subject = 'KH1'; 
finger = 'index_vs_middle'; 
condition = 'tact'; 

% Initialize variables to store the classification accuracy and confidence data
classfData = [];
confData = [];

% Load data for the specific subject, condition, and finger
subjectDir = fullfile(baseDir, subject); 

% Load classification accuracy data
classfFilename = fullfile(subjectDir, sprintf('%s_classf_%s_%s.mat', subject, condition, finger));
if exist(classfFilename, 'file')
    data = load(classfFilename);
    accuracy = struct2cell(data);
    classfData = accuracy{1}; % Assuming the loaded data contains only the accuracy vector
else
    error('File %s does not exist.', classfFilename);
end

% Load confidence data
confFilename = fullfile(subjectDir, sprintf('%s_conf95_%s_%s.mat', subject, condition, finger));
if exist(confFilename, 'file')
    data = load(confFilename);
    confidence = struct2cell(data);
    confData = confidence{1}; % Assuming the loaded data contains only the confidence vector
else
    error('File %s does not exist.', confFilename);
end

% Define the time vector based on the sliding window
accuracyLength = length(classfData);
time = linspace(0, 500, accuracyLength);

% Plot classification accuracy and confidence intervals
figure;
hold on;
plot(time, classfData, '-k', 'DisplayName', 'Classification accuracy', 'LineWidth', 1.0);
plot(time, confData, '--k', 'DisplayName', '95% confidence level', 'LineWidth', 1.0);
hold off;
set(gca, 'Color', 'w'); 
set(gca, 'XColor', 'k', 'YColor', 'k'); 
set(gca, 'TickDir', 'out'); 
set(gca, 'Box', 'off'); 
set(gca, 'FontName', 'Times New Roman'); 
set(gca, 'TickLength', [0.005 0.005]); 
title(sprintf('%s %s %s', subject, condition, finger), 'Color', 'k');
xlabel('Time (ms)', 'Color', 'k');
ylabel('(%)', 'Color', 'k');
xlim([0 500]);
ylim([20 100]); 
legend('show', 'Box', 'off'); 
