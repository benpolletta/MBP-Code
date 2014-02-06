function [biggest_corr,corr_vec,lags]=lagged_corr(low,low_phase,hi_amp)

signal_length=length(low);

peaks=[find(mod(low_phase,2*pi)/pi>1.99); signal_length];
extrema=peaks(find(diff(peaks)>1));
if length(extrema)>1
    cycle_length=max(diff(extrema));
else
    cycle_length=signal_length;
end

I=1:signal_length;

lags=1:ceil(cycle_length/100):cycle_length;

corr_vec=[];

for i=1:length(lags)
    indices=mod(I+lags(i),signal_length)+1;
    corr_vec(i)=corr(low(indices),hi_amp);
end

max_corr=max(corr_vec);
min_corr=min(corr_vec);
biggest_corr=sign(max_corr-min_corr)*max(abs(max_corr),abs(min_corr));