function cohy=coherency(chan1_fft,chan2_fft)

chan1_mean_pow=nanmean(abs(chan1_fft).^2);
chan2_mean_pow=nanmean(abs(chan2_fft).^2);

cohy_num=nanmean(chan1_fft.*conj(chan2_fft));

cohy=cohy_num./sqrt(chan1_mean_pow.*chan2_mean_pow);