function [bands_lo,bands_hi,MI]=CFC_Jan_wav(datafile,sampling_freq,nobins,bands_lo,bands_hi,units,outfilename,dirname)

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
    data=load(char(datafile))';
    datafile=char(datafile);
    dataname=[datafile(1:end-4)];
    if nargin>8
        dirname=outfilename;
    else
        for i=1:4   dirname{i}=''; end
    end
elseif isfloat(datafile)
    data=datafile;
    dataname=char(outfilename);
    if nargin>9
        dirname=char(dirname);
    else
        for i=1:4   dirname{i}=''; end
    end
end

[rows,cols]=size(data);
if rows<cols
    data=data';
end
signal_length=length(data);

[f,data_hat,bands_lo,H_lo,A_lo,P_lo,F_lo,cycle_bounds_lo]=filter_wavelet(data,'fs',sampling_freq,'filename',[dataname,'_lo'],'bands',bands_lo,'dirname',char(dirname{1}));
[f,data_hat,bands_hi,H_hi,A_hi,P_hi,F_hi,cycle_bounds_hi]=filter_wavelet(data,'fs',sampling_freq,'filename',[dataname,'_hi'],'bands',bands_hi,'dirname',char(dirname{1}));

% Plotting signals, amplitudes, and frequencies.

cmap=jet;
whitebg(cmap(1,:))

fft_plotter(data,f,data_hat,sampling_freq,[char(dirname{1}),'/',dataname])

HAF_plotter(H_lo,A_lo,F_lo,bands_lo,sampling_freq,units,[dataname,'_lo_bands'],char(dirname{1}))
HAF_plotter(H_hi,A_hi,F_hi,bands_hi,sampling_freq,units,[dataname,'_hi_bands'],char(dirname{1}))

% Computing amplitude vs. phase curves.

[bincenters,M,L]=amp_v_phase_new(nobins,A_hi,P_lo,dataname,bands_hi,bands_lo,char(dirname{2}));

nobands_lo=size(bands_lo,1);
nobands_hi=size(bands_hi,1);

for i=1:nobands_lo
   P_labels{i}=[num2str(bands_lo(i,3)),'_',char(units)];
end

for i=1:nobands_hi
   A_labels{i}=[num2str(bands_hi(i,3)),'_',char(units)];
end

% Plotting amplitude vs. phase distributions.

if ~isempty(dirname{3})
    cd (char(dirname{3}));
end

avp_curve_plotter(bincenters,M,dataname,A_labels,P_labels);

if ~isempty(dirname{3})
    cd (present_dir);
end

% Finding inverse entropy measure for each pair of modes.

if ~isempty(char(dirname{4}))
    cd (char(dirname{4}))
end

MI=inv_entropy_save(M,dataname,bands_hi,bands_lo);

fft_inv_entropy_plotter(MI,dataname,bands_hi,bands_lo,'Hz');

close('all')

if ~isempty(char(dirname{4}))
    cd (present_dir);
end