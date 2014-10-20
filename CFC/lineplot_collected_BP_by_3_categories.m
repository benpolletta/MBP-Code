function lineplot_collected_BP_by_3_categories(Title,name,band_labels,cat3_labels,cat1_labels,cat2_labels,cat3_vec,cat1_vec,cat2_vec,BP,stat)

% cat1_labels is for rows. cat2_labels is for columns. cat3_labels is for
% number of subplots. (At least in some figures - although actually it
% depends; see below.

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

BP_stats=zeros(no_bands,no_cats1,no_cats2,no_stats,no_cats3);

close('all')

for c3=1:no_cats3
    
    cat3=char(cat3_labels{c3});
    
    BP_cat3=BP(strcmp(cat3_vec,cat3),:);
    
    cat1_in_cat3=cat1_vec(strcmp(cat3_vec,cat3));
    
    cat2_in_cat3=cat2_vec(strcmp(cat3_vec,cat3));
    
    for c1=1:no_cats1
        
        cat1=char(cat1_labels{c1});
        
        BP_cat1=BP_cat3(strcmp(cat1_in_cat3,cat1),:);
        
        cat2_in_cat1=cat2_in_cat3(strcmp(cat1_in_cat3,cat1));
        
        for c2=1:no_cats2
            
            cat2=char(cat2_labels{c2});
            
            BP_cat2=BP_cat1(strcmp(cat2_in_cat1,cat2),:);
            
            if ~isempty(BP_cat2) && size(BP_cat2,1)>=5
            
                nan_median = nanmedian(BP_cat2);
                
                nan_median_mat = ones(size(BP_cat2))*diag(nan_median);
                
                BP_stats(:, c1, c2, 1, c3) = nan_median';
                
                BP_lower = BP_cat2;
                
                BP_lower(BP_cat2 >= nan_median_mat) = nan;
                
                BP_stats(:, c1, c2, 2, c3) = nanmedian(BP_lower)';
                
                BP_upper = BP_cat2;
                
                BP_upper(BP_cat2 <= nan_median_mat) = nan;
                
                BP_stats(:, c1, c2, 3, c3) = nanmedian(BP_upper)';
                
                BP_stats(:, c1, c2, 4, c3) = nanmean(BP_cat2)';
                
                BP_stats(:, c1, c2, 5, c3) = nanstd(BP_cat2)'/sqrt(size(BP_cat2,2));
                
            else
                
                BP_stats(:, c1, c2, 1:5, c3) = nan;
                
            end
            
        end
        
    end
    
    for b=1:no_bands
        
        %% For each band, lineplotting power by all cat2 categories (x-axis), in a single figure, with rows given by cat3 categories.
        
        figure(b)
        
        subplot(no_cats3,1,c3)
        
        if strcmp(stat, 'Mean')
            
            plot_data = reshape(BP_stats(b, :, :, 4, c3), no_cats1, no_cats2)';
            
            x_axis = (1:size(plot_data, 1))';
            
            error_data = reshape(BP_stats(b, :, :, 5, c3), no_cats1, no_cats2)';
            error_data = reshape(error_data, no_cats2, 1, no_cats1);
            error_data = repmat(error_data, [1 2 1]);
            
        elseif strcmp(stat, 'Median')
           
            plot_data = reshape(BP_stats(b, :, :, 1, c3), no_cats1, no_cats2)';
            
            x_axis = (1:size(plot_data, 1))';
            
            lower_q = reshape(BP_stats(b, :, :, 2, c3), no_cats1, no_cats2)';
            lower_q = plot_data - lower_q;
            lower_q = reshape(lower_q, no_cats2, 1, no_cats1);
            
            upper_q = reshape(BP_stats(b, :, :, 3, c3), no_cats1, no_cats2)';
            upper_q = upper_q - plot_data;
            upper_q = reshape(upper_q, no_cats2, 1, no_cats1);
            
            error_data(:, 1, :) = lower_q; error_data(:, 2, :) = upper_q;
            
        end
        
        boundedline(x_axis, plot_data, error_data)
        
        axis tight
        
        set(gca,'XTick',1:ceil(no_cats2/9):no_cats2,'XTickLabel',long_cat2_labels(1:ceil(no_cats2/9):no_cats2))
        
        legend(long_cat1_labels)
        
        if c3==1

%             title({Title,['Mean \pm S.E. of ',long_band_labels{b},' Band']})

            title({Title,[stat,' of ',long_band_labels{b},' Band']})
        
        end
            
        ylabel(cat3)
        
    end
    
end

for b=1:no_bands
    
%     saveas(b+no_cats3+no_cats1,[name,'_',band_labels{b},'.fig'])
    
    saveas(b,[name, '_', band_labels{b}, '_', stat, '.fig'])
    
end
    
save([name, '.mat'], 'BP_stats', 'band_labels', 'cat1_labels', 'cat2_labels', 'cat3_labels')