# Decoding sensory stimuli applied to fingers using MEG data and SVMs. 
Includes code for analyzing fully pre-processed MEG recordings (OTP, tSSS, ICA), detecting event-related responses, classifying tactile and proprioceptive stimuli delivered across four fingers of the hand, and plotting the results.
Check the full report on my website: https://panyland.github.io/pofo-website/portfolio
 

## svm.m
Implements sliding-window SVM classification with permutation testing. Key features:

- Trigger detection for finger-specific stimuli
- 50 ms window analysis with 10 ms steps
- 5-fold cross-validation
- Statistical significance testing via permutation

## plot_erps.m / plot_classf.m / plot_classf_conf95.m
Plots for event-related responses, grand average classification accuracies over time and classification accuracies with confidence intervals from individual subjects.
