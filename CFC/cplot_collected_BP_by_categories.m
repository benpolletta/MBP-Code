function cplot_collected_BP_by_categories(Title,name,band_labels,cat1_labels,cat2_labels,cat1_vec,cat2_vec,BP)

% cat1_labels is for rows. cat2_labels is for columns.

long_band_labels=band_labels{2};
long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};

band_labels=band_labels{1};
cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};

no_bands=length(band_labels);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);

stat_labels={'median','mean','std'};
long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

BP_stats=zeros(no_bands,no_cats1,no_cats2,no_stats);

close('all')

for c1=1:no_cats1
    
    cat1=char(cat1_labels{c1});
    
    BP_cat1=BP(strcmp(cat1_vec,cat1),:);
    
    cat2_in_cat1=cat2_vec(strcmp(cat1_vec,cat1));
    
    for c2=1:no_cats2
        
        cat2=char(cat2_labels{c2});
        
        BP_cat2=BP_cat1(strcmp(cat2_in_cat1,cat2),:);
        
        if ~isempty(BP_cat2) && size(BP_cat2,1)>=5
            
            BP_stats(:,c1,c2,1)=nanmedian(BP_cat2)';
            
            BP_stats(:,c1,c2,2)=nanmean(BP_cat2)';
            
            BP_stats(:,c1,c2,3)=nanstd(BP_cat2)/sqrt(size(BP_cat2,2))';
            
        else
            
            BP_stats(:,c1,c2,1:3)=nan;
            
        end
        
    end
    
end

for b=1:no_bands
    
    figure()
        
    barwitherr(reshape(BP_stats(b,:,:,3),no_cats1,no_cats2)',reshape(BP_stats(b,:,:,2),no_cats1,no_cats2)')
    
    set(gca,'XTickLabel',long_cat2_labels)
    
    legend(long_cat1_labels)
    
    title({Title,['Mean \pm S.E. of ',long_band_labels{b},' Band Power']})
    
    saveas(gcf,[name,'_',band_labels{b},'.fig'])
    saveas(gcf,[name,'_',band_labels{b},'.pdf'])
    
end