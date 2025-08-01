import mne

eeglab_file = 'your_data.set'

epochs = mne.read_epochs_eeglab(eeglab_file, verbose=False)

print('Load completed.')


#optional 

epochs_event11 = epochs['11'] 

data_array = epochs_event11.get_data()

print(data_array.shape)
