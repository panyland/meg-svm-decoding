# Decoding sensory stimuli applied to fingers using MEG data and SVMs. 
Includes code for processing MEG recordings (fully pre-processed), analyzing event-related responses, and classifying tactile/proprioceptive stimuli given across fingers as well as plotting results. 
Check the full report from my website https://panyland.github.io/pofo-website/  
 

## svm.m
Implements sliding-window SVM classification with permutation testing. Key features:

- Trigger detection for finger-specific stimuli
- 50 ms window analysis with 10 ms steps
- 5-fold cross-validation
- Statistical significance testing via permutation

## plot_erps.m / plot_classf.m / plot_classf_conf95.m
Plots for event-related responses, grand average classification accuracies over time and classification accuracies with confidence intervals from individual subjects.
