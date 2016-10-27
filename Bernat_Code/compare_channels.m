function [x_nans, y_nans, comp_mat] = compare_channels

load('channels'), load('subjects'), load('drugs')
        
subj_pairs = nchoosek(1:no_subjects, 2);

no_subj_pairs = size(subj_pairs, 1); [r, c] = subplot_size(no_subj_pairs);

[x_nans, y_nans, comp_mat] = deal(zeros(no_channels, no_channels, no_subj_pairs, no_drugs));

for d = 1:no_drugs
    
    drug = drugs{d};
    
    figure
    
    for sp = 1:no_subj_pairs
        
        subplot(r, c, sp)
        
        title(sprintf('%s, %s vs. %s', drug, subjects{subj_pairs}), 'FontSize', 16)
        
        for chx = 1:no_channels
            
            x_chan = location_channels{chx}(sx);
            
            xlabels{chx} = sprintf('Ch. %d', chx);
            
            for chy = chx:no_channels
                
                y_chan = location_channels{chy}(sy);
                
                ylabels{chy} = sprintf('Ch. %d', chy);
                
                for epoch = 1123
                    
                    x_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{subj_pairs(sp, 1)}, drug,...
                        subjects{sx}, drug, x_chan, epoch));
                    
                    x_nans(chx, chy, sp, d) = x_nans(x_index, y_index, d) + (sum(~isnan(x_epoch)) == 0);
                    
                    y_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{subj_pairs(sp, 2)}, drug,...
                        subjects{sy}, drug, y_chan, epoch));
                    
                    y_nans(chx, chy, sp, d) = y_nans(x_index, y_index, d) + (sum(~isnan(y_epoch)) == 0);
                    
                    comp_mat(chx, chy, sp, d) = comp_mat(x_index, y_index, d) + abs(nansum(x_epoch - y_epoch));
                    
                end
                
            end
            
        end
        
        xlabel(subjects{subj_pairs(sp, 1), 'FontSize', 14)
        
        ylabel(subjects{subj_pairs(sp, 2), 'FontSize', 14)
        
        set(gca, 'XTick', 1:no_channels, 'XTickLabel', xlabels,...
            'YTick', 1:no_channels, 'YTickLabel', ylabels)
        
    end

    save_as_pdf(gcf, sprintf('%s_compare_channels', drug))
    
end

save('compare_channels.mat', 'x_nans', 'y_nans', 'comp_mat')
        