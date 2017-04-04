function MI = PAC(data, sampling_freq, low_bands, high_bands)

if isnumeric(data), data = {data, data}; end

A_high = abs(wavelet_spectrogram(data{1}, sampling_freq, high_bands));

P_low = angle(wavelet_spectrogram(data{2}, sampling_freq, low_bands));

[~, M] = amp_v_phase_Jan(18, A_high, P_low);

MI = inv_entropy_no_save(M);

end