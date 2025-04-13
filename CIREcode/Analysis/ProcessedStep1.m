

folder_path = 'YourFolderPath';
save_data_path = 'YourFolderPath';
channel_location_folder = 'YourFolderPath';

set_files = dir(fullfile(folder_path, '*.set'));

for i = 1:length(set_files)
    
    set_file = fullfile(folder_path, set_files(i).name);
    [~, name, ~] = fileparts(set_files(i).name);
    subject_save_path = fullfile(save_data_path, name);
    if ~exist(subject_save_path, 'dir')
        mkdir(subject_save_path);
    end
    
    channel_location_file = fullfile(channel_location_folder, 'ChannelLocations.ced');
    
    EEG = pop_loadset('filename', set_files(i).name, 'filepath', folder_path);
    EEG = eeg_checkset(EEG);
    
    EEG = pop_select(EEG, 'nochannel', {'VEO', 'HEO', 'Trigger', '11', '85'});
    
    keep_triggers = {'101','102','11','12','13','14','21','22','23','24','111','112','113','114','121','122','123','124'};
    
    delete_indices = [];
    for k = 1:length(EEG.event)
        if isnumeric(EEG.event(k).type)
            event_type = num2str(EEG.event(k).type);
        else
            event_type = EEG.event(k).type;
        end
        
        if ~ismember(event_type, keep_triggers)
            delete_indices = [delete_indices, k];
        end
    end
    
    EEG.event(delete_indices) = [];
    
    
    trigger_latencies = [EEG.event.latency];
    
    if ~isempty(trigger_latencies)
        first_trigger_latency = trigger_latencies(1);
        last_trigger_latency = trigger_latencies(end);
    else
        error('No triggers found in the EEG event structure.');
    end
    
    start_time = (first_trigger_latency / EEG.srate) - 4;
    end_time = (last_trigger_latency / EEG.srate) + 4;
    
    if start_time < 0
        start_time = 0;
    end
    
    if end_time > EEG.xmax
        end_time = EEG.xmax;
    end
    
    start_point = round(start_time * EEG.srate) + 1;
    end_point = round(end_time * EEG.srate);
    
    EEG = pop_select(EEG, 'point', [start_point end_point]);
    
    EEG = pop_chanedit(EEG, 'lookup', channel_location_file);
    
    EEG = pop_eegfiltnew(EEG, 'hicutoff', 60);
    
    EEG = pop_eegfiltnew(EEG, 'locutoff', 1);
    
    EEG = pop_eegfiltnew(EEG, 'locutoff', 49, 'hicutoff', 51, 'revfilt', 1);
    
    EEG = pop_resample( EEG, 256);
    
    originalEEG = EEG;
    
    EEG = pop_clean_rawdata(EEG, 'ChannelCriterion', 0.6, 'FlatlineCriterion', 5, 'LineNoiseCriterion', 20, 'Highpass', 'off', 'BurstCriterion', 20, 'WindowCriterion', 'off', 'BurstRejection', 'off', 'Distance', 'Euclidian');
    
    EEG = pop_interp(EEG, originalEEG.chanlocs, 'spherical');
    
    EEG = pop_reref( EEG, []);
    EEG = eeg_checkset( EEG );
    
    EEG = eeg_checkset(EEG);
    EEG = pop_saveset(EEG, 'filename', [name '_step1.set'], 'filepath', subject_save_path);
    
    
    
end

fprintf('Processing completed.\n');

