function fft_plotter_Jan(data,sampling_freq,filename)

signal_length=length(data);
nyquist_index=ceil(signal_length/2);

data_hat=fft(data);
[r,c]=size(data_hat);
if r<c
    data_hat=data_hat';
end

figure();

subplot(1,2,1)
t=1:signal_length;
t=t/sampling_freq;
plot(t,data)
title('Data')

subplot(1,2,2)
indices=1:nyquist_index;
f=sampling_freq*(indices'-1)/signal_length;
plot(f,abs(data_hat(1:signal_length/2)))
title('FFT (Amplitude)')

if nargin>4
    saveas(gcf,[char(filename),'.fig'])
end