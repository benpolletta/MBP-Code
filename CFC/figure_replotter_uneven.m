function [max_MI_all,MI_all]=figure_replotter(numbers,rows,cols,bands_lo,bands_hi,labels)

nophases=length(bands_lo);
noamps=length(bands_hi);

MI_all=nan(noamps,nophases,rows*cols);

for i=1:length(numbers)
    
    figure(numbers(i))
    axxes=findall(gcf,'Type','axes');
    Chilluns=get(axxes(end),'Children');
    MI=get(Chilluns,'CData');
    MI=MI(1:end-1,1:end-1);
    [na,np]=size(MI);
    
    MI_all(1:na,1:np,i)=MI;
    max_MI_all(i)=max(max(MI));
    
end
    
max_MI=max(max(max(MI_all(:,:,:))));
min_MI=min(min(min(MI_all(:,:,:))));
    
figure()

for i=1:length(numbers)
    
    subplot(rows,cols,i)
    if i==1
        imagesc(MI_all(1:16,1:16,i))
    else
        imagesc(MI_all(:,:,i))
    end
    axis xy
    caxis([min_MI max_MI])
    title(char(labels(i)))
    if i==1
        set(gca,'XTick',1:2:nophases+1,'XTickLabel',bands_lo(2:4:end))
        set(gca,'YTick',1:noamps+1,'YTickLabel',bands_hi(2:2:end))
    else
        set(gca,'XTick',1:4:nophases+1,'XTickLabel',bands_lo(1:4:end))
        set(gca,'YTick',1:2:noamps+1,'YTickLabel',bands_hi(1:2:end))
    end
    if mod(i,cols)==1
        ylabel('Amp.-Giving Freq. (Hz)')
    elseif mod(i,cols)==0
        colorbar
    end
    if ceil(i/cols)==rows
        xlabel('Phase-Giving Freq. (Hz)')
    end
    
end
    
    