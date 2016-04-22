function NVP_BP_MIcorr

close('all')

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

%% BP comparisons.
    
load('BP_bands')

name = 'ALL_Frontal';

Frontal_BP_drugs = text_read([name, '/', name, '_drugs.txt'], '%s');
Frontal_BP_subjects = text_read([name, '/', name, '_subjects.txt'], '%s');
Frontal_BP_hrs = text_read([name, '/', name, '_hrs.txt'], '%s');
Frontal_BP_states = text_read([name, '/', name, '_states.txt'], '%s');
Frontal_BP = load([name, '/', name, '_BP.txt']);

name = 'ALL_CA1';

CA1_BP_drugs = text_read([name,'/',name,'_drugs.txt'],'%s');
CA1_BP_subjects = text_read([name,'/',name,'_subjects.txt'],'%s');
CA1_BP_hrs = text_read([name,'/',name,'_hrs.txt'],'%s');
CA1_BP_states = text_read([name,'/',name,'_states.txt'],'%s');
CA1_BP = load([name, '/', name, '_BP.txt']);

BP = Frontal_BP; BP(:, :, 2) = CA1_BP;

%% Comparing frontal & CA1 delta & theta.

chan_labels = {'Frontal', 'CA1'}; band_labels = {'Delta', 'Theta'};

colors = {[1 .5 0], [1 .5 .5]; [0 1 .5], [1 0 1]};

bonferroni_count = 4; plot_count = 1;

for ch = 1:2
    
    for band = 1:2
        
        BP1 = BP(strcmp(Frontal_BP_hrs, 'post1') & strcmp(Frontal_BP_drugs, 'NVP'), band, ch);
        
        BP2 = BP(strcmp(Frontal_BP_hrs, 'post4') & strcmp(Frontal_BP_drugs, 'NVP'), band, ch);
        
        % BP_median = nanmedian([BP1 BP2]);
        
        BP_mean = nanmean([BP1 BP2]);
        
        BP_se = nanstd([BP1 BP2])/sqrt(size(BP1, 1));
        
        subplot(3, 4, plot_count)
        
        % handle = bar([BP_median; nan nan]); 
        
        handle = barwitherr([BP_se; nan nan], [BP_mean; nan nan]);
        
        set(handle(1), 'FaceColor', colors{ch, band}), set(handle(2), 'FaceColor', colors{ch, band})
        
        bar_pos = get_bar_pos(handle);
        
        [~, p_val] = ttest(BP1, BP2); % ranksum(BP1, BP2);
        
        if p_val < .05/bonferroni_count
            
            bar_pairs = {[bar_pos(1, 1), bar_pos(2, 1)]};
            
            sigstar(bar_pairs, min(1, p_val*bonferroni_count))
            
        end
        
        box off
        
        xlims = [bar_pos(1, 1) - 1.5*diff(bar_pos(:, 1)), bar_pos(2, 1) + 1.5*diff(bar_pos(:, 1))];
        
        xlim(xlims)

        set(gca, 'XTick', bar_pos(:, 1)', 'XTickLabel', [1 4], 'FontSize', 16)
        
        xlabel('Hr. Post-Inj.')

        % xticklabel_rotate([], 45, [])
        
        title([chan_labels{ch}, ' ', band_labels{band}])
        
        plot_count = plot_count + 1;
        
    end

end

%% MI and BP correlations.

pairs = [cumsum(ones(3, 2)); nchoosek(1:3, 2); fliplr(nchoosek(1:3, 2))];

no_pairs = length(pairs);

channel_indices = [1 3];
        
load('NVP_MI_BP_pct_0to4hrs_by_6min.mat')

no_channels = 3;

for ch = 1:no_channels
    
    for band = 1:2
        
        pair_index = (pairs(:, 1) == ch) & (pairs(:, 2) == channel_indices(band));
        
        pair_corrs = All_corrs(:, band, pair_index);
        
        subplot(no_channels, no_channels, no_channels + (band - 1)*no_channels + ch)
        
        imagesc(reshape(pair_corrs, no_afs, no_pfs))
        
        colorbar
        
        axis xy
        
        title([channel_names{ch}, ' MI'], 'FontSize', 16)
        
        if ch == 1
            
            ylabel({'Correlation w/'; [channel_names{channel_indices(band)}, ' ', band_labels_long{band}]}, 'FontSize', 16)
            
        end
        
    end
    
end

save_as_pdf(gcf, 'NVP_BP_comparison_MIcorr')

end