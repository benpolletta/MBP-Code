function [avg_fft]=avg_amp_fft(peak_freq,sampling_freq,signal_length)
 
peak_freq_wavelet=dftfilt3(peak_freq, 8, sampling_freq, 'winsize', sampling_freq);

[listname,listpath]=uigetfile('*list','Choose a list of files to calculate peak-averaged signal.')

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

amp_fft=nan(filenum,signal_length);

fid=fopen([listname(1:end-5),'_',num2str(peak_freq),'_amp_avg_fft.txt'],'w');

format=make_format(signal_length,'f');

for i=1:filenum
    
    filename=char(filenames(i));
    data=load(filename);
%     signal_length=length(data);

    peak_freq_filtered=conv(data,peak_freq_wavelet);
    peak_freq_filtered=peak_freq_filtered(floor(sampling_freq/2)+1:end-floor(sampling_freq/2));
    peak_freq_mag=abs(peak_freq_filtered);
    
    amp_fft(i,:)=abs(fft(peak_freq_mag)).^2;
    
    fprintf(fid,format,amp_fft(i,:));
    
end

avg_fft=mean(amp_fft);
fprintf(fid,format,avg_fft);
fclose(fid);

f=sampling_freq*[1:signal_length]/signal_length;

figure()
plot(f,avg_fft)
title(['Average ',num2str(peak_freq),' Hz Amplitude Power for ',listname])
xlabel('Frequency (Hz)')
saveas(gcf,[listname(1:end-5),'_',num2str(peak_freq),'_amp_avg_fft.fig'])

figure()
colorplot(log(amp_fft))
title([num2str(peak_freq),' Hz Amplitude Power for ',listname])
set(gca,'YTick',[],'XTickLabel',f)
xlabel('Frequency (Hz)')
saveas(gcf,[listname(1:end-5),'_',num2str(peak_freq),'_amp_fft_colorplot.fig'])