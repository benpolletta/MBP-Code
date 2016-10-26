function stats_collected_BP_by_categories(name,band_labels,cat1_labels,cat2_labels,cat1_vec,cat2_vec,BP)

% cat1_labels is for drugs. cat2_labels is for hours. Does stats against
% saline.

band_labels=band_labels{1};
cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};

no_bands=length(band_labels);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);

BP_ranksum = nan(no_bands, no_cats2, no_cats1 - 1, 2);

close('all')

BP_1 = BP(strcmp(cat1_vec, cat1_labels{1}), :);
    
cat2_in_1 = cat2_vec(strcmp(cat1_vec, cat1_labels{1}));

for c1=2:no_cats1
    
    cat1 = char(cat1_labels{c1});
    
    BP_cat1 = BP(strcmp(cat1_vec, cat1), :);
    
    cat2_in_cat1 = cat2_vec(strcmp(cat1_vec, cat1));
    
    for c2=1:no_cats2
        
        cat2 = char(cat2_labels{c2});
        
        BP_1_cat2 = BP_1(strcmp(cat2_in_1, cat2), :);
        
        BP_cat1_cat2 = BP_cat1(strcmp(cat2_in_cat1, cat2), :);
        
        if ~isempty(BP_cat1_cat2) && size(BP_cat1_cat2, 1) >= 5 && ~isempty(BP_1_cat2) && size(BP_1_cat2, 1) >= 5
            
            for b = 1:no_bands
            
                BP_ranksum(b, c2, c1 - 1, 1) = ranksum(BP_1_cat2(:, b), BP_cat1_cat2(:, b), 'tail', 'left');
            
                BP_ranksum(b, c2, c1 - 1, 2) = ranksum(BP_1_cat2(:, b), BP_cat1_cat2(:, b), 'tail', 'right');
                
            end
            
        else
            
            BP_ranksum(:, c2, c1 - 1) = nan;
            
        end
        
    end
    
end
    
save([name, '_ranksum.mat'], 'BP_ranksum', 'band_labels', 'cat1_labels', 'cat2_labels')