function cplot_collected_MI_by_3_categories(name,rows,cols,x_ticks,y_ticks,cat3_labels,cat1_labels,cat2_labels,cat3_vec,cat1_vec,cat2_vec,MI)

% cat1_labels is for subplot rows. cat2_labels is for subplot columns. cat3_labels is for
% number of figures.

matrix_rows=length(y_ticks); matrix_columns=length(x_ticks);

long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};
long_cat3_labels=cat3_labels{2};

cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};
cat3_labels=cat3_labels{1};

no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);
no_cats3=length(cat3_labels);

stat_labels={'median','mean','std'};
long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

MI_stats=nan(matrix_rows,matrix_columns,no_stats);

close('all')

for c3=1:no_cats3
    
    cat3=char(cat3_labels{c3});
    
    MI_cat3=MI(strcmp(cat3_vec,cat3),:);
    
    cat1_in_cat3=cat1_vec(strcmp(cat3_vec,cat3));
    
    cat2_in_cat3=cat2_vec(strcmp(cat3_vec,cat3));
    
    figs=nan(3,no_cats1*no_cats2);
    
    for c1=1:no_cats1
        
        cat1=char(cat1_labels{c1});
        
        MI_cat1=MI_cat3(strcmp(cat1_in_cat3,cat1),:);
        
        cat2_in_cat1=cat2_in_cat3(strcmp(cat1_in_cat3,cat1));
        
        for c2=1:no_cats2
            
            cat2=char(cat2_labels{c2});
            
            MI_cat2=MI_cat1(strcmp(cat2_in_cat1,cat2),:);
            
            if ~isempty(MI_cat2) && size(MI_cat2,1)~=1
                
                MI_stats(:,:,1)=reshape(nanmedian(MI_cat2),matrix_rows,matrix_columns);
                
                MI_stats(:,:,2)=reshape(nanmean(MI_cat2),matrix_rows,matrix_columns);
                
                MI_stats(:,:,3)=reshape(nanstd(MI_cat2),matrix_rows,matrix_columns);
                
            else
                
                MI_stats=nan(matrix_rows,matrix_columns,3);
                
            end
            
            for m=1:no_stats
                
                figure(), imagesc(MI_stats(:,:,m))
                
                figs(m,(c1-1)*no_cats2+c2)=gcf;
                
%                 fprintf('m=%d, c1=%d, c2=%d\n',m,c1,c2)
                
                handl=figure_replotter(gcf,1,1,x_ticks,y_ticks,{[long_stat_labels{m},' ',long_cat1_labels{c1},' ',long_cat2_labels{c2}]});
                
                saveas(handl,[name,'_',cat3,'_',cat1,'_',cat2,'_',stat_labels{m},'.fig']);
                
                close(handl)
                
            end
            
        end
        
    end
    
    if no_cats2==1
        
        long_labels=long_cat1_labels;
        
    else
        
        long_labels={long_cat2_labels{:}, long_cat1_labels{:}};
        
    end
    
    for m=1:no_stats
        
        figure_replotter(figs(m,:),rows,cols,x_ticks,y_ticks,long_labels);
        
        saveas(gcf,[name,'_',cat3,'_',stat_labels{m},'.fig']);
        
        set(gcf,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
        
        print(gcf,'-dpdf',[name,'_',cat3,'_',stat_labels{m},'.pdf']);
        
        close(figs(m,:))
        
    end
        
end

close('all')