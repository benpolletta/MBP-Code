function cplot_collected_BP_by_3_categories(Title,name,band_labels,cat3_labels,cat1_labels,cat2_labels,cat3_vec,cat1_vec,cat2_vec,BP)

% cat1_labels is for rows. cat2_labels is for columns. cat3_labels is for
% number of subplots. (At least in some figures - although actually it
% depends; see below.

long_band_labels=band_labels{2};
long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};
long_cat3_labels=cat3_labels{2};

band_labels=band_labels{1};
cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};
cat3_labels=cat3_labels{1};

no_bands=length(band_labels);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);
no_cats3=length(cat3_labels);

stat_labels={'median','mean','std'};
long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

BP_stats=zeros(no_bands,no_cats1,no_cats2,no_stats);

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
                
                BP_stats(:,c1,c2,1)=nanmedian(BP_cat2)';
                
                BP_stats(:,c1,c2,2)=nanmean(BP_cat2)';
                
                BP_stats(:,c1,c2,3)=nanstd(BP_cat2)'/sqrt(size(BP_cat2,2));
                
            else
                
                BP_stats(:,c1,c2,1:3)=nan;
                
            end
            
        end
        
        %% Colorplotting all bands, by all of cat2 categories, in row c3 of a figure dedicated to cat1 category c1.
        
        figure(c1)
        
        subplot(no_cats3,1,c3)
        
        imagesc(reshape(BP_stats(:,c1,:,2),no_bands,no_cats2))
        
        axis xy
        
        colorbar
        
        set(gca,'XTick',1:no_cats2,'XTickLabel',cat2_labels,'YTick',1:no_bands,'YTickLabel',band_labels)
        
        ylabel(cat3)
        
        if c3==1
            
%             title({Title,['Mean for ',cat1]})
            
            title({Title,['Median for ',cat1]})
            
        end
        
        %% Colorplotting all bands, by all of cat2 categories, in row c1 of a figure dedicated to cat3 category c3.
        
        figure(no_cats1+c3)
        
        subplot(no_cats1,1,c1)
        
        imagesc(reshape(BP_stats(:,c1,:,2),no_bands,no_cats2))
        
        axis xy
        
        colorbar
        
        set(gca,'XTick',1:no_cats2,'XTickLabel',cat2_labels,'YTick',1:no_bands,'YTickLabel',band_labels)
        
        ylabel(cat1)
        
        if c1==1
            
%             title({Title,['Mean for ',cat3]})
            
            title({Title,['Median for ',cat3]})
            
        end
        
    end
    
    for b=1:no_bands
        
        %% For each band, barplotting power by all cat2 categories, in a single figure, with rows given by cat3 categories.
        
        figure(b+no_cats3+no_cats1)
        
        subplot(no_cats3,1,c3)
        
%         barwitherr(reshape(BP_stats(b,:,:,3),no_cats1,no_cats2)',reshape(BP_stats(b,:,:,2),no_cats1,no_cats2)')

        bar(reshape(BP_stats(b,:,:,1),no_cats1,no_cats2)')
        
        set(gca,'XTick',1:no_cats2,'XTickLabel',long_cat2_labels)
        
        legend(long_cat1_labels)
        
        if c3==1

%             title({Title,['Mean \pm S.E. of ',long_band_labels{b},' Band']})

            title({Title,['Median of ',long_band_labels{b},' Band']})
        
        end
            
        ylabel(cat3)
        
    end
    
end

for c1=1:no_cats1
    
%     saveas(c1,[name,'_',cat1_labels{c1},'.fig'])
    
    saveas(c1,[name,'_',cat1_labels{c1},'_median.fig'])
    
end

for c3=1:no_cats3
    
%     saveas(no_cats1+c3,[name,'_',cat3_labels{c3},'.fig'])
    
    saveas(no_cats1+c3,[name,'_',cat3_labels{c3},'_median.fig'])
    
end

for b=1:no_bands
    
%     saveas(b+no_cats3+no_cats1,[name,'_',band_labels{b},'.fig'])
    
    saveas(b+no_cats3+no_cats1,[name,'_',band_labels{b},'_median.fig'])
    
end