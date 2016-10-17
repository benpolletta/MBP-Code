function MI_BP_corr_figure(drug, subjects_flag)

figure

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

%% MI and BP correlations.

pairs = [cumsum(ones(3, 2)); nchoosek(1:3, 2); fliplr(nchoosek(1:3, 2))];

no_pairs = length(pairs);

channel_indices = [1 3];
        
if subjects_flag, subjects_label = '_by_subject'; else subjects_label = ''; end

load([drug, '_MI_BP_pct_0to4hrs_by_6min', subjects_label, '.mat'])

no_channels = 3;

for band = 1:2
    
    for ch = 1:no_channels
        
        pair_index = (pairs(:, 1) == ch) & (pairs(:, 2) == channel_indices(band));
        
        if subjects_flag
        
            pair_corrs = nanmedian(All_corrs(:, band, pair_index, 1:(end - 1)), 4);
        
        else
            
            pair_corrs = All_corrs(:, band, pair_index);
            
        end
            
        subplot(no_channels, 2, (ch - 1)*2 + band)
        
        imagesc(phase_freqs, amp_freqs, reshape(pair_corrs, no_afs, no_pfs))
        
        colorbar
        
        axis xy
        
        if band == 1
        
            ylabel(channel_names{ch}, 'FontSize', 16)
        
        end
            
        if ch == 1
            
            title({'Correlation of'; ['MI & ', channel_names{channel_indices(band)}, ' ', band_labels_long{band}]}, 'FontSize', 16)
           
        elseif ch == no_channels
            
            xlabel('Frequency (Hz)', 'FontSize', 16)
            
        end
        
    end
    
end

save_as_pdf(gcf, [drug, '_MI_BP_corr', subjects_label])

end