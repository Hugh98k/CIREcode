import os
import mne


def DataLoading(folder_path = 'YourFolderPath'):
    foldpraise = []
    foldirony = []
    filelist = os.listdir(folder_path)

    k = 0
    onefoldpraise = []
    onefoldirony = []
    for filename in filelist:
        if '0.set' in filename.split('_'):
            if k > 7:
                k = 0
                foldpraise.append(onefoldpraise)
                foldirony.append(onefoldirony)
                onefoldpraise = []
                onefoldirony = []

            
            filepath = os.path.join(folder_path, filename)
            epo = mne.io.read_epochs_eeglab(filepath, uint16_codec='latin1')

            num_epochs = len(epo)
            for i in range(num_epochs):
                onefoldpraise.append(epo[i]._data[:,:,:])

            name = filename.split('_')[0]
            filepath = os.path.join(folder_path, name + '_1.set')

            epo = mne.io.read_epochs_eeglab(filepath, uint16_codec='latin1')

            num_epochs = len(epo)
            for i in range(num_epochs):
                onefoldirony.append(epo[i]._data[:,:,:])

            k += 1
            
    foldpraise.append(onefoldpraise)
    foldirony.append(onefoldirony)



    return foldpraise,foldirony

  
if __name__ == '__main__':

    datalist0,datalist1 = DataLoading()




