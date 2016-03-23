function plot_multivar_PAC_Bernat

load('subjects.mat'), load('drugs.mat'), load('channels.mat')

load('ALL_Frontal/ALL_Frontal_A99_summed_hrMI_6min_BP_stats.mat', 'long_band_labels')

freq_labels = {{'delta', 'HFO'}, {'theta', 'HFO'}}; % {{'delta', '65', '95', 'HFO'}, {'theta', '65', '95', 'HFO'}};

no_freqs = length(freq_labels{1});

tick_labels = cell(no_freqs*no_channels, 1);

for b = 1:2
    
    for c = 1:no_channels
        
        for f = 1:no_freqs
            
            tick_labels{(c - 1)*no_freqs + f, b} =...
                [display_channel_names{c}, ', ', freq_labels{b}{f}];
            
        end
        
    end
    
end

mv_PAC_subjects = text_read('multivar_PAC_subjects.txt', '%s');
mv_PAC_drugs = text_read('multivar_PAC_drugs.txt', '%s');
mv_PAC_bands = text_read('multivar_PAC_bands.txt', '%s');

measures = {'', '_thresh'};

for m = 1:length(measures)
    
    mv_PAC = load(['multivar_PAC_PAC', measures{m}, '.txt']);
    
    if m == 1, mv_PAC = abs(mv_PAC); end
    
    median_mv_PAC = nan(no_drugs, (no_freqs*no_channels).^2, 2);
    
    for d = 1:no_drugs
        
        for b = 1:2
            
            mv_PAC_indices = strcmp(mv_PAC_drugs, drugs{d})...
                & strcmp(mv_PAC_bands, long_band_labels{b + 4});
            
            median_mv_PAC(d, :, b) = nanmedian(mv_PAC(mv_PAC_indices, :));
            
        end
        
    end
    
    median_mv_PAC = reshape(median_mv_PAC, [no_drugs, no_freqs*no_channels, no_freqs*no_channels, 2]);
    
    figure
    
    for b = 1:2
        
        upper_clim = all_dimensions(@nanmax, median_mv_PAC(:, :, :, b));
        lower_clim = all_dimensions(@nanmin, median_mv_PAC(:, :, :, b));
        
        for d = 1:no_drugs
            
            subplot(2, no_drugs, (b - 1)*no_drugs + d)
            
            mv_PAC_for_plot = reshape(median_mv_PAC(d, :, :, b), no_freqs*no_channels, no_freqs*no_channels);
            
            mv_PAC_for_plot(tril(mv_PAC_for_plot) == 0) = nan;
            
            h = imagesc(mv_PAC_for_plot);
            
            set(h, 'alphadata', ~isnan(mv_PAC_for_plot))
            
            axis xy
            
            set(gca, 'XTick', 1:(no_freqs*no_channels), 'XTickLabel', tick_labels(:, b),...
                'YTick', 1:(no_freqs*no_channels), 'YTickLabel', tick_labels(:, b))
            
            xticklabel_rotate([], 90)
            
            caxis([lower_clim upper_clim])
            
            title(drugs{d})
            
            ylabel(long_band_labels{b + 4})
            
            if d == no_drugs, colorbar, end
            
        end
        
    end
    
    save_as_pdf(gcf, ['multivar_PAC', measures{m}])
    
    figure
    
    hf_indices = [2 4 6]; % [2:4, 6:8, 10:12];
    no_hf_indices = length(hf_indices);
    lf_indices = [1 3 5]; % [1 5 9];
    no_lf_indices = length(lf_indices);
    
    for b = 1:2
        
        upper_clim = all_dimensions(@nanmax, median_mv_PAC(:, hf_indices, lf_indices, b));
        lower_clim = all_dimensions(@nanmin, median_mv_PAC(:, hf_indices, lf_indices, b));
        
        for d = 1:no_drugs
            
            subplot(2, no_drugs, (b - 1)*no_drugs + d)
            
            imagesc(reshape(median_mv_PAC(d, hf_indices, lf_indices, b), no_hf_indices, no_lf_indices))
            
            axis xy
            
            set(gca, 'XTick', 1:no_lf_indices, 'XTickLabel', tick_labels(lf_indices, b),...
                'YTick', 1:no_hf_indices, 'YTickLabel', tick_labels(hf_indices, b))
            
            xticklabel_rotate([], 90)
            
            caxis([lower_clim upper_clim])
            
            title(drugs{d})
            
            if d == 1, ylabel(long_band_labels{b + 4}), end
            
            if d == no_drugs, colorbar, end
            
        end
        
    end
    
    save_as_pdf(gcf, ['multivar_PAC', measures{m}, '_cross'])
    
    figure
    
    for b = 1:2
        
        upper_clim = all_dimensions(@nanmax, median_mv_PAC(:, lf_indices, lf_indices, b));
        lower_clim = all_dimensions(@nanmin, median_mv_PAC(:, lf_indices, lf_indices, b));
        
        for d = 1:no_drugs
            
            subplot(2, no_drugs, (b - 1)*no_drugs + d)
            
            mv_PAC_for_plot = reshape(median_mv_PAC(d, lf_indices, lf_indices, b), no_lf_indices, no_lf_indices);
            
            mv_PAC_for_plot(tril(mv_PAC_for_plot) == 0) = nan;
            
            h = imagesc(mv_PAC_for_plot);
            
            set(h, 'alphadata', ~isnan(mv_PAC_for_plot))
            
            axis xy
            
            set(gca, 'XTick', 1:no_lf_indices, 'XTickLabel', tick_labels(lf_indices, b),...
                'YTick', 1:no_lf_indices, 'YTickLabel', tick_labels(lf_indices, b))
            
            xticklabel_rotate([], 90)
            
            caxis([lower_clim upper_clim])
            
            title(drugs{d})
            
            if d == 1, ylabel(long_band_labels{b + 4}), end
            
            if d == no_drugs, colorbar, end
            
        end
        
    end
    
    save_as_pdf(gcf, ['multivar_PAC', measures{m}, '_low'])
    
    figure
    
    for b = 1:2
        
        upper_clim = all_dimensions(@nanmax, median_mv_PAC(:, hf_indices, hf_indices, b));
        lower_clim = all_dimensions(@nanmin, median_mv_PAC(:, hf_indices, hf_indices, b));
        
        for d = 1:no_drugs
            
            subplot(2, no_drugs, (b - 1)*no_drugs + d)
            
            mv_PAC_for_plot = reshape(median_mv_PAC(d, hf_indices, hf_indices, b), no_hf_indices, no_hf_indices);
            
            mv_PAC_for_plot(tril(mv_PAC_for_plot) == 0) = nan;
            
            h = imagesc(mv_PAC_for_plot);
            
            set(h, 'alphadata', ~isnan(mv_PAC_for_plot))
            
            axis xy
            
            set(gca, 'XTick', 1:no_hf_indices, 'XTickLabel', tick_labels(hf_indices, b),...
                'YTick', 1:no_hf_indices, 'YTickLabel', tick_labels(hf_indices, b))
            
            xticklabel_rotate([], 90)
            
            caxis([lower_clim upper_clim])
            
            title(drugs{d})
            
            if d == 1, ylabel(long_band_labels{b + 4}), end
            
            if d == no_drugs, colorbar, end
            
        end
        
    end
    
    save_as_pdf(gcf, ['multivar_PAC', measures{m}, '_high'])
    
end

end