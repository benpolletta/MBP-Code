%This program performs nested-frequency analysis on an input time series
%sepcified on Line 34. Filtering is performed via a 3rd-order, symmetrical 
%Butterworth filter implemented in the frequency domain. Detrending is 
%carried out by making the first and last value zero and taking out the 
%linear trend (suited for 1/f^2 type of signal, not for white noise).  
%Recommendation: Spread the windows out as the program is running, this way
%one can watch how the nested-frequency pattern changes as the filter moves
%across the frequency space. 
%Written by Biyu Jade He, Jan 2010, St. Louis. email: biyu.jade.he@gmail.com

%figure-1: filter gain response (for power);
%figure-2: raw and filtered low- and high- frequency time series;
%figure-3: lower-frequency phase;
%figure-4: higher-frequency amplitude; (note: the frequency for amplitude
%extraction could in some cases be actually lower than that for phase
%extraction, depending on the values chosen for the 2-D frequency space)
%figure-5: higher-frequency amplitude averaged at different phase of the
%lower-frequency fluctuation;
%figure-6: occurence histogram of the lower-frequency phase;
%figure-7: MI Z-score in the 2-D frequency space. 

function [Z_score] = BNestedfreq(data,Plow,Phi,Alow,Ahi)

fs = 1;  %set sampling frequency for economic data
nsample = 20000; %for economic data;

delta = 1/fs;
order = 3;      %choose butterworth filter order
ampsum = zeros(1,20);
ampoccur = zeros(1,20);

t = 0:delta:(nsample-1)*delta;

x = load('dow_jones_industrial_average_raw.dat'); %loading data
x(nsample+1:length(x)) = [];

windowt = 1000; %window length
nwindow = nsample/windowt;

%%% choose frequency ranges %%%
for M = 1:10
    for N = 1:24
        phase = 0.005*M;
        Amp = 0.02*N;
        flo(1) = phase-0.002;
        fhi(1) = phase+0.002;
        flo(2) = Amp-0.01;
        fhi(2) = Amp+0.01;
   
%%% set up butterworth filtering weights %%%
period = windowt/fs;
hzpbin = 1/period;
for j = 1:2
   for i = 1:windowt/2+1
      r_lo(j,i) = ((i-1)*hzpbin/flo(j))^(2*order);
      factor_lo(j,i) = r_lo(j,i)/(1 + r_lo(j,i));
      r_hi(j,i) = ((i-1)*hzpbin/fhi(j))^(2*order);
      factor_hi(j,i) = 1/(1 + r_hi(j,i));
   end
   for i = windowt/2+2:windowt
      factor_lo(j,i) = factor_lo(j,windowt-i+2);
      factor_hi(j,i) = factor_hi(j,windowt-i+2);
   end
end
freq = 0:hzpbin:(windowt-1)*hzpbin;
figure(1); clf;
plot(freq,factor_lo(1,:),'red')
hold on
plot(freq,factor_lo(2,:),'blue')
plot(freq,factor_hi(1,:),'red')
plot(freq,factor_hi(2,:),'blue')
title('filter gain function for power')
legend('phase extraction','amplitude extraction')
xlabel('frequency')
ylabel('Power');

figure(2);clf;
plot(t,x);
hold on

%%% window %%%
for k = 1:nwindow
   xk = x([1:windowt]+(k-1)*windowt);

%%% detrend %%%
   for i = 2:windowt-1
      xk(i) = xk(i) - xk(1) - (xk(windowt)-xk(1))*(i-1)/(windowt-1);
   end
   xk(1) = 0;
   xk(windowt) = 0;

%%% filter %%%
fftx = fft(xk);
for i = 1:windowt
   fftx_lf(i) = fftx(i) * sqrt(factor_lo(1,i) * factor_hi(1,i));
   fftx_hf(i) = fftx(i) * sqrt(factor_lo(2,i) * factor_hi(2,i));
end
lfx([1:windowt]+(k-1)*windowt) = ifft(fftx_lf);
hfx([1:windowt]+(k-1)*windowt) = ifft(fftx_hf);
end
plot(t,lfx,'r');
plot(t,hfx,'g');
title('raw and filtered data');
legend('raw','low-freq filtered','high-freq filtered');

%%% Hilbert transform %%%
hlfx = hilbert(lfx);
hhfx = hilbert(hfx);
phaself = angle(hlfx);
amphf = abs(hhfx);
figure(3);
plot(t,phaself);
title('lower-frequency phase');
figure(4);
plot(t,amphf);
title('higher-frequency amplitude');

%%% bin and average %%%
for i = 1:nsample
   for k = 1:20
      if ((k-11)*0.1*pi < phaself(i) && phaself(i) < (k-10)*0.1*pi)
         ampsum(k) = ampsum(k) + amphf(i);
         ampoccur(k) = ampoccur(k) + 1;
      end
   end
end
for k = 1:20
   ampsum(k) = ampsum(k)/ampoccur(k);
end

phase = -0.95*pi:0.1*pi:0.95*pi;
figure(5);clf;
plot(phase,ampsum);
title('amplitude bin by phase')
xlabel('lower-frequency phase');
ylabel('higher-frequency amplitude');

figure(6);clf;
plot(phase,ampoccur);
title('phase occurence histogram')
xlabel('lower-frequency phase');
ylabel('occurence');

%%% compute MI %%%
pj = ampsum / sum(ampsum);
MI = -sum(pj.*log2(pj));
MI_real = (log2(20) - MI)/log2(20);

%% *****************************************************************
%% bootstrapping
lx = windowt;
n = lx/5;
% make all possible shuffles
v = perms([1:5]);
v2 = v;
% find those for which each segment is in a different position
for k=1:5
   j = find(v(:,k)==k);
   v2(j,1) = 0;
end
j = find(v2(:,1));
v = v(j,:);
% this yields the 44 shuffles

for p=1:44
   % concatenate shuffled data
   phaselfB = [];
   for i = 1:nwindow;
   data = phaself([1:windowt]+(i-1)*windowt);
   for k=1:5 
       phaselfB = cat(2, phaselfB,data(1,[1:n]+(v(p,k)-1)*n));
   end
   end
   
   for k = 1:20
       ampsum(k) = 0;
       ampoccur(k) = 0;
   end
   
   for i = 1:nsample
      for k = 1:20
         if ((k-11)*0.1*pi < phaselfB(i) && phaselfB(i) < (k-10)*0.1*pi)
            ampsum(k) = ampsum(k) + amphf(i);
            ampoccur(k) = ampoccur(k) + 1;
         end
      end
   end
   for k = 1:20
      ampsum(k) = ampsum(k)/ampoccur(k);
   end
   pj = ampsum / sum(ampsum);
   MI = -sum(pj.*log2(pj));
   MI_boot(p) = (log2(20) - MI)/log2(20);

end
%%% make Z_score %%%
Z_score(M,N) = (MI_real - mean(MI_boot))./std(MI_boot);

    end
end
Z_score = Z_score';
figure(7)
for i = 1:24
    Zscore_inv(i,:) = Z_score(25-i,:);
end
imagesc(Zscore_inv,[4 20])
colorbar
title('MI Zscore')
set(gca,'XTickLabel',{0.01,0.02,0.03,0.04,0.05})
set(gca,'YTickLabel',{0.4 0.3 0.2 0.1})
xlabel('frequency for phase (cycle/day)');
ylabel('frequency for amplitude (cycle/day)');


