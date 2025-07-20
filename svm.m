% Read files
addpath('mneM');

infile = 'S:\sport-motor_adult_meg\Adult_MEG\filtered_otp_ica\AD13\AD13_4x_mov_tact_r_otp_tsss_mc_ica.fif';
raw = fiff_setup_read_raw(infile); % Infile = fif-file

includeSTI{1} = 'STI101'; %All trigs 
includeSTI{2} = 'STI005'; %Tactile index D2
includeSTI{3} = 'STI006'; %Tactile middle D3
includeSTI{4} = 'STI007'; %Tactile ring D4
includeSTI{5} = 'STI008'; %Tactile little D5
includeSTI{6} = 'STI009'; %Actuator index D2
includeSTI{7} = 'STI010'; %Actuator middle D3
includeSTI{8} = 'STI011'; %Actuator ring D4
includeSTI{9} = 'STI012'; %Actuator little D5

% Find all channels
picksSTI_all = fiff_pick_types(raw.info,0,0,0,includeSTI);

% Choose pair to compare
picksSTI1 = picksSTI_all(6);
picksSTI2 = picksSTI_all(9);

% Read in stimulus and trigger channnels
trig1 = fiff_read_raw_segment_debug(raw,raw.first_samp,raw.last_samp,picksSTI1);
trig2 = fiff_read_raw_segment_debug(raw,raw.first_samp,raw.last_samp,picksSTI2);

% Find timings for events
ii1=find(diff(trig1)>0);
ii2=find(diff(trig2)>0);

% All gradiometers
gradm=find([raw.info.chs.coil_type]==3012);

% Choose gradiometers for analysis
specific_channels = [ ...
    7, 8, 13, 14, 16, 17, 38, 37, 40, 41, 67, 68, 112, 113, ...
    115, 116, 118, 119, 139, 140, 142, 143, 160, 161, 163, 164, ...
    22, 23, 19, 20, 46, 47, 43, 44, 73, 74, 76, 77, 124, 125, ...
    121, 122, 148, 149, 145, 146, 295, 296, 166, 167, 175, 176, ...
    178, 179, 211, 212, 202, 203, 82, 83, 79, 80, 247, 248, 250, ...
    251, 271, 272, 274, 275, 304, 305, 190, 191, 184, 185, 181, ...
    182, 208, 209, 217, 218, 280, 281, 253, 254, 256, 257, 277, ...
    278, 286, 287 ...
];
[~, idx_in_gradm] = ismember(specific_channels, gradm);
ii_meg = idx_in_gradm(idx_in_gradm > 0);

% Samplinf freq and total analyzing window size
sf = 1000;             
total_duration = 500;  

% Parameters for a sliding window
window_size = 50;  
step_size = 10;  
num_windows = floor((total_duration - window_size) / step_size) + 1;

results = zeros(num_windows, 1);
times = zeros(num_windows, 2);
conf95_val = zeros(num_windows, 1);

