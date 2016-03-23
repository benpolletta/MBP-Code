function stats_multivar_PAC_Bernat

load('subjects.mat'), load('drugs.mat'), load('channels.mat')

load('ALL_Frontal/ALL_Frontal_A99_summed_hrMI_6min_BP_stats.mat', 'long_band_labels')

freq_labels = {{'delta', 'HFO'}, {'theta', 'HFO'}}; %{{'delta', '65', '95', 'HFO'}, {'theta', '65', '95', 'HFO'}};

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

mv_PAC = load('multivar_PAC_PAC.txt');
% mv_PAC_subjects = text_read('multivar_PAC_subjects.txt', '%s');
mv_PAC_drugs = text_read('multivar_PAC_drugs.txt', '%s');
mv_PAC_bands = text_read('multivar_PAC_bands.txt', '%s');

mv_PAC_ranksum = nan(no_drugs - 1, (no_freqs*no_channels).^2, 2);

for d = 2:no_drugs
    
    for b = 1:2
        
        saline_indices = strcmp(mv_PAC_drugs, 'saline')...
            & strcmp(mv_PAC_bands, long_band_labels{b + 4});
        
        drug_indices = strcmp(mv_PAC_drugs, drugs{d})...
            & strcmp(mv_PAC_bands, long_band_labels{b + 4});
        
        for comp = 1:((no_freqs*no_channels)^2)
            
            if any(~isnan(mv_PAC(saline_indices, comp))) && any(~isnan(mv_PAC(drug_indices, comp)))
                
                mv_PAC_ranksum(d - 1, comp, b) = ranksum(mv_PAC(saline_indices, comp), mv_PAC(drug_indices, comp), 'tail', 'left');
                
            end
            
        end
        
    end
    
end

mv_PAC_ranksum = min(1, reshape(mv_PAC_ranksum, [no_drugs - 1, no_freqs*no_channels, no_freqs*no_channels, 2])*((no_drugs - 1)*(no_freqs^2)*(no_channels^2)*2));

mv_PAC_test = mv_PAC_ranksum < .01;

save('multivar_PAC_ranksum.mat', 'mv_PAC_ranksum', 'mv_PAC_test')

figure

for b = 1:2
    
    upper_clim = all_dimensions(@nanmax, -log(mv_PAC_ranksum(:, :, :, b)));
    lower_clim = all_dimensions(@nanmin, -log(mv_PAC_ranksum(:, :, :, b)));
    
    for d = 1:(no_drugs - 1)
        
        subplot(2, no_drugs - 1, (b - 1)*(no_drugs - 1) + d)
        
        imagesc(-log(reshape(mv_PAC_ranksum(d, :, :, b), no_freqs*no_channels, no_freqs*no_channels)))
        
        axis xy
        
        set(gca, 'XTick', 1:(no_freqs*no_channels), 'XTickLabel', tick_labels(:, b),...
            'YTick', 1:(no_freqs*no_channels), 'YTickLabel', tick_labels(:, b))
        
        xticklabel_rotate([], 90)
        
        caxis([lower_clim upper_clim])
        
        title(drugs{d + 1})
        
        ylabel(long_band_labels{b + 4})
        
        if d == (no_drugs - 1), colorbar, end
        
    end
    
end

save_as_pdf(gcf, 'multivar_PAC_ranksum')

figure

hf_indices = [2 4 6]; %[2:4, 6:8, 10:12];
no_hf_indices = length(hf_indices);
lf_indices = [1 3 5]; %[1 5 9];
no_lf_indices = length(lf_indices);

for b = 1:2
    
    upper_clim = all_dimensions(@nanmax, -log(mv_PAC_ranksum(:, hf_indices, lf_indices, b)));
    lower_clim = all_dimensions(@nanmin, -log(mv_PAC_ranksum(:, hf_indices, lf_indices, b)));
    
    for d = 1:(no_drugs - 1)
        
        subplot(2, no_drugs - 1, (b - 1)*(no_drugs - 1) + d)
        
        imagesc(-log(reshape(mv_PAC_ranksum(d, hf_indices, lf_indices, b), no_hf_indices, no_lf_indices)))
        
        axis xy
        
        set(gca, 'XTick', 1:no_lf_indices, 'XTickLabel', tick_labels(lf_indices, b),...
            'YTick', 1:no_hf_indices, 'YTickLabel', tick_labels(hf_indices, b))
        
        xticklabel_rotate([], 90)
        
        caxis([lower_clim upper_clim])
        
        title(drugs{d + 1})
        
        if d == 1, ylabel(long_band_labels{b + 4}), end
        
        if d == no_drugs - 1, colorbar, end
        
    end
    
end

save_as_pdf(gcf, 'multivar_PAC_ranksum_cross')

