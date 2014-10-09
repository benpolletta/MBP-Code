function lineplot_collected_BP_by_categories(Title,name,band_labels,cat1_labels,cat2_labels,cat1_vec,cat2_vec,BP,stat,c_order)

% cat1_labels is for rows. cat2_labels is for columns. cat3_labels is for
% number of subplots. (At least in some figures - although actually it
% depends; see below.

long_band_labels=band_labels{2};
long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};

band_labels=band_labels{1};
cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};

no_bands=length(band_labels);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);

stat_labels={'median','Q1','Q3','mean','std'};
no_stats=length(stat_labels);

[rows, cols] = subplot_size(no_bands);

BP_stats = zeros(no_bands, no_cats2, no_stats, no_cats1);

close('all')

for c1=1:no_cats1
    
    cat1=char(cat1_labels{c1});
    
    BP_cat1 = BP(strcmp(cat1_vec, cat1), :);
    
    cat2_in_cat1 = cat2_vec(strcmp(cat1_vec, cat1));
    
    for c2=1:no_cats2
        
        cat2 = char(cat2_labels{c2});
        
        BP_cat2 = BP_cat1(strcmp(cat2_in_cat1, cat2), :);
        
        if ~isempty(BP_cat2) && size(BP_cat2,1)>=5
            
            nan_median = nanmedian(BP_cat2);
            
            nan_median_mat = ones(size(BP_cat2))*diag(nan_median);
            
            BP_stats(:, c2, 1, c1) = nan_median';
            
            BP_lower = BP_cat2;
            
            BP_lower(BP_cat2 >= nan_median_mat) = nan;
            
            BP_stats(:, c2, 2, c1) = nanmedian(BP_lower)';
            
            BP_upper = BP_cat2;
            
            BP_upper(BP_cat2 <= nan_median_mat) = nan;
            
            BP_stats(:, c2, 3, c1) = nanmedian(BP_upper)';
            
            BP_stats(:, c2, 4, c1) = nanmean(BP_cat2)';
            
            BP_stats(:, c2, 5, c1) = nanstd(BP_cat2)'/sqrt(size(BP_cat2,2));
            
        else
            
            BP_stats(:, c2, 1:5, c1) = nan;
            
        end
        
    end
   
    %% For each band, lineplotting power by all cat2 categories (x-axis), in a single figure, with rows given by cat1 categories.
    
    for b=1:no_bands
        
        figure(b)
        
        subplot(no_cats1, 1, c1)
        
        error_data = nan(no_cats2, 2);
        
        if strcmp(stat, 'Mean')
            
            plot_data = reshape(BP_stats(b, :, 4, c1), no_cats2, 1);
            
            x_axis = (1:size(plot_data, 1))';
            
            error_data = reshape(BP_stats(b, :, 5, c1), no_cats2, 1);
            error_data = reshape(error_data, no_cats2, 1, 1);
            error_data = repmat(error_data, [1 2 1]);
            
        elseif strcmp(stat, 'Median')
            
            plot_data = reshape(BP_stats(b, :, 1, c1), no_cats2, 1);
            
            x_axis = (1:size(plot_data, 1))';
            
            lower_q = reshape(BP_stats(b, :, 2, c1), no_cats2, 1);
            lower_q = plot_data - lower_q;
            
            upper_q = reshape(BP_stats(b, :, 3, c1), no_cats2, 1);
            upper_q = upper_q - plot_data;
            
            error_data(:, 1) = lower_q; error_data(:, 2) = upper_q;
            
        end
        
        boundedline(x_axis, plot_data, error_data)
        
        axis tight
        
        set(gca,'XTick',1:ceil(no_cats2/9):no_cats2,'XTickLabel',long_cat2_labels(1:ceil(no_cats2/9):no_cats2))
        
        % legend(long_cat1_labels)
        
        if c1 == 1
            
            title({Title,[stat,' of ',long_band_labels{b},' Band']})
            
        end
        
        ylabel(cat1)
        
    end
    
    %% For each cat1 category past the second (e.g., drugs), lineplotting power from [1 c1] (x-axis), in a single figure, with rows given by bands.
    
    if c1 >= 2
        
        figure(no_bands + c1 - 1)
        
        cat1_indices = [1 c1];
        
        for b=1:no_bands
            
            subplot(rows, cols, b)
            
            error_data = nan(no_cats2, 2, 2);
            
            if strcmp(stat, 'Mean')
                
                plot_data = reshape(BP_stats(b, :, 4, cat1_indices), no_cats2, 2);
                
                x_axis = (1:size(plot_data, 1))';
                
                error_data = reshape(BP_stats(b, :, 5, cat1_indices), no_cats2, 2);
                error_data = reshape(error_data, no_cats2, 1, 2);
                error_data = repmat(error_data, [1 2 1]);
                
            elseif strcmp(stat, 'Median')
                
                plot_data = reshape(BP_stats(b, :, 1, cat1_indices), no_cats2, 2);
                
                x_axis = (1:size(plot_data, 1))';
                
                lower_q = reshape(BP_stats(b, :, 2, cat1_indices), no_cats2, 2);
                lower_q = plot_data - lower_q;
                lower_q = reshape(lower_q, no_cats2, 1, 2);
                
                upper_q = reshape(BP_stats(b, :, 3, cat1_indices), no_cats2, 2);
                upper_q = upper_q - plot_data;
                upper_q = reshape(upper_q, no_cats2, 1, 2);
                
                error_data(:, 1, :) = lower_q; error_data(:, 2, :) = upper_q;
                
            end
            
            boundedline(x_axis, plot_data, error_data, 'cmap', c_order(cat1_indices,:))
            
            axis tight
            
            set(gca,'XTick',1:ceil(no_cats2/8):no_cats2,'XTickLabel',long_cat2_labels(1:ceil(no_cats2/8):no_cats2))
            
            % legend(long_cat1_labels)
            
            if b == 1
                
                title({Title,[stat,' of ',long_cat1_labels{c1}]})
                
            end
            
            ylabel(long_band_labels{b})
            
        end
        
    end
    
