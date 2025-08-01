# Abstract
Neural decoding of speech intention could advance the development and application of brain-computer interface (BCI) technology. Currently, lack of dataset limited the research on decoding the true speech intention, especially the diverse intentions expressed by the same text when no context is given. This study provides an EEG dataset, CIRE, on spoken language interaction intention featuring aligned textual expressions with divergent intentional meanings due to the differences in prosodic emotion. The dataset comprises preprocessed high-density (128-channel) EEG recordings from 38 participants engaged in comprehension of attitude-conveying speech stimuli, accompanied by Wav2vec2-derived acoustic embeddings of the listening materials. To validate our dataset through cognitive neuroscience studies and binary intent classification, we applied signal processing pipelines, cognitive analysis frameworks, and machine learning approaches. Our baseline model achieved a cross-subject classification accuracy of 68.2$\%$, with differences exhibiting interpretable neurophysiological correlates. The high-density and high temporal resolution EEG data offer broader application areas, both in cognitive neuroscience and speech BCI, and can also contribute to the brain-inspired algorithms.

# Analysis
The preprocessing scripts based on the MATLAB toolbox EEGLAB include one EEG electrode location file (.ced) and four processing scripts corresponding to four sequential steps. For detailed descriptions of the specific preprocessing procedures, please refer to the associated publication.

# Model
The code for the deep learning model is provided, while the specific model architecture can be found in the associated publication.

# LoadData
The EEG data loading scripts are provided, including both MATLAB and Python versions for reading data in the .set format.