figure

for b = 1:2
    
    upper_clim = all_dimensions(@nanmax, mv_PAC_test(:, :, :, b));
    lower_clim = all_dimensions(@nanmin, mv_PAC_test(:, :, :, b));
    
    for d = 1:(no_drugs - 1)
        
        subplot(2, no_drugs - 1, (b - 1)*(no_drugs - 1) + d)
        
        imagesc(reshape(mv_PAC_test(d, :, :, b), no_freqs*no_channels, no_freqs*no_channels))
        
        axis xy
        
        set(gca, 'XTick', 1:(no_freqs*no_channels), 'XTickLabel', tick_labels(:, b),...
            'YTick', 1:(no_freqs*no_channels), 'YTickLabel', tick_labels(:, b))
        
        xticklabel_rotate([], 90)
        
        caxis([lower_clim upper_clim])
        
        title(drugs{d + 1})
        
        ylabel(long_band_labels{b + 4})
        
        if d == (no_drugs - 1), colorbar, end
        
    end
    
end

save_as_pdf(gcf, 'multivar_PAC_test')

figure

% hf_indices = [2:4, 6:8, 10:12]; no_hf_indices = length(hf_indices);
% lf_indices = [1 5 9]; no_lf_indices = length(lf_indices);

for b = 1:2
    
    upper_clim = all_dimensions(@nanmax, mv_PAC_test(:, hf_indices, lf_indices, b));
    lower_clim = all_dimensions(@nanmin, mv_PAC_test(:, hf_indices, lf_indices, b));
    
    for d = 1:(no_drugs - 1)
        
        subplot(2, no_drugs - 1, (b - 1)*(no_drugs - 1) + d)
        
        imagesc(reshape(mv_PAC_test(d, hf_indices, lf_indices, b), no_hf_indices, no_lf_indices))
        
        axis xy
        
        set(gca, 'XTick', 1:no_lf_indices, 'XTickLabel', tick_labels(lf_indices, b),...
            'YTick', 1:no_hf_indices, 'YTickLabel', tick_labels(hf_indices, b))
        
        xticklabel_rotate([], 90)
        
        caxis([lower_clim upper_clim])
        
        title(drugs{d + 1})
        
        if d == 1, ylabel(long_band_labels{b + 4}), end
        
        if d == no_drugs - 1, colorbar, end
        
    end
    
end

save_as_pdf(gcf, 'multivar_PAC_test_cross')

figure

for b = 1:2
    
    upper_clim = all_dimensions(@nanmax, mv_PAC_test(:, lf_indices, lf_indices, b));
    lower_clim = all_dimensions(@nanmin, mv_PAC_test(:, lf_indices, lf_indices, b));
    
    for d = 1:(no_drugs - 1)
        
        subplot(2, no_drugs - 1, (b - 1)*(no_drugs - 1) + d)
        
        imagesc(reshape(mv_PAC_test(d, lf_indices, lf_indices, b), no_lf_indices, no_lf_indices))
        
        axis xy
        
        set(gca, 'XTick', 1:no_lf_indices, 'XTickLabel', tick_labels(lf_indices, b),...
            'YTick', 1:no_lf_indices, 'YTickLabel', tick_labels(lf_indices, b))
        
        xticklabel_rotate([], 90)
        
        caxis([lower_clim upper_clim])
        
        title(drugs{d + 1})
        
        if d == 1, ylabel(long_band_labels{b + 4}), end
        
        if d == no_drugs - 1, colorbar, end
        
    end
    
end

save_as_pdf(gcf, 'multivar_PAC_test_low')

figure

for b = 1:2
    
    upper_clim = all_dimensions(@nanmax, mv_PAC_test(:, hf_indices, hf_indices, b));
    lower_clim = all_dimensions(@nanmin, mv_PAC_test(:, hf_indices, hf_indices, b));
    
    for d = 1:(no_drugs - 1)
        
        subplot(2, no_drugs - 1, (b - 1)*(no_drugs - 1) + d)
        
        imagesc(reshape(mv_PAC_test(d, hf_indices, hf_indices, b), no_hf_indices, no_hf_indices))
        
        axis xy
        
        set(gca, 'XTick', 1:no_hf_indices, 'XTickLabel', tick_labels(hf_indices, b),...
            'YTick', 1:no_hf_indices, 'YTickLabel', tick_labels(hf_indices, b))
        
        xticklabel_rotate([], 90)
        
        caxis([lower_clim upper_clim])
        
        title(drugs{d + 1})
        
        if d == 1, ylabel(long_band_labels{b + 4}), end
        
        if d == no_drugs - 1, colorbar, end
        
    end
    
end

save_as_pdf(gcf, 'multivar_PAC_test_high')

end