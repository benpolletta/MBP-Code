f=500*[1:length(all_avg_fft)]/length(all_avg_fft);

bands=[4 200; 4 12; 20 110; 120 200];
[no_bands,~]=size(bands);

stops=[58 62; 117 123; 179 181];
[no_stops,~]=size(stops);

for s=1:no_stops
    
    all_avg_fft(:,f>=stops(s,1) & f<=stops(s,2))=nan;
    all_se_fft(:,f>=stops(s,1) & f<=stops(s,2))=nan;

end

avg_linestyles={'k','m','c'};
se_linestyles={'-k','-m','-c'};

drug_indices=[4 1 2 3];

for b=1:no_bands

    figure()
        
    band_indices=find(f>=bands(b,1) & f<=bands(b,2));
    
    mean_max=nanmax(nanmax(all_avg_fft(:,band_indices)));
    mean_min=nanmin(nanmin(all_avg_fft(:,band_indices)));
    
    se_max=nanmax(nanmax(all_se_fft(:,band_indices)));
    
    fft_max=mean_max+se_max;
    fft_min=mean_min-se_max;
    
    for i=1:4
        
        subplot(4,1,i)
        
        for j=1:3
            
            loglog(f(band_indices), all_avg_fft((drug_indices(i)-1)*3+j,band_indices),avg_linestyles{j},'LineWidth',2);
                        
            hold on
            
        end
        
        if i==1
    
            legend({'Preinjection','1 to 4 Hrs. Postinjection','5 to 8 Hrs. Postinjection'})
        
        end
            
        for j=1:3
        
            loglog(f(band_indices), all_avg_fft((drug_indices(i)-1)*3+j,band_indices)+all_se_fft((drug_indices(i)-1)*3+j,band_indices),se_linestyles{j});
            loglog(f(band_indices), all_avg_fft((drug_indices(i)-1)*3+j,band_indices)-all_se_fft((drug_indices(i)-1)*3+j,band_indices),se_linestyles{j});
            
        end
        
        xlim(bands(b,:))
        ylim([fft_min fft_max])
        set(gca,'FontSize',20)
        
    end
    
end

subplot(4,1,1)

legend('','','')