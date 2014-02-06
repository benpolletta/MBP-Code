[max_corr,corr_vec]=lagged_corr(low,low_phase,hi_amp)

peaks=find(mod(low_phase,2*pi)/pi>1.99);
extrema=peaks(find(diff(peaks)>1));
cycle_length=mean(diff(extrema));

I=1:signal_length;

lags=1:ceil(cycle_length/100):cycle_length;

for i=1:length(lags)
    indices=mod(I+lags(i),signal_length)+1;
    corr_vec(i)=corr(low_new(indices),hi_amp);
end

max_corr=max(corr_vec);

figure();
plot(lags,corr_vec)
