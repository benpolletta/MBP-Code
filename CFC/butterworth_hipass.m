function [filter]=butterworth_hipass(order,signal_length,sampling_freq,fhi,plotoption)

% Produces the transfer function in the frequency domain of a band pass 
% Butterworth filter of order 'order'. The filter passes frequencies between 
% 'flo' and 'fhi', for a signal of length 'signal_length', sampled at frequency 
% 'sampling_freq'. If plotoption==1, the script plots the transfer function.

period = signal_length/sampling_freq;    %length of window
hzpbin = 1/period;      %frequency resolution

if mod(signal_length,2)==0

    i = 1:signal_length/2+1;
    i = i';
    r_hi = ((i-1)*hzpbin/fhi).^(2*order);
    factor_hi = 1./(1 + r_hi);

    factor_hi(signal_length/2+2:signal_length) = flipud(factor_hi(2:signal_length/2));

else
    
    i = 1:ceil(signal_length/2);
    i = i';
    r_hi = ((i-1)*hzpbin/fhi).^(2*order);
    factor_hi = 1./(1 + r_hi);

    factor_hi(ceil(signal_length/2)+1:signal_length) = flipud(factor_hi(2:ceil(signal_length/2)));

end

filter=sqrt(factor_hi);

if plotoption==1

freq = 0:hzpbin:(signal_length-1)*hzpbin;
figure();
plot(freq,filter,'k')
title('Filter Gain Function (Amplitude)')
xlabel('Frequency')
ylabel('Power')

end