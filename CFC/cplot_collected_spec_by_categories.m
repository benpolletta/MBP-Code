function cplot_collected_spec_by_categories(Title,name,freqs,bands,band_names,stops,c_order,cat1_labels,cat2_labels,cat1_vec,cat2_vec,spec)

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

cat1_labels=cat1_labels{1};
cat2_labels=cat2_labels{1};

no_freqs=length(freqs);
no_cats1=length(cat1_labels);
no_cats2=length(cat2_labels);

stat_labels={'median','mean','std'};
long_stat_labels={'Median','Mean','St. Dev.'};
no_stats=length(stat_labels);

spec_stats=zeros(no_freqs,no_cats1,no_cats2,no_stats);

close('all')

for c1=1:no_cats1
    
    cat1=char(cat1_labels{c1});
    
    spec_cat1=spec(strcmp(cat1_vec,cat1),:);
    
    cat2_in_cat1=cat2_vec(strcmp(cat1_vec,cat1));
    
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
    
    for s=1:no_stats
        
        %% Plots by Band.
        
        for b=1:no_bands
            
            band_freqs=freqs(band_indices{b});
            
            band_width=length(band_freqs);
            
            tick_indices=1:ceil(band_width/10):band_width;
            
            band_ticks=band_freqs(tick_indices);
            
            if mean(band_ticks)<10
                
                band_labels=round(10*band_ticks)/10;
                
            else
                
                band_labels=round(band_ticks);
                
            end
            
            %% Colorplots by Band.
            
            % Figures for each drug.
            
            figure((s-1)*(no_cats1+2)+c1)
            
            subplot(no_bands,1,b)
            
            imagesc(reshape(spec_stats(band_indices{b},c1,:,s),band_width,no_cats2))
            
            axis xy
            
            colorbar
            
            set(gca,'XTick',1:ceil(no_cats2/5):no_cats2,'XTickLabel',cat2_labels(1:ceil(no_cats2/5):no_cats2),'YTick',tick_indices,'YTickLabel',band_labels)
            
            if c1==1
                
                if ~isempty(band_names)
                    
                    ylabel({band_names{b},'Frequency (Hz)'})
                    
                else
                    
                    ylabel('Frequency (Hz)')
                    
                end
                
            end
            
            if b==1
                
                title({Title,[long_stat_labels{s},' for ',cat1]})
                
            end
            
            % Figure w/ all drugs.
            
            figure((s-1)*(no_cats1+2)+no_cats1+1)
            
            subplot(no_bands,no_cats1,(b-1)*no_cats1+c1)
            
            imagesc(reshape(spec_stats(band_indices{b},c1,:,s),band_width,no_cats2))
            
            axis xy
            
            colorbar
            
            set(gca,'XTick',1:ceil(no_cats2/5):no_cats2,'XTickLabel',cat2_labels(1:ceil(no_cats2/5):no_cats2),'YTick',tick_indices,'YTickLabel',band_labels)
            
            if c1==1
                
                if ~isempty(band_names)
                    
                    ylabel({band_names{b},'Frequency (Hz)'})
                    
                else
                    
                    ylabel('Frequency (Hz)')
                    
                end
                
            end
            
            if b==1
                
                title({Title,[long_stat_labels{s},' for ',cat1]})
                
            end
            
            %% Line Plots by Band.
            
            figure(s*(no_cats1+2))
            
            set(gcf,'DefaultAxesColorOrder',c_order)
            
            subplot(no_cats1,no_bands,(c1-1)*no_bands+(no_bands+1-b))
            
            plot(band_freqs,reshape(spec_stats(band_indices{b},c1,:,s),band_width,no_cats2))
            
            hold on
            
            plot(band_freqs,reshape(spec_stats(band_indices{b},c1,:,s),band_width,no_cats2)+reshape(spec_stats(band_indices{b},c1,:,3),band_width,no_cats2),':')
            
            plot(band_freqs,reshape(spec_stats(band_indices{b},c1,:,s),band_width,no_cats2)-reshape(spec_stats(band_indices{b},c1,:,3),band_width,no_cats2),':')
            
            set(gca,'XTick',band_ticks,'XTickLabel',band_labels)
            
            xlim([band_ticks(1) band_ticks(end)])
            
            if b==no_bands && c1==1
                
                legend(long_cat2_labels,'Location','BestOutside')
                
            end
            
            if b==1
                
                ylabel(cat1)
                
            end
            
            if c1==1
                
                if b==ceil(no_bands/2)
                    
                    if ~isempty(band_names)
                        
                        title({Title,[long_stat_labels{s},' for ',char(long_cat1_labels{c1})],band_names{b}})
                        
                    else
                        
                        title({Title,[long_stat_labels{s},' for ',char(long_cat1_labels{c1})]})
                        
                    end
                    
                else
                    
                    title(band_names{b})
                    
                    % title({Title,['Median for ',cat1]})
                    
                end
                
            end
            
        end
        
        saveas((s-1)*(no_cats1+2)+c1,[name,'_',cat1,'_',stat_labels{s},'.fig'])
        
        set((s-1)*(no_cats1+2)+c1,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
        
        print((s-1)*(no_cats1+2)+c1,'-dpdf',[name,'_',cat1,'_',stat_labels{s},'.pdf'])
        
    end
    
end

for s=1:no_stats
    
    saveas((s-1)*(no_cats1+2)+no_cats1+1,[name,'_',stat_labels{s},'.fig'])
    
    set((s-1)*(no_cats1+2)+no_cats1+1,'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
    
    print((s-1)*(no_cats1+2)+no_cats1+1,'-dpdf',[name,'_',stat_labels{s},'.pdf'])
    
    saveas(s*(no_cats1+2),[name,'_',stat_labels{s},'_line.fig'])
    
    set(s*(no_cats1+2),'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0 0 1 1])
    
    print(s*(no_cats1+2),'-dpdf',[name,'_',stat_labels{s},'_line.pdf'])
    
end