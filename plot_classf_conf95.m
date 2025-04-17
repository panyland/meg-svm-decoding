clc;
clear;
close all;

% Define the base directory where the subject folders are located
baseDir = pwd; % Assuming the current directory is the base directory

% Define the specific subject, condition, and finger
subject = 'KH1'; % Change this to select different subjects
finger = 'index_vs_middle'; % Change this to select different conditions
condition = 'tact'; % Change this to select different fingers

% Initialize variables to store the classification accuracy and confidence data
classfData = [];
confData = [];

% Load data for the specific subject, condition, and finger
subjectDir = fullfile(baseDir, subject); % Directory for the subject

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
% Plot classification accuracy
plot(time, classfData, '-k', 'DisplayName', 'Classification accuracy', 'LineWidth', 1.0);
% Plot confidence values
plot(time, confData, '--k', 'DisplayName', '95% confidence level', 'LineWidth', 1.0);
hold off;
set(gca, 'Color', 'w'); % Set axes background color to white
set(gca, 'XColor', 'k', 'YColor', 'k'); % Set tick colors to black
set(gca, 'TickDir', 'out'); % Ticks pointing outwards
set(gca, 'Box', 'off'); % Remove the upper and right edges
set(gca, 'FontName', 'Times New Roman'); % Set font to Times New Roman
set(gca, 'TickLength', [0.005 0.005]); % Set shorter tick lengths
title(sprintf('%s %s %s', subject, condition, finger), 'Color', 'k');
xlabel('Time (ms)', 'Color', 'k');
ylabel('(%)', 'Color', 'k');
xlim([0 500]);
ylim([20 100]); % Set y-axis to range from 0 to 80
legend('show', 'Box', 'off'); % Show legend and remove the box around it
