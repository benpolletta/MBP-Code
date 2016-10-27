function comp_mat = compare_channels

load('channels'), load('subjects'), load('drugs')
        
comp_mat = nan(no_subjects*no_channels, no_subjects*no_channels, no_drugs);

figure

for d = 1:no_drugs
    
    drug = drugs{d};
    
    for chx = 1:no_channels
        
        for sx = 1:no_subjects
            
            x_chan = location_channels{chx}(sx);
            
            x_index = (sx - 1)*no_channels + chx;
            
            labels{x_index} = sprintf('%s %s (ch. %d)', subjects{sx}, channel_names{chx}, x_chan);
            
            x_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{sx}, drug,...
                subjects{sx}, drug, x_chan, 1123));
            
            for sy = sx:no_subjects
                
                for chy = chx:no_channels
                    
                    y_chan = location_channels{chx}(sx);
                    
                    y_index = (sy - 1)*no_channels + chy;
                    
                    y_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{sy}, drug,...
                        subjects{sy}, drug, y_chan, 1123));
                    
                    comp_mat(x_index, y_index, d) = sum(x_epoch - y_epoch);
                    
                end
                
            end
            
        end
        
    end
    
    subplot(1, no_drugs, d)
    
    imagesc(comp_mat(:, :, d))
    
    axis xy
    
    set(gca, 'XTickLabel', labels, 'YTickLabel', labels)
    
end

save_as_pdf(gcf, 'compare_channels')
        