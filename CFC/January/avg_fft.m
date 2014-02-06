function [avg_fft,se_fft]=avg_fft(sampling_freq,signal_length)

[listname,listpath]=uigetfile('*list','Choose a list of files to fft.')

fftname=[listname(1:end-5),'_avg_fft'];
fid=fopen([fftname,'.txt'],'w');

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

data_hat=zeros(filenum,signal_length);

for i=1:filenum
    
    filename=char(filenames(i));
    data=load(filename);
    data=data';
    
%     data_hat(i,:)=fft(data(:,3));
    data_hat(i,:)=fft(data);
    
end

f=sampling_freq*[1:signal_length/2]/(signal_length);

avg_fft=mean(abs(data_hat).^2);
avg_fft=avg_fft(1:signal_length/2);
se_fft=std(abs(data_hat).^2)/sqrt(filenum);
se_fft=se_fft(1:signal_length/2)/sqrt(filenum);

fprintf(fid,'%f\t%f\n',[avg_fft;se_fft]);
fclose(fid);

figure()
loglog(f,avg_fft,'k',f,avg_fft+se_fft,'--k',f,avg_fft-se_fft,'--k')
title(['Avg. FFT for ',listname])
xlabel('Frequency (Hz)')
ylabel('Power')
legend('Mean','SD')
saveas(gcf,fftname,'fig')