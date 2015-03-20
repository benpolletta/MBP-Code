function spec = nan_pmtm(data, tbw)

% Takes data (whose spectrum is to be calculated) and time-bandwidth product.

length_data = length(data);

if size(data, 2) ~= 1, data = data'; end

dps_seq = dpss(length_data, tbw/2);

spec_est = nan(size(dps_seq));

for s = 1:tbw
    
    fft_est = nan_fft(data.*dps_seq(:, s));
    
    spec_est(:, s) = sqrt(fft_est .* conj(fft_est));
    
end

spec = nanmean(spec_est, 2);

end
