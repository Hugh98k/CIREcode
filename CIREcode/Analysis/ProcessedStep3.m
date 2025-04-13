
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
        
        if any(strcmp(parts, 'step2.set'))
            name = parts{1};
            
            EEG = pop_loadset('filename', set_files(i).name, 'filepath', subFolderPath);
            EEG = eeg_checkset(EEG);
            
            EEG = pop_iclabel(EEG, 'default');
            
            brain_threshold = 0.8;
            brain_components = find(EEG.etc.ic_classification.ICLabel.classifications(:, 1) >= brain_threshold);
            reject_components = setdiff(1:size(EEG.icaweights, 1), brain_components);
            EEG = pop_subcomp(EEG, reject_components, 0);
            
            nDIP = size(EEG.icaweights, 1);
            
            EEG = pop_dipfit_settings(EEG, ...
                'hdmfile', 'E:\\eeglab2024.2\\plugins\\dipfit\\standard_BEM\\standard_vol.mat', ...
                'coordformat', 'MNI', ...
                'mrifile', 'E:\\eeglab2024.2\\plugins\\dipfit\\standard_BEM\\standard_mri.mat', ...
                'chanfile', 'E:\\eeglab2024.2\\plugins\\dipfit\\standard_BEM\\elec\\standard_1005.elc', ...
                'coord_transform', [0.58978 -17.2151 1.5971 -0.11831 0.00061987 -1.5698 0.9943 0.99659 1.0142], ...
                'chansel', [1:122]);
            
            EEG = pop_dipfit_gridsearch(EEG, [1:nDIP], ...
                [-85 -77.6087 -70.2174 -62.8261 -55.4348 -48.0435 -40.6522 -33.2609 -25.8696 -18.4783 -11.087 -3.69565 3.69565 11.087 18.4783 25.8696 33.2609 40.6522 48.0435 55.4348 62.8261 70.2174 77.6087 85], ...
                [-85 -77.6087 -70.2174 -62.8261 -55.4348 -48.0435 -40.6522 -33.2609 -25.8696 -18.4783 -11.087 -3.69565 3.69565 11.087 18.4783 25.8696 33.2609 40.6522 48.0435 55.4348 62.8261 70.2174 77.6087 85], ...
                [0 7.72727 15.4545 23.1818 30.9091 38.6364 46.3636 54.0909 61.8182 69.5455 77.2727 85], 0.4);
            
            EEG = pop_multifit(EEG, [1:nDIP], 'threshold', 15, 'rmout', 'on', 'dipoles', 1, 'dipplot', 'off');
            
            rv_values = [EEG.dipfit.model.rv];
            
            ic_to_remove = find(rv_values > 0.15);
            
            if ~isempty(ic_to_remove)
                EEG = pop_subcomp(EEG, ic_to_remove, 0);
            end
            
            nDIP = size(EEG.icaweights, 1);
            row_idx = find(strcmp(num_pca_table.Subject, name));
            if ~isempty(row_idx)
                num_pca_table.nDIP(row_idx) = nDIP;
            end
            
            EEG = eeg_checkset(EEG);
            EEG = pop_saveset(EEG, 'filename', [name '_step3.set'], 'filepath', subFolderPath);
            
        end
    end
end