end

for b = 1:no_bands
    
    save_as_pdf(b, [name,'_',band_labels{b},'_',stat])
    
end

for c1 = 2:no_cats1
    
    save_as_pdf(no_bands + c1 - 1, [name,'_',cat1_labels{c1},'_',stat])
    
end
    
save([name, '_BP_stats.mat'], 'BP_stats', 'band_labels', 'cat1_labels', 'cat2_labels', 'stat_labels')
        
%% Lineplotting power by all cat2 categories (x-axis), in a single figure, with rows given by bands.

figure(no_bands + no_cats1)

for b=1:no_bands
    
    subplot(rows, cols, b)
    
    error_data = nan(no_cats2, 2, no_cats1);
    
    if strcmp(stat, 'Mean')
        
        plot_data = reshape(BP_stats(b, :, 4, :), no_cats2, no_cats1);
        
        x_axis = (1:size(plot_data, 1))';
        
        error_data = reshape(BP_stats(b, :, 5, :), no_cats2, no_cats1);
        error_data = reshape(error_data, no_cats2, 1, no_cats1);
        error_data = repmat(error_data, [1 2 1]);
        
    elseif strcmp(stat, 'Median')
        
        plot_data = reshape(BP_stats(b, :, 1, :), no_cats2, no_cats1);
        
        x_axis = (1:size(plot_data, 1))';
        
        lower_q = reshape(BP_stats(b, :, 2, :), no_cats2, no_cats1);
        lower_q = plot_data - lower_q;
        lower_q = reshape(lower_q, no_cats2, 1, no_cats1);
        
        upper_q = reshape(BP_stats(b, :, 3, :), no_cats2, no_cats1);
        upper_q = upper_q - plot_data;
        upper_q = reshape(upper_q, no_cats2, 1, no_cats1);
        
        error_data(:, 1, :) = lower_q; error_data(:, 2, :) = upper_q;
        
    end
    
    h = boundedline(x_axis, plot_data, error_data, 'cmap', c_order);
    
    hold on
    
    axis tight
    
    set(gca,'XTick',1:ceil(no_cats2/8):no_cats2,'XTickLabel',long_cat2_labels(1:ceil(no_cats2/8):no_cats2))
    
    if b == 1
        
        if c1 == no_cats1
            
            legend(h, long_cat1_labels)
            
        end
        
        title([stat, ' ', Title])
        
    end
    
    ylabel(long_band_labels{b})
    
end

save_as_pdf(gcf, [name,'_',stat])