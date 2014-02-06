function cplot_collected_AVP_by_categories(name,rows,cols,x_ticks,y_ticks,cat1_labels,cat2_labels,cat1_vec,cat2_vec,AVP,norm_flag)

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

for c1=1:no_cats1
    
    cat1=char(cat1_labels{c1});
    
    AVP_cat1=AVP(strcmp(cat1_vec,cat1),:);
    
    cat2_in_cat1=cat2_vec(strcmp(cat1_vec,cat1));
    
    for c2=1:no_cats2
        
        cat2=char(cat2_labels{c2});
        
        AVP_cat2=AVP_cat1(strcmp(cat2_in_cat1,cat2),:);
        
        if ~isempty(AVP_cat2) && size(AVP_cat2,1)~=1
            
            AVP_stats(:,:,1)=reshape(nanmedian(AVP_cat2),matrix_rows,matrix_columns);
            
            AVP_stats(:,:,2)=reshape(nanmean(AVP_cat2),matrix_rows,matrix_columns);
            
            AVP_stats(:,:,3)=reshape(nanstd(AVP_cat2),matrix_rows,matrix_columns);
            
        else
            
            AVP_stats=nan(matrix_rows,matrix_columns,3);
            
        end
        
        if norm_flag==0
            
            mean_est_amp=repmat(nanmean(AVP_stats),matrix_rows,1);
            
            AVP_stats=AVP_stats./mean_est_amp;
            
        end
            
        for m=1:no_stats
            
            figure(), imagesc(AVP_stats(:,:,m)')
            
            figs(m,(c1-1)*no_cats2+c2)=gcf;
            
            handl=figure_replotter(gcf,1,1,y_ticks,x_ticks,{[long_stat_labels{m},' ',long_cat1_labels{c1},' ',long_cat2_labels{c2}]});
            
            saveas(handl,[name,'_',cat1,'_',cat2,'_',stat_labels{m},'.fig']);
            
            close(handl)
            
        end
        
    end
    
end

if no_cats2==1
    
    long_labels=long_cat1_labels;
    
elseif no_cats1==1
    
    long_labels=long_cat2_labels;
    
else
    
    long_labels={long_cat2_labels{:}, long_cat1_labels{:}};
    
end

for m=1:no_stats
    
    figure_replotter(figs(m,:),rows,cols,y_ticks,x_ticks,long_labels);
    
    if norm_flag==0
        
        saveas(gcf,[name,'_',stat_labels{m},'.fig']);
        saveas(gcf,[name,'_',stat_labels{m},'.pdf']);
        
    else
        
        saveas(gcf,[name,'_',stat_labels{m},'_norm.fig']);
        saveas(gcf,[name,'_',stat_labels{m},'_norm.pdf']);
        
    end
    
    close(figs(m,:))
    
end

close('all')