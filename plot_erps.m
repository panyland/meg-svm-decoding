clc;
clear;
close all;

% Define the base directory where the subject folders are located
baseDir = pwd; 

% Define the subjects and conditions
subjects = {'KH1', 'KH2', 'KH3', 'KH4', 'KH5', 'KH6', 'KH7', 'KH8', 'KH9', 'KH10'};
conditions = {'tact', 'prop'};
fingers = {'index', 'middle', 'ring', 'pinky'};
numSubjects = length(subjects);
numConditions = length(conditions);
numFingers = length(fingers);
selectedChannel = 20; 

% Initialize cell arrays to store the data
erpData = cell(numConditions, numFingers);
samplingRate = 1000; 
startTime = -100; 
endTime = 500; 
time = linspace(startTime, endTime, 601); 

% Loop through subjects, conditions, and fingers to load data
for i = 1:numSubjects
    subject = subjects{i};
    subjectDir = fullfile(baseDir, subject); 
    for j = 1:numConditions
        condition = conditions{j};
        for k = 1:numFingers
            finger = fingers{k};
            filename = fullfile(subjectDir, sprintf('%s_avg_erps_%s_%s.mat', subject, condition, finger));
            if exist(filename, 'file')
                data = load(filename);
                erp = struct2cell(data);
                erp = erp{1}; % Assuming the loaded data contains only the ERP matrix
                % Select the desired channel
                selectedErp = erp(selectedChannel, :);
                % Accumulate ERP data
                if isempty(erpData{j, k})
                    erpData{j, k} = selectedErp;
                else
                    erpData{j, k} = erpData{j, k} + selectedErp;
                end
            else
                warning('File %s does not exist.', filename);
            end
        end
    end
end

% Compute the grand average by dividing by the number of subjects
for j = 1:numConditions
    for k = 1:numFingers
        erpData{j, k} = erpData{j, k} / numSubjects;
    end
end

% Plot the grand average ERP responses separately
for j = 1:numConditions
    condition = conditions{j};
    for k = 1:numFingers
        finger = fingers{k};
        figure;
        plot(time, erpData{j, k}, 'Color', 'k'); 
        set(gca, 'Color', 'w');
        set(gca, 'XColor', 'k', 'YColor', 'k'); 
        set(gca, 'TickDir', 'out'); 
        set(gca, 'Box', 'off'); 
        set(gca, 'FontName', 'Times New Roman'); 
        title(sprintf('Grand Average ERP - %s %s', condition, finger), 'Color', 'k');
        xlabel('Time (ms)', 'Color', 'k');
        ylabel('Amplitude (T)', 'Color', 'k');
        xlim([startTime endTime]);
    end
end

