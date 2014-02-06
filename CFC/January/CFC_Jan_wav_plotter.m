function CFC_Jan_wav_plotter(units)

[dataname,datapath]=uigetfile('*mat','Choose file for plotting.');

present_dir=pwd;

cd (datapath)

load(dataname)

dataname=dataname(1:end-4);

% Plotting signals, amplitudes, and frequencies.

if exist(data,'var')==1 && exist(sampling_freq,'var')==1

    fft_plotter(data,sampling_freq,dataname)
    
end

if exist(H_lo,'var')==1 && exist(H_hi,'var')==1 && exist(sampling_freq,'var')==1

    A_lo=abs(H_lo); A_hi=abs(H_hi);
    P_lo=angle(H_lo); P_hi=angle(H_hi);
    
    plotHAP_Jan(H_lo,A_lo,P_lo,bands_lo,sampling_freq,char(units),[dataname,'_lo'])
    plotHAP_Jan(H_hi,A_hi,P_hi,bands_hi,sampling_freq,char(units),[dataname,'_hi'])

end

% Making labels.

[nobands_lo,~]=size(bands_lo,1);
[nobands_hi,~]=size(bands_hi,1);

for i=1:nobands_lo
   P_labels{i}=[num2str(bands_lo(i,2),3),'_',char(units)];
end

for i=1:nobands_hi
   A_labels{i}=[num2str(bands_hi(i,2),3),'_',char(units)];
end

% Plotting amplitude vs. phase distributions.

avp_curve_plotter_Jan(bincenters,M,dataname,A_labels,P_labels);

% Plotting MI.

fft_inv_entropy_plotter_Jan(MI,dataname,bands_hi,bands_lo,char(units));

close('all')

cd (present_dir)