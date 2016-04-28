function NVP_BP_comparison

close('all')

%% Loading data.

load('AP_freqs'), load('subjects'), load('drugs'), load('channels'), load('BP_bands')

%% Setting up information about periods (time since injection).
    
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

bonferroni_count = 2*3*3*20 + 4; plot_count = 1;

for ch = 1:2
    
    for band = 1:2
        
        BP1 = BP(strcmp(Frontal_BP_hrs, 'post1') & strcmp(Frontal_BP_drugs, 'NVP'), band, ch);
        
        BP2 = BP(strcmp(Frontal_BP_hrs, 'post4') & strcmp(Frontal_BP_drugs, 'NVP'), band, ch);
        
        % BP_median = nanmedian([BP1 BP2]);
        
        BP_mean = nanmean([BP1 BP2]);
        
        BP_se = nanstd([BP1 BP2])/sqrt(size(BP1, 1));
        
        subplot(1, 4, plot_count)
        
        % handle = bar([BP_median; nan nan]); 
        
        handle = barwitherr([BP_se; nan nan], [BP_mean; nan nan]);
        
        set(handle(1), 'FaceColor', colors{ch, band}), set(handle(2), 'FaceColor', colors{ch, band})
        
        bar_pos = get_bar_pos(handle);
        
        p_val = ranksum(BP1, BP2); % [~, p_val] = ttest(BP1, BP2);
        
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

save_as_pdf(gcf, 'NVP_BP_comparison')

end