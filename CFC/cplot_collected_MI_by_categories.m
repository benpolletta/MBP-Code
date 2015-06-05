function cplot_collected_MI_by_categories(name,rows,cols,x_ticks,y_ticks,cat1_labels,cat2_labels,cat1_vec,cat2_vec,MI)

% cat1_labels is for rows. cat2_labels is for columns.

matrix_rows=length(y_ticks); matrix_columns=length(x_ticks);

long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};

cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};

no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);

stat_labels={'median','mean','std'};
long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

close('all')

figs=nan(3,no_cats1*no_cats2);

MI_stats = nan(matrix_rows, matrix_columns, no_cats1, no_cats2, no_stats);

for c1=1:no_cats1
    
    cat1=char(cat1_labels{c1});
    
    MI_cat1=MI(strcmp(cat1_vec,cat1),:);
    
    cat2_in_cat1=cat2_vec(strcmp(cat1_vec,cat1));
    
    for c2=1:no_cats2
        
        cat2=char(cat2_labels{c2});
        
        MI_cat2=MI_cat1(strcmp(cat2_in_cat1,cat2),:);
        
        if ~isempty(MI_cat2) && size(MI_cat2,1)~=1
            
            MI_stats(:,:,c1,c2,1)=reshape(nanmedian(MI_cat2),matrix_rows,matrix_columns);
            
            MI_stats(:,:,c1,c2,2)=reshape(nanmean(MI_cat2),matrix_rows,matrix_columns);
            
            MI_stats(:,:,c1,c2,3)=reshape(nanstd(MI_cat2),matrix_rows,matrix_columns);
            
        else
            
            MI_stats=nan(matrix_rows,matrix_columns,no_cats1,no_cats2,3);
            
        end
                
        for m=1:no_stats
            
            figure(), imagesc(MI_stats(:,:,c1,c2,m))
            
            figs(m,(c1-1)*no_cats2+c2)=gcf;
            
            handl=figure_replotter(gcf,1,1,12,18,x_ticks,y_ticks,{[long_stat_labels{m},' ',long_cat1_labels{c1},' ',long_cat2_labels{c2}]});
            
            saveas(handl,[name,'_',cat1,'_',cat2,'_',stat_labels{m},'.fig']);
            
        end
        
    end
    
end

save([name, '_cplot_data.mat'], 'MI_stats', 'long_cat1_labels', 'cat1_labels', 'long_cat2_labels', 'cat2_labels', 'stat_labels')

if no_cats2==1
    
    long_labels=long_cat1_labels;
    
else
    
    long_labels={long_cat2_labels{:}, long_cat1_labels{:}};
    
end

for m=1:no_stats
    
    figure_replotter(figs(m,:),rows,cols,4,7,x_ticks,y_ticks,{long_cat2_labels{:}, long_cat1_labels{:}});
    
    saveas(gcf,[name,'_',stat_labels{m},'.fig']);
    
    set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
    
    print(gcf,'-dpdf',[name,'_',stat_labels{m},'.pdf']);
    
end