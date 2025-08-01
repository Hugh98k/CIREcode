


folder_path = 'your_folder';
set_file = 'your_data.set';

EEG = pop_loadset('filename', set_file, 'filepath', folder_path);
EEG = eeg_checkset(EEG);

fprintf('Load completed.\n');

