function fft_plotter(data,f,data_hat,sampling_freq,filename)

signal_length=length(data);

figure();

subplot(1,2,1)
t=1:signal_length;
t=t/sampling_freq;
plot(t,data)
title('Data')

subplot(1,2,2)
indices=1:signal_length/2;
f=sampling_freq*(indices'-1)/signal_length;
plot(f,abs(data_hat(1:signal_length/2)))
title('FFT (Amplitude)')

if nargin>4
    saveas(gcf,[char(filename),'.fig'])
end