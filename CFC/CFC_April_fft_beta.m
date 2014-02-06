function [bands_lo,bands_hi,MI,MI_p_vals,MI_z_scores,MI_p_thresh,MI_z_thresh]=CFC_April_fft_beta(datafile,sampling_freq,nobins,noshufs,p_threshold,z_threshold,range_lo,nobands_lo,range_hi,nobands_hi,buttorder,pct_pass,units,outfilename,dirname,opt_band_lo,opt_band_hi)

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

spacing='linear';

if ischar(datafile)
    
    data=load(datafile)';
    datafile=char(datafile);
    dataname=[datafile(1:end-4)];
    if nargin>13 && nargin<=15
        if nargin>14
            opt_band_hi=opt_band_lo;
            opt_band_lo=dirname;
        else
            opt_band_hi=[];
            opt_band_lo=[];
        end
        dirname=outfilename;
    else
        for i=1:4   
            dirname{i}=''; end
            opt_band_hi=[];
            opt_band_lo=[];
    end
    
elseif isfloat(datafile)
    
    data=datafile;
    dataname=char(outfilename);
    
    if nargin<=13
        for i=1:4   dirname{i}=''; end
        opt_band_hi=[];
        opt_band_lo=[];
    end
    
end

[rows,cols]=size(data);
if rows<cols
    data=data';
end
signal_length=length(data);

if isempty(opt_band_lo)
    [~,~,bands_lo,~,H_lo,A_lo,P_lo,F_lo,cycle_bounds_lo]=filter_fft_new(data,'fs',sampling_freq,'spacing',spacing,'filename',[dataname,'_lo'],'bandrange',range_lo,'nobands',nobands_lo,'buttorder',buttorder,'pct_pass',pct_pass,'dirname',char(dirname{1}));
else
    [~,~,bands_lo,~,H_lo,A_lo,P_lo,F_lo,cycle_bounds_lo]=filter_fft_new(data,'fs',sampling_freq,'filename',[dataname,'_lo'],'bands',opt_band_lo,'buttorder',buttorder,'dirname',char(dirname{1}));
end

if isempty(opt_band_hi)
    [f,data_hat,bands_hi,~,H_hi,A_hi,~,F_hi,cycle_bounds_hi]=filter_fft_new(data,'fs',sampling_freq,'spacing',spacing,'filename',[dataname,'_hi'],'bandrange',range_hi,'nobands',nobands_hi,'buttorder',buttorder,'pct_pass',pct_pass,'dirname',char(dirname{1}));
else
    [f,data_hat,bands_hi,~,H_hi,A_hi,~,F_hi,cycle_bounds_hi]=filter_fft_new(data,'fs',sampling_freq,'filename',[dataname,'_hi'],'bands',opt_band_hi,'buttorder',buttorder,'dirname',char(dirname{1}));
end

% Plotting signals, amplitudes, and frequencies.

cmap=jet;
whitebg(cmap(1,:))

% fft_plotter(data,f,data_hat,sampling_freq,[char(dirname{1}),'/',dataname])

% HAF_plotter(H_lo,A_lo,F_lo,bands_lo,sampling_freq,units,[dataname,'_lo_bands'],char(dirname{1}))
% HAF_plotter(H_hi,A_hi,F_hi,bands_hi,sampling_freq,units,[dataname,'_hi_bands'],char(dirname{1}))

% Computing amplitude vs. phase curves.

[bincenters,M,L]=amp_v_phase_new(nobins,A_hi,P_lo,dataname,bands_hi,bands_lo,char(dirname{2}));

for i=1:nobands_lo
   P_labels{i}=[num2str(bands_lo(i,2)),'_',char(units)];
end

for i=1:nobands_hi
   A_labels{i}=[num2str(bands_hi(i,2)),'_',char(units)];
end

% Plotting amplitude vs. phase distributions.

% if ~isempty(dirname{3})
%     cd (char(dirname{3}));
% end
% 
% avp_curve_plotter(bincenters,M,dataname,A_labels,P_labels);
% 
% if ~isempty(dirname{3})
%     cd (present_dir);
% end

% Finding inverse entropy measure for each pair of modes.

if ~isempty(char(dirname{4}))
    cd (char(dirname{4}))
end

MI=inv_entropy_save(M,dataname,bands_hi,bands_lo);

% fft_inv_entropy_plotter(MI,dataname,bands_hi,bands_lo,'Hz');

% Finding & plotting inverse entropy p-values & z-scores.

MI_p_thresh=zeros(size(MI));
MI_z_thresh=zeros(size(MI));

if noshufs>0
    [MI_p_vals,MI_z_scores]=inv_entropy_distn(noshufs,nobins,A_hi,P_lo,cycle_bounds_hi,cycle_bounds_lo,MI,dataname,bands_hi,bands_lo);

    [MI_p_thresh,MI_z_thresh]=inv_entropy_colorplot(MI,MI_p_vals,MI_z_scores,p_threshold,z_threshold,dataname,bands_hi,bands_lo,units);
end

% Plotting thresholded inverse entropy, according to cycle-by-cycle
% frequency, or original inverse entropy if no MI p-values exceed
% threshold.

% emd_inv_entropy_bMI_all(MI,F,50,'linear',units,dataname);
% emd_inv_entropy_bMI_all(MI_p_thresh,F,50,'linear',units,[dataname,'_pt']);
% emd_inv_entropy_bMI_all(MI_z_thresh,F,50,'linear',units,[dataname,'_zt']);
% Binned_MI_zt=emd_inv_entropy_plot_bMI(MI_z_thresh,F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_zt']);
% Binned_MI_pt=emd_inv_entropy_plot_bMI(MI_p_thresh,F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,[dataname,'_pt']);
% Binned_MI=emd_inv_entropy_plot_bMI(MI,F,x_lims,x_bins,y_lims,y_bins,'linear',1,units,dataname);
if ~isempty(char(dirname{4}))
    cd (present_dir)
end