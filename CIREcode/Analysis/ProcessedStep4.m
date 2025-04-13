
folder_path = 'YourFolderPath';
save_data_path = 'YourFolderPath';

allItems = dir(folder_path);

subFolders = allItems([allItems.isdir] & ~ismember({allItems.name}, {'.', '..'}));

event_labels_0 = {'11'};
event_labels_1 = {'21'};
%{
11,21 corresponds to the beginning and end of a positive statement;
12,22 corresponds to the beginning and end of an interrogative sentence;
14,24 corresponds to the beginning and end of a negative statement;
%}

for j = 1:length(subFolders)
    
    subFolderPath = fullfile(folder_path, subFolders(j).name);
    
    set_files = dir(fullfile(subFolderPath, '*.set'));
    
    for i = 1:length(set_files)
        
        set_file = fullfile(subFolderPath, set_files(i).name);
        
        parts = strsplit(set_files(i).name, '_');
        
        if any(strcmp(parts, 'step3.set'))
            
            name = parts{1};
            
            EEG = pop_loadset('filename', set_files(i).name, 'filepath', subFolderPath);
            EEG = eeg_checkset(EEG);
            
            
            EEG_0 = pop_epoch(EEG, event_labels_0, [-1 4]);
            EEG_1 = pop_epoch(EEG, event_labels_1, [-1 4]);
            
            
            EEG_0 = eeg_checkset(EEG_0);
            EEG_0 = pop_saveset(EEG_0, 'filename', [name '_step4_0.set'], 'filepath', subFolderPath);
            EEG_1 = eeg_checkset(EEG_1);
            EEG_1 = pop_saveset(EEG_1, 'filename', [name '_step4_1.set'], 'filepath', subFolderPath);
            
            
            
        else
            
        end
    end
end



