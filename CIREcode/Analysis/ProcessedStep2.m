
folder_path = 'YourFolderPath';
save_data_path = 'YourFolderPath';

allItems = dir(folder_path);

subFolders = allItems([allItems.isdir] & ~ismember({allItems.name}, {'.', '..'}));

for j = 1:length(subFolders)
    
    subFolderPath = fullfile(folder_path, subFolders(j).name);
    
    set_files = dir(fullfile(subFolderPath, '*.set'));
    
    for i = 1:length(set_files)
        
        set_file = fullfile(subFolderPath, set_files(i).name);
        
        parts = strsplit(set_files(i).name, '_');
        
        if any(strcmp(parts, 'step1.set'))
            name = parts{1};
            EEG = pop_loadset('filename', set_files(i).name, 'filepath', subFolderPath);
            EEG = eeg_checkset(EEG);
            
            EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
            
            EEG = eeg_checkset(EEG);
            EEG = pop_saveset(EEG, 'filename', [name '_step2.set'], 'filepath', subFolderPath);
            
        end
    end
end



