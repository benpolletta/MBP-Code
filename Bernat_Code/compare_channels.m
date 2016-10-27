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
        
        title(sprintf('%s, %s vs. %s', drug, subjects{subj_pairs(sp, :)}), 'FontSize', 16)
        
        xlabels = cell(no_channels, 1);
        
        ylabels = cell(no_channels, 1);
        
        for chx = 1:no_channels
            
            x_chan = location_channels{chx}(subj_pairs(sp, 1));
            
            xlabels{chx} = sprintf('Ch. %d', x_chan);
            
            for chy = chx:no_channels
                
                y_chan = location_channels{chy}(subj_pairs(sp, 2));
                
                ylabels{chy} = sprintf('Ch. %d', y_chan);
                
                for epoch = 1123
                    
                    x_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{subj_pairs(sp, 1)}, drug,...
                        subjects{subj_pairs(sp, 1)}, drug, x_chan, epoch));
                    
                    x_nans(chx, chy, sp, d) = x_nans(chx, chy, sp, d) + (sum(~isnan(x_epoch)) == 0);
                    
                    y_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{subj_pairs(sp, 2)}, drug,...
                        subjects{subj_pairs(sp, 2)}, drug, y_chan, epoch));
                    
                    y_nans(chx, chy, sp, d) = y_nans(chx, chy, sp, d) + (sum(~isnan(y_epoch)) == 0);
                    
                    comp_mat(chx, chy, sp, d) = comp_mat(chx, chy, sp, d) + abs(nansum(x_epoch - y_epoch));
                    
                end
                
            end
            
        end
        
        colormap([0 0 0; 1 1 1])
        
        imagesc(1:no_channels, 1:no_channels, comp_mat(:, :, sp, d) > 0)
        
        xlabel(subjects{subj_pairs(sp, 1)}, 'FontSize', 14)
        
        ylabel(subjects{subj_pairs(sp, 2)}, 'FontSize', 14)
        
        set(gca, 'XTick', 1:no_channels, 'XTickLabel', xlabels,...
            'YTick', 1:no_channels, 'YTickLabel', ylabels)
        
    end

    save_as_pdf(gcf, sprintf('%s_compare_channels', drug))
    
end

save('compare_channels.mat', 'x_nans', 'y_nans', 'comp_mat')
        