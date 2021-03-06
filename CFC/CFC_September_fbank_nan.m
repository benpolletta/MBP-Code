function [bands,MI,MI_p_vals,MI_z_scores,MI_lz_scores,Binned_MI_pt,Binned_MI_zt,Binned_MI_lzt,Binned_NPV,Binned_LPV]=CFC_September_fbank_beta(datafile,sampling_freq,min_cycles,nobins,noshufs,threshold,x_lims,x_bins,y_lims,y_bins,buttorder,pct_pass,spacing,units,outfilename,extradirname,opt_band)

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

present_dir=pwd;

if ischar(datafile)
    
    data=load(datafile)';
    datafile=char(datafile);
    dataname=[datafile(1:end-4)];
    if nargin>10
        dirname=outfilename;
        if nargin>11
            opt_band=extradirname;
        end
    else
        for i=1:4   dirname{i}=''; end
    end
    
elseif isfloat(datafile)
    
    data=datafile;
    dataname=char(outfilename);
    if nargin>11
        dirname=extradirname;
        if nargin>12
            opt_band=extradirname;
        end
    else
        for i=1:4   dirname{i}=''; end
    end
    
end

signal_length=length(data);

% Passing data through filter bank, calculating Hilbert transform,
% amplitudes, phases, frequencies, and cycles, and saving.

if strcmp(spacing,'custom')==1
    [f,data_hat,bands,signals,H,A,P,F,cycle_bounds]=filter_fft_bank(data,sampling_freq,min_cycles,10,[1/signal_length sampling_freq/2],spacing,buttorder,pct_pass,dataname,char(dirname{1}),opt_band);
else
    [f,data_hat,bands,signals,H,A,P,F,cycle_bounds]=filter_fft_bank(data,sampling_freq,min_cycles,10,[1/signal_length sampling_freq/2],spacing,buttorder,pct_pass,dataname,char(dirname{1}));
end
    
[nomodes,junk]=size(bands);

% Plotting signals, amplitudes, and frequencies.

cmap=gray;
whitebg('w')

HAF_plotter(H,A,F,bands,sampling_freq,units,dataname,char(dirname{1}))

% Computing amplitude vs. phase distributions.

[bincenters,M,L]=amp_v_phase_save(nobins,A,P,dataname,bands,bands,char(dirname{2}));

% Plotting amplitude vs. phase distributions.

for i=1:nomodes
   A_labels{i}=[num2str(bands(i,2)),units];
   P_labels{i}=A_labels{i};
end

if ~isempty(dirname{3})
    cd (char(dirname{3}));
end

avp_curve_plotter(bincenters,M,dataname,A_labels,P_labels)

if ~isempty(dirname{3})
    cd (present_dir);
end

% Finding inverse entropy measure for each pair of modes.

if ~isempty(dirname{4})
    present_dir=pwd;
    cd (char(dirname{4}));
end
    
MI=inv_entropy_save(M,dataname,bands,bands);

% Finding & plotting inverse entropy p-values.

threshold=1-threshold/(nchoosek(nomodes,2));

[MI_p_vals,MI_p_thresh,MI_z_scores,MI_z_pvals,MI_z_thresh,MI_lz_scores,MI_lz_pvals,MI_lz_thresh]=inv_entropy_distn_w_thresh_nan(noshufs,threshold,nobins,A,P,cycle_bounds,cycle_bounds,MI,dataname,bands,bands);

inv_entropy_colorplot_no_thresh(nantriu(MI,1),nantriu(MI_p_vals,1),nantriu(MI_p_thresh,1),nantriu(MI_z_scores,1),nantriu(MI_z_pvals,1),nantriu(MI_z_thresh,1),nantriu(MI_lz_scores,1),nantriu(MI_lz_pvals,1),nantriu(MI_lz_thresh,1),threshold,dataname,bands,bands,units);

% Plotting statistics of inverse entropy, according to cycle-by-cycle
% frequency.

emd_inv_entropy_bMI_all(nantriu(MI_z_thresh,1),F,50,'linear',units,[dataname,'_zt']);
Binned_MI_pt=emd_inv_entropy_plot_bMI_nan(nantriu(MI_p_thresh,1),F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_pt']);
Binned_MI_zt=emd_inv_entropy_plot_bMI_nan(nantriu(MI_z_thresh,1),F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_zt']);
Binned_MI_lzt=emd_inv_entropy_plot_bMI_nan(nantriu(MI_lz_thresh,1),F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_lzt']);

MI_npv = nantriu(MI_z_pvals-threshold,1);
MI_npv(MI_npv<=0) = nan;
Binned_NPV=emd_inv_entropy_plot_bMI_nan(MI_npv,F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_npv']);

MI_lpv = nantriu(MI_lz_pvals-threshold,1);
MI_lpv(MI_lpv<=0) = nan;
Binned_LPV=emd_inv_entropy_plot_bMI_nan(MI_lpv,F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_lpv']);

close('all')

if ~isempty(char(dirname{4}))
    cd (present_dir);
end
