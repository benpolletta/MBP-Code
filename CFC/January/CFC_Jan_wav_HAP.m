function [bands_lo,A_lo,P_lo,bands_hi,A_hi,P_hi]=CFC_Jan_wav_HAP(datafile,sampling_freq,bands_lo,bands_hi,outfilename)

% Finds phase-amplitude modulation for rhythmic modes centered at bands_lo 
% on rhythmic modes centered at band_hi. Calculates an inverse entropy 
% measure (MI) based on the amplitude vs. phase 'histogram' for each pair 
% of phase-modulating mode and amplitude-modulated faster mode.

% 'datafile' can be either a matrix in Matlab's workspace whose
% columns are the EMD modes of a signal, or a text file containing such a
% matrix. If 'datafile' is in the workspace, the name of the data must be
% specified as the optional string 'outfilename'. 'sampling_frequency' is
% the frequency datafile is sampled at. 'nobins' is the number of bins the
% interval [-pi,pi] is divided into when calculating amp. vs. phase curves.

present_dir=pwd;

if ischar(datafile)
    data=load(char(datafile))';
    datafile=char(datafile);
    dataname=[datafile(1:end-4)];
    dirname=char(outfilename);
elseif isfloat(datafile)
    data=datafile;
    dataname=char(outfilename);
    dirname=pwd;
end

% mkdir (dataname)
% 
% cd (dataname)

[rows,cols]=size(data);
if rows<cols
    data=data';
end
[rows,cols]=size(bands_lo);
if rows<cols
    bands_lo=bands_lo';
end
[rows,cols]=size(bands_hi);
if rows<cols
    bands_hi=bands_hi';
end
clear rows cols

% Comb filtering at 60 Hz harmonics.

for f = 1:3
    
    notch_freq = 60*f;
    
    [n,Wn] = buttord(2*(notch_freq + 5*[-1 1])/sampling_freq, 2*(notch_freq + 2.5*[-1 1])/sampling_freq, 1, 20);
    
    [z, p, k] = butter(n,Wn,'stop'); [sos, g] = zp2sos(z, p, k); h = dfilt.df2sos(sos, g);
    
    data = filtfilthd(h, data, 'reflect');
    
end

% Extracting components, amplitudes, and phases.

[bands_lo,~,A_lo,P_lo] = filter_wavelet_Jan(data,'sampling_freq',sampling_freq,'bands',bands_lo);
[bands_hi,~,A_hi,P_hi] = filter_wavelet_Jan(data,'sampling_freq',sampling_freq,'bands',bands_hi);

% Saving.

% format=make_format(2*length(bands_lo),'%f');
% 
% fid=fopen([dataname,'_lo_AP.txt'],'w');
% fprintf(fid,make_format(2*length(bands_lo),'%f'),[A_lo P_lo]');
% fclose(fid);
% 
% fid=fopen();
% fprintf();
% fclose(fid);

save([dirname,'/',dataname,'_AP.mat'],'sampling_freq','bands_lo','bands_hi','A_lo','P_lo','A_hi','P_hi','-v7.3')

cd (present_dir);