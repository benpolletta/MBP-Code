function All_PLV_summed(channel_label1, channel_label2, freq_limits)

freqs = [1:.25:12 20:5:200];

[no_fls, fl_rows] = size(freq_limits);

if fl_rows ~= 2
    
    if no_fls == 2
        
        freq_limits = freq_limits';
        
        no_fls = size(freq_limits, 1);
        
    else
        
        display('Third argument freq_limits must be n by 2, where the first column gives initial frequency and the second column gives final frequency of a band.')
        
        return
        
    end
    
end

%% Loading Data.

name = sprintf('ALL_%s_by_%s_PLV', channel_label1, channel_label2);
PLV = load([name, '/', name, '.txt']);
PLV_zs = load([name, '/', name, '_zs.txt']);
PLV_pct = load([name, '/', name, '_pct.txt']);
PLV_thresh = load([name, '/', name, '_thresh.txt']);
PLV_thresh_pct = load([name, '/', name, '_thresh_pct.txt']);

%% Summing PLV over frequency intervals, saving.

[summed_PLV, summed_PLV_zs, summed_PLV_pct] = deal(nan(size(PLV,1), no_fls));

band_labels = cell(no_fls,1);

for fl = 1:no_fls
    
    band_labels{fl} = [num2str(freq_limits(fl,1)), 'to', num2str(freq_limits(fl,2))];
    
    freq_indices = find(freqs >= freq_limits(fl,1) & freqs <= freq_limits(fl,2));
    
    summed_PLV(:, fl) = sum(PLV(:, freq_indices), 2);
    summed_PLV_pct(:, fl) = sum(PLV_pct(:, freq_indices), 2);
    summed_PLV_zs(:, fl) = sum(PLV_zs(:, freq_indices), 2);
    summed_PLV_thresh(:, fl) = sum(PLV_thresh(:, freq_indices), 2);
    summed_PLV_thresh_pct(:, fl) = sum(PLV_thresh_pct(:, freq_indices), 2);
    
end

save([name, '/', name,'_summed.mat'], 'band_labels', 'summed_PLV', 'summed_PLV_pct', 'summed_PLV_zs', 'summed_PLV_thresh', 'summed_PLV_thresh_pct')
        