function stats_collected_BP_by_3_categories(name,band_labels,cat3_labels,cat1_labels,cat2_labels,cat3_vec,cat1_vec,cat2_vec,BP)

% cat3 is like states, cat1 is like drugs, cat2 is like periods. 

long_band_labels=band_labels{2};
long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};

band_labels=band_labels{1};
cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};
cat3_labels=cat3_labels{1};

no_bands=length(band_labels);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);
no_cats3=length(cat3_labels);

stat_labels={'median','Q1','Q3','mean','std'};
no_stats=length(stat_labels);

BP_ranksum = zeros(no_bands, no_cats3, no_cats1 - 1, no_cats2);

close('all')

for c3=1:no_cats3
    
    cat3=char(cat3_labels{c3});
    
    BP_cat3=BP(strcmp(cat3_vec,cat3),:);
    
    cat1_in_cat3=cat1_vec(strcmp(cat3_vec,cat3));
    
    cat2_in_cat3=cat2_vec(strcmp(cat3_vec,cat3));
    
    BP_1 = BP_cat3(strcmp(cat1_in_cat3, cat1_labels{1}), :);
    
    cat2_in_1 = cat2_in_cat3(strcmp(cat1_in_cat3, cat1_labels{1}));
    
    for c1=2:no_cats1
        
        cat1=char(cat1_labels{c1});
        
        BP_cat1=BP_cat3(strcmp(cat1_in_cat3,cat1),:);
        
        cat2_in_cat1=cat2_in_cat3(strcmp(cat1_in_cat3,cat1));
        
        for c2=1:no_cats2
            
            cat2=char(cat2_labels{c2});
            
            BP_1_cat2 = BP_1(strcmp(cat2_in_1, cat2), :);
            
            BP_cat1_cat2 = BP_cat1(strcmp(cat2_in_cat1, cat2), :);
            
            if ~isempty(BP_cat1_cat2) && size(BP_cat1_cat2,1)>=5 && any(sum(~isnan(BP_cat1_cat2)) >= size(BP_cat1_cat2, 1)/2) ...
                    && ~isempty(BP_1_cat2) && size(BP_1_cat2,1)>=5 && any(sum(~isnan(BP_1_cat2)) >= size(BP_1_cat2, 1)/2)
                
                for b = 1:no_bands
                    
                    BP_ranksum(b, c3, c1 - 1, c2) = ranksum(BP_1_cat2(:, b), BP_cat1_cat2(:, b), 'tail', 'left');
                    
                end
                
            else
                
                BP_ranksum(:, c3, c1 - 1, c2) = nan;
                
            end
            
        end
        
    end
    
end
    
save([name, '_ranksum.mat'], 'BP_ranksum', 'band_labels', 'cat1_labels', 'cat2_labels', 'cat3_labels')