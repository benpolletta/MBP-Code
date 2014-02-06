function Sixty_Hz_comb_batch(sampling_freq,signal_length)

[listname,listpath]=uigetfile('*list','Choose a list of files to notch filter.')

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

data_hat=zeros(filenum,signal_length);

nyquist_index=ceil(signal_length/2);

f=sampling_freq*[1:signal_length/2]/(signal_length);

[n,Wn]=buttord(2*[55 65]/sampling_freq,2*[57.5 62.5]/sampling_freq,1,20);

[z,p,k]=butter(n,Wn,'stop'); [sos,g]=zp2sos(z,p,k); h=dfilt.df2sos(sos,g);

[H,W]=freqz(h,nyquist_index);
plot(f,abs(H))
saveas(gcf,[listname(1:end-5),'_notch_filter.fig'])

for i=1:filenum
    
    filename=char(filenames(i));
    data=load(filename)';
        
    filtered=filtfilthd(h,data,'reflect');
    data_hat(i,:)=fft(filtered)';
    
    filename=filename(1:end-4);
    fid=fopen([filename,'_notched.txt'],'w');
    fprintf(fid,'%f\n',filtered);
    fclose(fid);
    
end

avg_fft=mean(abs(data_hat).^2);
avg_fft=avg_fft(1:signal_length/2);
std_fft=std(abs(data_hat).^2);
std_fft=std_fft(1:signal_length/2);

figure()
loglog(f,avg_fft,'k',f,avg_fft+std_fft,'--k')
title(['Avg. FFT for ',listname,', Post 60 Hz Notch Filtering'])
xlabel('Frequency (Hz)')
ylabel('Power')
legend('Mean','SD')

saveas(gcf,[listname(1:end-5),'_notched_avg_fft.fig'])
