function [F,cycle_bounds,bands,MI_good,MI_p_vals,Percent_MI]=FFT_backend(MI,H,sampling_freq,nobins,noshufs,p_threshold,z_threshold,x_lims,x_bins,y_lims,y_bins,units,outfilename,dirname)

% Finds and displays phase-amplitude modulation for each rhythmic mode (having 
% more than 3 cycles) on its higher-frequency modes in the EMD of a
% signal. Calculates an inverse entropy measure (MI) based on the amplitude
% vs. phase 'histogram' for each pair of phase-modulating mode and
% amplitude-modulated faster mode. Uses a bootstrap to calculate a
% significance value for each pair of modes.

% 'datafile' can be either a matrix in Matlab's workspace whose
% columns are the EMD modes of a signal, or a text file containing such a
% matrix. If 'datafile' is in the workspace, the name of the data must be
% specified as the optional string 'outfilename'. 'sampling_frequency' is
% the frequency datafile is sampled at. 'nobins' is the number of bins the
% interval [-pi,pi] is divided into when calculating amp. vs. phase curves.
% 'noshufs' is the number of times the cycles in each mode will be shuffled
% to obtain bootstrap p-values for MI; if it is zero, bootstrapping will be
% skipped. 'threshold' is a lower threshold for MI p-values; if it is zero,
% thresholding will be skipped. 'units' is the units in which frequency
% will be displayed.

% Separate directories in which to save (1) the amplitude, phase, and
% frequency measures of the modes, (2) the amp. vs. phase curve data, (3)
% the amp. vs. phase curve plots, and (4) the MI data and plots, can be
% specified as an optional final string array, in place of either
% 'outfilename' or 'extradirname'.

P=inc_phase(hilbert(H));

[F,cycle_bounds,bands,cycle_frequencies]=emd_cycle_by_cycle_freqs(P,sampling_freq);

[signal_length,nomodes]=size(P);

% Plotting signals, amplitudes, and frequencies.

cmap=jet;
whitebg(cmap(1,:))

HAF_plotter(H,A,F,bands,sampling_freq,units,dataname,char(dirname{1}))

% Finding & plotting inverse entropy p-values.

MI_good=zeros(size(MI));

if noshufs>0
    [MI_p_vals,MI_z_scores]=inv_entropy_distn(noshufs,nobins,A,P,cycle_bounds,MI,MIname,bands,bands);

    [MI_p_thresh,MI_z_thresh]=emd_inv_entropy_colorplot(MI,MI_p_vals,MI_z_scores,p_threshold,z_threshold,MIname,bands,units);
end

% Plotting thresholded inverse entropy, according to cycle-by-cycle
% frequency, or original inverse entropy if no MI p-values exceed
% threshold.

if max(max(MI_p_thresh))>0
    emd_inv_entropy_plot_scatter(MI_p_thresh,F,units,MIname)
    Percent_MI=emd_inv_entropy_plot_pMI(MI_p_thresh,F,bands,x_lims,x_bins,y_lims,y_bins,units,MIname);
else
    emd_inv_entropy_plot_scatter(MI,F,units,MIname)
    Percent_MI=emd_inv_entropy_plot_pMI(MI,F,bands,x_lims,x_bins,y_lims,y_bins,units,MIname);
end
