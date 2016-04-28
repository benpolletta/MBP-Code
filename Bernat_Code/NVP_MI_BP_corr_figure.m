function NVP_MI_BP_corr_figure

close('all')

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

%% MI and BP correlations.

pairs = [cumsum(ones(3, 2)); nchoosek(1:3, 2); fliplr(nchoosek(1:3, 2))];

no_pairs = length(pairs);

channel_indices = [1 3];
        
load('NVP_MI_BP_pct_0to4hrs_by_6min.mat')

no_channels = 3;

for band = 1:2
    
    for ch = 1:no_channels
        
        pair_index = (pairs(:, 1) == ch) & (pairs(:, 2) == channel_indices(band));
        
        pair_corrs = All_corrs(:, band, pair_index);
        
        subplot(no_channels, 2, (ch - 1)*2 + band)
        
        imagesc(reshape(pair_corrs, no_afs, no_pfs))
        
        colorbar
        
        axis xy
        
        ylabel(channel_names{ch}, 'FontSize', 16)
        
        if ch == 1
            
            title({'Correlation of'; ['MI & ', channel_names{channel_indices(band)}, ' ', band_labels_long{band}]}, 'FontSize', 16)
            
        end
        
    end
    
end

save_as_pdf(gcf, 'NVP_MI_BP_corr')

end