% Read data in windows
for w = 1:num_windows
    
    start_sample = (w - 1) * step_size + 1;
    end_sample = start_sample + window_size - 1;
    times(w, :) = [start_sample, end_sample];

    data1 = zeros(length(ii1), length(ii_meg), window_size);
    data2 = zeros(length(ii2), length(ii_meg), window_size);

    for k = 1:length(ii1)
        start_idx = raw.first_samp + ii1(k) + start_sample - 1;
        end_idx = raw.first_samp + ii1(k) + end_sample - 1;
        if start_idx >= raw.first_samp && end_idx <= raw.last_samp
            temp_data = fiff_read_raw_segment_debug(raw, start_idx, end_idx, ii_meg);
            if isequal(size(temp_data), [length(ii_meg), window_size])
                data1(k, :, :) = temp_data;
            else
                fprintf('Data size mismatch at index %d: expected [%d, %d], got [%d, %d]\n', k, length(ii_meg), window_size, size(temp_data, 1), size(temp_data, 2));
                data1(k, :, :) = NaN; % Assign NaNs or handle as appropriate
            end
        else
            fprintf('Index out of bounds for event %d: start_idx=%d, end_idx=%d, range [%d, %d]\n', k, start_idx, end_idx, raw.first_samp, raw.last_samp);
            data1(k, :, :) = NaN; % Handle out of bound indices
        end
    end

    for k = 1:length(ii2)
        start_idx = raw.first_samp + ii2(k) + start_sample - 1;
        end_idx = raw.first_samp + ii2(k) + end_sample - 1;
        if start_idx >= raw.first_samp && end_idx <= raw.last_samp
            temp_data = fiff_read_raw_segment_debug(raw, start_idx, end_idx, ii_meg);
            if isequal(size(temp_data), [length(ii_meg), window_size])
                data2(k, :, :) = temp_data;
            else
                fprintf('Data size mismatch at index %d: expected [%d, %d], got [%d, %d]\n', k, length(ii_meg), window_size, size(temp_data, 1), size(temp_data, 2));
                data2(k, :, :) = NaN; % Assign NaNs or handle as appropriate
            end
        else
            fprintf('Index out of bounds for event %d: start_idx=%d, end_idx=%d, range [%d, %d]\n', k, start_idx, end_idx, raw.first_samp, raw.last_samp);
            data2(k, :, :) = NaN; % Handle out of bound indices
        end
    end
  
    % Run classification and permutation tests
    results(w) = run_classification(data1, data2);
    conf95_val(w) = permutation_test(data1, data2);
end

% Print results
for w = 1:num_windows
    fprintf('Time window %d to %d ms: Classification accuracy = %.2f%%\n', times(w, 1), times(w, 2), results(w));
end

