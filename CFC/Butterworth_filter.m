%%% Comparison of the 3rd-order Butterworth filter used in nested frequency
%%% analyses in this article (He et al., 2010) with the 3rd-order
%%% Butterworth filter implemented by the function butter in Matlab. 
%%% Written by Biyu Jade He, March 2010, St. Louis. Email: biyu.jade.he@gmail.com

clear;
nsample = 40000; 
fs = 512;
delta = 1/fs;
order = 3;      %choose butterworth filter order
data = randn(1,nsample);
freq =fs * [0:nsample/2-1]/nsample;

%************ FFT BUTTERWORTH FILTER **************%
%%% set up butterworth filtering weights %%%
period = nsample/fs;
hzpbin = 1/period;
flo = 3.6;
fhi = 4;
i = [1:nsample/2+1];
r_lo = ((i-1)*hzpbin/flo).^(2*order);
factor_lo = r_lo./(1 + r_lo);
r_hi = ((i-1)*hzpbin/fhi).^(2*order);
factor_hi = 1./(1 + r_hi);
for i = nsample/2+2:nsample
    factor_lo(i) = factor_lo(nsample-i+2);
    factor_hi(i) = factor_hi(nsample-i+2);
end

%%% plot FFT filter response in Bode plot %%%
fftfilt_bp = factor_lo(1:20000).*factor_hi(1:20000);
fftfilt_bp_DB = 10*log10(fftfilt_bp);
fftfilt_lp_DB = 10*log10(factor_hi(1:20000));
fftfilt_hp_DB = 10*log10(factor_lo(1:20000));
figure(1); clf;
plot(log10(freq),fftfilt_bp_DB,'black','LineWidth',2.0)
hold on
plot(log10(freq),fftfilt_lp_DB,'r','LineWidth',2.0)
plot(log10(freq),fftfilt_hp_DB,'g','LineWidth',2.0)
title('Figure-1 Filter response from FFT filter, Bode plot');
axis([0 2.5 -100 0]);
grid on
legend('bpss','lpss','hpss');
xlabel('Log10(frequency/Hz)');
ylabel('Power/dB');

%%% plot FFT filter response in linear plot %%%
figure(2); clf;
plot(freq,fftfilt_bp,'black','LineWidth',2.0)
hold on
plot(freq,factor_hi(1:20000),'r','LineWidth',2.0)
plot(freq,factor_lo(1:20000),'g','LineWidth',2.0)
title('Figure-2 Filter response from FFT filter, Linear plot');
axis([0 250 0 1]);
grid on
legend('bpss','lpss','hpss');
xlabel('frequency/Hz');
ylabel('Power');

%%% plot raw filtered data %%%
fftx = fft(data);
for i = 1:nsample
   fftx_filt(i) = fftx(i) * sqrt(factor_lo(1,i) * factor_hi(1,i));
end
dataA = ifft(fftx_filt);
figure(5); clf;
plot(data,'black');
hold on
plot(dataA,'r');
axis([0 200 -3 3])


%********** BUTTERWORTH FILTER as suggested by MATLAB **********%
% http://www.mathworks.com/access/helpdesk/help/toolbox/signal/butter.html
%%% set up butterworth filter %%%
[lpb,lpa] = butter(order,fhi*2./fs,'low');
[hpb,hpa] = butter(order,flo*2./fs,'high');
[bpb,bpa]=butter(order,([flo fhi]*2)./fs,'bandpass');
dataB = filtfilt(bpb,bpa,data);
figure(5)
plot(dataB,'g');
legend('raw data','filtered by FFT Butterworth','filtered by Matlab Butter');

[lph,lpw] = freqz(lpb,lpa, nsample/2);
[hph,hpw] = freqz(hpb,hpa, nsample/2);
[bph,bpw] = freqz(bpb,bpa, nsample/2);

%%% visualize filter response %%%
figure(6);clf
freqz(lpb,lpa,128,fs);
title('Matlab lpss filter response')
figure(7);clf;
freqz(hpb,hpa,128,fs);
title('Matlab hpss filter response')
figure(8);clf;
freqz(bpb,bpa,128,fs);
title('Matlab bpss filter response')

%%% plot Matlab filter response in Bode plot %%%
figure(3); clf;
plot(log10(freq),10*log10(abs(bph).^2),'black','LineWidth',2.0);
hold on
plot(log10(freq),10*log10(abs(lph).^2),'r','LineWidth',2.0);
plot(log10(freq),10*log10(abs(hph).^2),'g','LineWidth',2.0);
title('Figure-3 Filter response from Matlab filter, Bode plot');
axis([0 2.5 -100 0]);
grid on
legend('bpss','lpss','hpss');
xlabel('Log10(frequency/Hz)');
ylabel('Power/dB');

%%% plot Matlab filter response in Linear plot %%%
figure(4); clf;
plot(freq,abs(bph).^2,'black','LineWidth',2.0);
hold on
plot(freq,abs(lph).^2,'r','LineWidth',2.0);
plot(freq,abs(hph).^2,'g','LineWidth',2.0);
title('Figure-4 Filter response from Matlab filter');
axis([0 250 0 1]);
grid on
legend('bpss','lpss','hpss');
xlabel('frequency/Hz');
ylabel('Power');
return;
