function cplot_collected_spec_by_3_categories(Title,name,freqs,bands,stops,c_order,cat3_labels,cat1_labels,cat2_labels,cat3_vec,cat1_vec,cat2_vec,spec)

% cat1_labels is for rows. cat2_labels is for columns. cat3_labels is for
% number of subplots.

no_bands=size(bands,1);
band_indices=cell(no_bands);

for b=1:no_bands
    
    band_indices{b}=find(freqs>=bands(b,1) & freqs<=bands(b,2));
    
end

no_stops=size(stops,1);

for s=1:no_stops
    
    spec(:,freqs>=stops(s,1) & freqs<=stops(s,2))=nan;

end

long_cat1_labels=cat1_labels{2};
long_cat2_labels=cat2_labels{2};
long_cat3_labels=cat3_labels{2};

cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};
cat3_labels=cat3_labels{1};

no_freqs=length(freqs);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);
no_cats3=length(cat3_labels);

stat_labels={'median','mean','std'};
% long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

spec_stats=zeros(no_freqs,no_cats1,no_cats2,no_stats);

close('all')

for c3=1:no_cats3
    
    cat3=char(cat3_labels{c3});
    
    spec_cat3=spec(strcmp(cat3_vec,cat3),:);
    
    cat1_in_cat3=cat1_vec(strcmp(cat3_vec,cat3));
    
    cat2_in_cat3=cat2_vec(strcmp(cat3_vec,cat3));
    
    for c1=1:no_cats1
        
        cat1=char(cat1_labels{c1});
        
        spec_cat1=spec_cat3(strcmp(cat1_in_cat3,cat1),:);
        
        cat2_in_cat1=cat2_in_cat3(strcmp(cat1_in_cat3,cat1));
        
        for c2=1:no_cats2
            
            cat2=char(cat2_labels{c2});
            
            spec_cat2=spec_cat1(strcmp(cat2_in_cat1,cat2),:);
            
            if ~isempty(spec_cat2) && size(spec_cat2,1)>=5
                
                spec_stats(:,c1,c2,1)=nanmedian(spec_cat2)';
                
                spec_stats(:,c1,c2,2)=nanmean(spec_cat2)';
                
                spec_stats(:,c1,c2,3)=nanstd(spec_cat2)'/sqrt(size(spec_cat2,2));
                
            else
                
                spec_stats(:,c1,c2,1:3)=nan;
                
            end
            
        end
        
        %% Plots by Band.
        
        for b=1:no_bands
            
            band_freqs=freqs(band_indices{b});
            
            band_width=length(band_freqs);

            tick_indices=1:floor(band_width/10):band_width;
            
            band_ticks=band_freqs(tick_indices);
            
            if mean(band_ticks)<10
                
                band_labels=round(10*band_ticks)/10;
                
            else
                
                band_labels=round(band_ticks);
                
            end
            
            %% Colorplots by Band.
            
            figure(c1)
            
            subplot(no_cats3,no_bands,(c3-1)*no_bands+b)
            
            imagesc(reshape(spec_stats(band_indices{b},c1,:,2),band_width,no_cats2))
            
            axis xy
            
            colorbar
            
            set(gca,'XTick',1:ceil(no_cats2/5):no_cats2,'XTickLabel',cat2_labels(1:ceil(no_cats2/5):no_cats2),'YTick',tick_indices,'YTickLabel',band_labels)
            
            if b==1
                
                ylabel({cat3,'Frequency (Hz)'})
            
            end
            
            if c3==1 && b==ceil(no_bands/2)
                
                title({Title,['Mean for ',char(long_cat1_labels{c1})]})
                
                %             title({Title,['Median for ',cat1]})
                
            end
            
            figure(2*no_cats1+c3)
            
            subplot(no_cats1,no_bands,(c1-1)*no_bands+b)
            
            imagesc(reshape(spec_stats(band_indices{b},c1,:,2),band_width,no_cats2))
            
            axis xy
            
            colorbar
            
            set(gca,'XTick',1:ceil(no_cats2/5):no_cats2,'XTickLabel',cat2_labels(1:ceil(no_cats2/5):no_cats2),'YTick',tick_indices,'YTickLabel',band_labels)
            
            if b==1
                
                ylabel({cat1,'Frequency (Hz)'})
            
            end
            
            if c1==1 && b==ceil(no_bands/2)
                
                title({Title,['Mean for ',char(long_cat3_labels{c3})]})
                
                %             title({Title,['Mean for ',cat3]})
                
            end
            
            %% Line Plots by Band.
            
            figure(no_cats1+c1)
            
            set(gcf,'DefaultAxesColorOrder',c_order)
            
            subplot(no_cats3,no_bands,(c3-1)*no_bands+b)
            
            plot(band_freqs,reshape(spec_stats(band_indices{b},c1,:,2),band_width,no_cats2))
            
            hold on
            
            plot(band_freqs,reshape(spec_stats(band_indices{b},c1,:,2),band_width,no_cats2)+reshape(spec_stats(band_indices{b},c1,:,3),band_width,no_cats2),':')
            
            plot(band_freqs,reshape(spec_stats(band_indices{b},c1,:,2),band_width,no_cats2)-reshape(spec_stats(band_indices{b},c1,:,3),band_width,no_cats2),':')
            
            set(gca,'XTick',band_ticks,'XTickLabel',band_labels)
            
            xlim([band_ticks(1) band_ticks(end)])
            
            if b==no_bands && c3==1
                
                legend(long_cat2_labels,'Location','BestOutside')
                
            end
                
            if b==1
                
                ylabel(cat3)
                
            end   
                
            if b==ceil(no_bands/2) && c3==1
                
                title({Title,['Mean for ',char(long_cat1_labels{c1})]})
                
                % title({Title,['Median for ',cat1]})
                
            end
            
        end
        
    end
    
end

for c1=1:no_cats1
    
    saveas(c1,[name,'_',cat1_labels{c1},'.fig'])
    
    saveas(no_cats1+c1,[name,'_',cat1_labels{c1},'_line.fig'])
    
%     saveas(c1,[name,'_',cat1_labels{c1},'_median.fig'])
    
end

for c3=1:no_cats3
    
    saveas(2*no_cats1+c3,[name,'_',cat3_labels{c3},'.fig'])
    
%     saveas(no_cats1+c3,[name,'_',cat3_labels{c3},'_median.fig'])
    
end