% Plot accuracy as a function of time
times_sec = (times - 1) / sf; 
times_midpoint = mean(times_sec, 2); 
figure; 
plot(times_midpoint, results, '-ok', 'LineWidth', 2); 
xlabel('Time (s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylabel('Classification Accuracy (%)', 'FontName', 'Times New Roman', 'FontSize', 12);

ax = gca;
grid off; 

ylim([0 max(results)*1.1]); 

ax.TickDir = 'out'; 
ax.TickLength = [0.005 0.025];
ax.Box = 'off'; 
ax.Color = 'white'; 
ax.XColor = 'k'; 
ax.YColor = 'k';  
set(ax, 'XAxisLocation', 'bottom', 'YAxisLocation', 'left');
ax.FontName = 'Times New Roman';

%% Plot average responses

time_int=[-100 500]; 
num_samples = abs(time_int(2) - time_int(1)) + 1;
data1 = zeros(length(ii1), length(ii_meg), num_samples);
data2 = zeros(length(ii2), length(ii_meg), num_samples);

for k = 1:length(ii1)
    start_idx = raw.first_samp + ii1(k) + time_int(1);
    end_idx = raw.first_samp + ii1(k) + time_int(2);
    if start_idx >= raw.first_samp && end_idx <= raw.last_samp
        temp_data = fiff_read_raw_segment_debug(raw, start_idx, end_idx, ii_meg);
        if isequal(size(temp_data), [length(ii_meg), num_samples])
            data1(k, :, :) = temp_data;
        else
            fprintf('Data size mismatch at index %d: expected [%d, %d], got [%d, %d]\n', k, length(ii_meg), num_samples, size(temp_data, 1), size(temp_data, 2));
            data1(k, :, :) = NaN; 
        end
    else
        fprintf('Index out of bounds for event %d: start_idx=%d, end_idx=%d, range [%d, %d]\n', k, start_idx, end_idx, raw.first_samp, raw.last_samp);
        data1(k, :, :) = NaN; 
    end
end

for k = 1:length(ii2)
    start_idx = raw.first_samp + ii2(k) + time_int(1);
    end_idx = raw.first_samp + ii2(k) + time_int(2);
    if start_idx >= raw.first_samp && end_idx <= raw.last_samp
        temp_data = fiff_read_raw_segment_debug(raw, start_idx, end_idx, ii_meg);
        if isequal(size(temp_data), [length(ii_meg), num_samples])
            data2(k, :, :) = temp_data;
        else
            fprintf('Data size mismatch at index %d: expected [%d, %d], got [%d, %d]\n', k, length(ii_meg), num_samples, size(temp_data, 1), size(temp_data, 2));
            data2(k, :, :) = NaN; 
        end
    else
        fprintf('Index out of bounds for event %d: start_idx=%d, end_idx=%d, range [%d, %d]\n', k, start_idx, end_idx, raw.first_samp, raw.last_samp);
        data2(k, :, :) = NaN; 
    end
end

% Averaging
avg_data1 = zeros(length(ii_meg), size(data1, 3));  
for i = 1:length(ii_meg)
    channel_data = [];
    for k = 1:length(ii1)
        channel_data = [channel_data; data1(k, i, :)];  
    end
    avg_data1(i, :) = mean(channel_data, 1); 
end

avg_data2 = zeros(length(ii_meg), size(data2, 3)); 
for i = 1:length(ii_meg)
    channel_data = [];
    for k = 1:length(ii2)
        channel_data = [channel_data; data2(k, i, :)];  
    end
    avg_data2(i, :) = mean(channel_data, 1);
end

scrollable_erps(avg_data1, specific_channels, time_int);
scrollable_erps(avg_data2, specific_channels, time_int);


%% Functions

function scrollable_erps(avg_data, gradm, time_int)
    % Scrollable window setup
    f = figure('Position', [100 100 1200 600], 'Color', 'white');
    p = uipanel('Parent', f, 'BorderType', 'none'); 
    p.Title = 'Scrollable ERPs'; 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';

    % Scrollbar configuration
    s = uicontrol('Style', 'slider',...
        'Min', 1, 'Max', length(gradm), 'Value', 1, ...
        'Position', [1150 50 20 500], ...
        'SliderStep', [1/(length(gradm)-1) 1/(length(gradm)-1)], ...
        'Callback', {@slider_callback, p, avg_data, gradm, time_int});

    % Axes setup
    ax = axes('Parent', p, 'Position', [0.05 0.1 0.9 0.85]);
    ax.Color = 'white'; 
    ax.FontSize = 12; 
    ax.FontName = 'Times New Roman'; 
    ax.TickDir = 'out'; 
    ax.TickLength = [0.005 0.025]; 
    ax.Box = 'off'; 
    ax.XColor = 'k'; 
    ax.YColor = 'k';  

    % Initial plot
    plot(ax, linspace(time_int(1), time_int(2), size(avg_data, 2)), avg_data(1, :));
    title(ax, sprintf('Channel %d', gradm(1)), 'FontName', 'Times New Roman', 'FontSize', 12);
    xlabel(ax, 'Time (ms)', 'FontName', 'Times New Roman', 'FontSize', 12);
    ylabel(ax, 'Amplitude (T)', 'FontName', 'Times New Roman', 'FontSize', 12);
    grid(ax, 'off'); 


    % Slider callback function
    function slider_callback(src, ~, p, avg_data, gradm, time_int)
        ch_idx = round(src.Value);
        plot(ax, linspace(time_int(1), time_int(2), size(avg_data, 2)), avg_data(ch_idx, :));
        title(ax, sprintf('Channel %d', gradm(ch_idx)), 'FontName', 'Times New Roman', 'FontSize', 12);
    end
end


function pred_mean = run_classification(data1, data2)
    % Take same number of trials from both conditions
    x1=min([size(data1,1) size(data2,1)]);
    data1_d=data1(1:x1,:,:);
    data2_d=data2(1:x1,:,:);
    
    % Matrices -> vectors
    data1_d=reshape(data1_d,size(data1_d,1),size(data1_d,2)*size(data1_d,3));
    data2_d=reshape(data2_d,size(data2_d,1),size(data2_d,2)*size(data2_d,3));
    
    % Permutation
    iip=randperm(x1);
    data1_d=data1_d(iip,:);
    data2_d=data2_d(iip,:);
    
    % 5-fold classification
    fold_num=5;
    fold_size=(x1-mod(x1,fold_num))/fold_num;
    fold_ind = zeros(fold_num, fold_size);
    for n=1:fold_num
       fold_ind(n,:)=((n-1)*fold_size+1:n*fold_size );
    end
    
    x1=fold_num*fold_size;
    x2=fold_size;
    
    data1_d=data1_d(1:x1,:);
    data2_d=data2_d(1:x1,:);
    
    % Classificationn - test with one fold and teach with others 
    
    for k=1:5
      train_ind = [];
      for(n=1:5);
         if(k~=n);
           train_ind=[train_ind fold_ind(n,:)];
         end;
      end;
     
      test_ind=fold_ind(k,:);
     
      data1a=data1_d(train_ind,:);
      data2a=data2_d(train_ind,:);
      data1b=data1_d(test_ind,:);
      data2b=data2_d(test_ind,:);
      
      X=[data1a;data2a];
      Y=[ones(size(data1a,1),1);2*ones(size(data2a,1),1)];
      % Support Vector Machine 
      SVMModel = fitcsvm(X,Y,'Standardize',true);
    
      newX=[data1b;data2b];
      newY=[ones(size(data1b,1),1);2*ones(size(data2b,1),1)];
      [label,score] = predict(SVMModel,newX);
      %pred = zeros(5);
      pred(k)=100*(sum(label==newY)/(2*x2));
      
    end
    % Result is the average over folds
    pred_mean=mean(pred);
end

function conf95 = permutation_test(data1, data2)
    x1=min([size(data1,1) size(data2,1)]);
    data1_d=data1(1:x1,:,:);
    data2_d=data2(1:x1,:,:);
    
    data1_d=reshape(data1_d,size(data1_d,1),size(data1_d,2)*size(data1_d,3));
    data2_d=reshape(data2_d,size(data2_d,1),size(data2_d,2)*size(data2_d,3));
    
    iip=randperm(x1);
    data1_d=data1_d(iip,:);
    data2_d=data2_d(iip,:);
    
    fold_num=5;
    fold_size=(x1-mod(x1,fold_num))/fold_num;
    fold_ind = zeros(fold_num, fold_size);
    for n=1:fold_num
       fold_ind(n,:)=((n-1)*fold_size+1:n*fold_size );
    end

    x1=fold_num*fold_size;
    x2=fold_size;
    
    data1_d=data1_d(1:x1,:);
    data2_d=data2_d(1:x1,:);
    
    data_all=[data1_d;data2_d];
    for l=1:200
        iip=randperm(x1*2);
        data1_p=data_all(iip(1:x1),:,:);
        data2_p=data_all(iip(x1+1:end),:,:);
        for k=1:5 %5-fold cross nyt
           train_ind=[];
           for n=1:5
             if(k~=n)
               train_ind=fold_ind(n,:);
             end
           end
           test_ind=fold_ind(k,:);
    
           data1a=data1_p(train_ind,:);
           data2a=data2_p(train_ind,:);
           data1b=data1_p(test_ind,:);
           data2b=data2_p(test_ind,:);
              
           X=[data1a;data2a];
           Y=[ones(size(data1a,1),1);2*ones(size(data2a,1),1)];
              
           SVMModel = fitcsvm(X,Y,'Standardize',true);
           newX=[data1b;data2b];
           newY=[ones(size(data1b,1),1);2*ones(size(data2b,1),1)];
           [label,score] = predict(SVMModel,newX);
           pred(k)=100*(sum(label==newY)/(2*x2));
        end
        predi_prctile(l)=mean(pred);
    end

    conf95=prctile(predi_prctile,95);
end
