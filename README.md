# Decoding sensory stimuli applied to fingers using MEG data and SVMs. 
Includes code for processing MEG recordings, analyzing event-related responses, and classifying tactile/proprioceptive stimuli across fingers as well as plotting results.

## svm.m
Implements sliding-window SVM classification with permutation testing. Key features:

- Trigger detection for finger-specific stimuli
- 50 ms window analysis with 10 ms steps
- 5-fold cross-validation
- Statistical significance testing via permutation
