function [x_nans, y_nans, comp_mat] = compare_channels

load('channels'), load('subjects'), load('drugs')
        
[x_nans, y_nans, comp_mat] = deal(nan(no_subjects*no_channels, no_subjects*no_channels, no_drugs));

figure

for d = 1:no_drugs
    
    drug = drugs{d};
    
    for chx = 1:no_channels
        
        for sx = 1:no_subjects
            
            x_chan = location_channels{chx}(sx);
            
            x_index = (sx - 1)*no_channels + chx;
            
            labels{x_index} = sprintf('%s %s (ch. %d)', subjects{sx}, channel_names{chx}, x_chan);
            
            for sy = sx:no_subjects
                
                for chy = chx:no_channels
                    
                    y_chan = location_channels{chy}(sy);
                    
                    y_index = (sy - 1)*no_channels + chy;
                    
                    for epoch = 1123:1223
                        
                        x_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{sx}, drug,...
                            subjects{sx}, drug, x_chan, epoch));
                        
                        x_nans(x_index, y_index, d) = x_nans(x_index, y_index, d) + (sum(~isnan(x_epoch)) == 0);
                        
                        y_epoch = load(sprintf('%s_%s/%s_%s_chan%d_epoch%d.txt', subjects{sy}, drug,...
                            subjects{sy}, drug, y_chan, epoch));
                        
                        y_nans(x_index, y_index, d) = y_nans(x_index, y_index, d) + (sum(~isnan(y_epoch)) == 0);
                        
                        comp_mat(x_index, y_index, d) = comp_mat(x_index, y_index, d) + nansum(x_epoch - y_epoch);
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
    comp_mat(x_nans(:, :, d) == 0 | y_nans(:, :, d) == 0, d) = max(comp_mat(:, :, d));
    
    figure
    
    imagesc(comp_mat(:, :, d))
    
    axis xy
    
    set(gca, 'XTickLabel', labels, 'YTickLabel', labels)

    save_as_pdf(gcf, sprintf('%s_compare_channels', drug))
    
end
        