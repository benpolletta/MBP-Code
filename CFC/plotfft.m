function [f,data_hat,bins,signals,A,P,Pmod]=plotfft(data,sampling_freq,nobands,filename)

signal_length=length(data);
nyquist=sampling_freq/2;

% if strcomp(bandwidth,'linear')==1

% band_spacing=(nyquist-1/signal_length)/nobands;
% bandwidth=2*band_spacing/5;
% band_centers=1/signal_length+bandwidth:band_spacing:nyquist+bandwidth;

% elseif strcomp(bandwidth,'log')==1

% band_spacing=(log(nyquist)-log(1/signal_length))/nobands;
% bandwidth=2*band_spacing/5;
% log_band_centers=log(1/signal_length)+band_spacing/2:band_spacing:log(nyquist)-band_spacing/2;
% band_centers=exp(log_band_centers);

% elseif strcomp(bandwidth,'sqrt')==1

band_spacing=(sqrt(nyquist)-sqrt(1/signal_length))/nobands;
bandwidth=2*band_spacing/5;
sqrt_band_centers=sqrt(1/signal_length)+band_spacing/2:band_spacing:sqrt(nyquist)-band_spacing/2;
band_centers=sqrt_band_centers.^2

data_hat=fft(data);

figure();
subplot(1,2,1)
t=1:signal_length;
t=t*sampling_freq;
plot(t,data)
title('Data')
subplot(1,2,2)
indices=1:signal_length/2;
f=sampling_freq*(indices-1)/signal_length;
plot(f,abs(data_hat(1:signal_length/2)))
title('FFT (Power)')

if nargin>3
    saveas(gcf,[filename,'fft.fig']);
end

bins=[]; signals=[]; A=[]; P=[]; Pmod=[];

figure();

for i=1:nobands
    
    flo=(sqrt_band_centers(i)-bandwidth)^2;
    fhi=(sqrt_band_centers(i)+bandwidth)^2;
    bins(i,1)=flo; bins(i,2)=fhi;
    
%     flo=exp(log_band_centers(i)-bandwidth);
%     fhi=exp(log_band_centers(i)+bandwidth);
    
%     flo=band_centers(i)-bandwidth;
%     fhi=band_centers(i)+bandwidth;

    filter=butterworth(3,signal_length,1,flo,fhi,0);
    
    filtered=data_hat.*sqrt(filter);
    signals(:,i)=real(ifft(filtered));
    
    H(:,i)=hilbert(signals(:,i));
    A(:,i)=abs(H(:,i));
    P(:,i)=phase(H(:,i));
    Pmod(:,i)=mod(P(:,i),2*pi)/pi;
    
    subplot(nobands,3,3*i-2);
    plot(signals(:,i));
    title([num2str(flo),' to ',num2str(fhi),' Frequency Band'])
    
    subplot(nobands,3,3*i-1);
    plot(A(:,i));
    title(['Amplitude of ',num2str(flo),' to ',num2str(fhi),' Frequency Band']);
    
    subplot(nobands,3,3*i);
    plot(Pmod(:,i));
    title(['Phase of ',num2str(flo),' to ',num2str(fhi),' Frequency Band']);
end

if nargin>3
    saveas(gcf,[filename,'fft_bands.fig']);
end