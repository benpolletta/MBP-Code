function batch_fft_plotter(datalist,sampling_freq)

% function [f,FFT]=batch_fft_plotter(datalist,sampling_freq)

filenames=textread(char(datalist),'%s\n');
filenum=length(filenames);

for i=1:filenum
    filename=char(filenames(i));
    data=load(filename);
    filename=filename(1:end-4);
    
    signal_length=length(data);
    highest_freq=ceil(signal_length/2);
    
    data_hat=fft(data);
%     FFT(:,i)=abs(data_hat(1:highest_freq));
    indices=1:highest_freq;
    f=sampling_freq*(indices'-1)/signal_length;

    figure();
    
    subplot(2,1,1)
    t=1:signal_length;
    t=t/sampling_freq;
    plot(t,data)
    title('Data')
    xlabel('Time')
    ylabel('Value')
    
    subplot(2,1,2)
    indices=1:signal_length/2;
    f=sampling_freq*(indices'-1)/signal_length;
    plot(f,abs(data_hat(1:signal_length/2)))
    title('FFT')
    xlabel('Frequency')
    ylabel('Amplitude')
    
    fid=fopen([filename,'_fft.txt'],'w');
    fprintf(fid,'%f\t%f\n',[f real(data_hat(1:highest_freq)) imag(data_hat(1:highest_freq))]');
    fclose(fid);
    
    saveas(gcf,[filename,'_fft.fig'])
end