# MEG Sensory Stimuli Decoding with SVM
Decoding sensory stimuli applied to fingers using magnetoencephalography (MEG) data and Support Vector Machines (SVMs). 
Includes tools for processing MEG recordings, analyzing event-related responses, and classifying tactile/proprioceptive stimuli across fingers.

## svm.m
Implements sliding-window SVM classification with permutation testing. Key features:

- Trigger detection for finger-specific stimuli
- 50 ms window analysis with 10 ms steps
- 5-fold cross-validation
- Statistical significance testing via permutation
