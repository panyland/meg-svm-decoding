clc;
clear;
close all;

% Define the base directory where the subject folders are located
baseDir = pwd; % Assuming the current directory is the base directory

% Define the subjects and conditions
subjects = {'KH1', 'KH2', 'KH3', 'KH4', 'KH5', 'KH6', 'KH7', 'KH8', 'KH9', 'KH10'};
conditions = {'tact', 'prop'};
pairs = {'index_vs_middle', 'index_vs_ring', 'index_vs_pinky'};
numSubjects = length(subjects);
numConditions = length(conditions);
numPairs = length(pairs);

% Initialize cell arrays to store the classification accuracy data
classfData = cell(numConditions, numPairs);

% Loop through subjects, conditions, and finger pairs to load data
for i = 1:numSubjects
    subject = subjects{i};
    subjectDir = fullfile(baseDir, subject); % Directory for each subject
    for j = 1:numConditions
        condition = conditions{j};
        for k = 1:numPairs
            pair = pairs{k};
            filename = fullfile(subjectDir, sprintf('%s_classf_%s_%s.mat', subject, condition, pair));
            if exist(filename, 'file')
                data = load(filename);
                accuracy = struct2cell(data);
                accuracy = accuracy{1}; % Assuming the loaded data contains only the accuracy vector
                % Accumulate accuracy data
                if isempty(classfData{j, k})
                    classfData{j, k} = accuracy;
                else
                    classfData{j, k} = classfData{j, k} + accuracy;
                end
            else
                warning('File %s does not exist.', filename);
            end
        end
    end
end

% Compute the grand average by dividing by the number of subjects
for j = 1:numConditions
    for k = 1:numPairs
        classfData{j, k} = classfData{j, k} / numSubjects;
    end
end

% Define the time vector based on the sliding window
accuracyLength = length(classfData{1, 1});
time = linspace(0, 500, accuracyLength);

% Plot styles for different pairs
plotStyles = {'-ok', '-^k', '-sk'}; % Circle, triangle, square, all in black

% Plot the grand average classification accuracies separately
for j = 1:numConditions
    condition = conditions{j};
    figure;
    hold on;
    for k = 1:numPairs
        pair = pairs{k};
        plot(time, classfData{j, k}, plotStyles{k}, 'DisplayName', strrep(pair, '_', ' '), 'LineWidth', 1.0, 'MarkerIndices', 2:length(time)-1);
    end
    hold off;
    set(gca, 'Color', 'w'); % Set axes background color to white
    set(gca, 'XColor', 'k', 'YColor', 'k'); % Set tick colors to black
    set(gca, 'TickDir', 'out'); % Ticks pointing outwards
    set(gca, 'Box', 'off'); % Remove the upper and right edges
    set(gca, 'FontName', 'Times New Roman'); % Set font to Times New Roman
    set(gca, 'TickLength', [0.005 0.005]); % Set shorter tick lengths
    title(sprintf('Grand Average Classification Accuracy - %s', condition), 'Color', 'k');
    xlabel('Time (ms)', 'Color', 'k');
    ylabel('Classification accuracy (%)', 'Color', 'k');
    xlim([0 500]);
    ylim([20 80]); % Set y-axis to range from 0 to 80
    legend('show', 'Box', 'off'); % Show legend and remove the box around it
end

%%

clc;
clear;
close all;

% Define the base directory where the subject folders are located
baseDir = pwd; % Assuming the current directory is the base directory

% Define the subjects and fingers
subjects = {'KH1', 'KH2', 'KH3', 'KH4', 'KH5', 'KH6', 'KH7', 'KH8', 'KH9', 'KH10'};
fingers = {'index', 'middle', 'ring', 'pinky'};
numSubjects = length(subjects);
numFingers = length(fingers);

% Initialize cell arrays to store the classification accuracy data
classfData = cell(1, numFingers);

% Loop through subjects and fingers to load data
for i = 1:numSubjects
    subject = subjects{i};
    subjectDir = fullfile(baseDir, subject); % Directory for each subject
    for j = 1:numFingers
        finger = fingers{j};
        filename = fullfile(subjectDir, sprintf('%s_classf_tact_vs_prop_%s.mat', subject, finger));
        if exist(filename, 'file')
            data = load(filename);
            accuracy = struct2cell(data);
            accuracy = accuracy{1}; % Assuming the loaded data contains only the accuracy vector
            % Accumulate accuracy data
            if isempty(classfData{j})
                classfData{j} = accuracy;
            else
                classfData{j} = classfData{j} + accuracy;
            end
        else
            warning('File %s does not exist.', filename);
        end
    end
end

% Compute the grand average by dividing by the number of subjects
for j = 1:numFingers
    classfData{j} = classfData{j} / numSubjects;
end

% Define the time vector based on the sliding window
accuracyLength = length(classfData{1});
time = linspace(0, 500, accuracyLength);

% Plot styles for different fingers
plotStyles = {'-ok', '-^k', '-sk', '-dk'}; % Circle, triangle, square, diamond, all in black

% Plot the grand average classification accuracies
figure;
hold on;
for j = 1:numFingers
    finger = fingers{j};
    plot(time, classfData{j}, plotStyles{j}, 'DisplayName', sprintf('%s', finger), 'LineWidth', 1.0, 'MarkerIndices', 2:length(time));
end
hold off;
set(gca, 'Color', 'w'); % Set axes background color to white
set(gca, 'XColor', 'k', 'YColor', 'k'); % Set tick colors to black
set(gca, 'TickDir', 'out'); % Ticks pointing outwards
set(gca, 'Box', 'off'); % Remove the upper and right edges
set(gca, 'FontName', 'Times New Roman'); % Set font to Times New Roman
set(gca, 'TickLength', [0.005 0.005]); % Set shorter tick lengths
title('Proprioceptive vs. Tactile', 'Color', 'k');
xlabel('Time (ms)', 'Color', 'k');
ylabel('Accuracy (%)', 'Color', 'k');
xlim([0 500]);
ylim([20 100]); % Set y-axis to range from 0 to 80
legend('show', 'Box', 'off'); % Show legend and remove the box around it
