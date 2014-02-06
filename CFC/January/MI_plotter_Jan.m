function MI_plotter_Jan(MI,filename,A_bands,P_bands,fig_title,units)

[~,band_cols]=size(A_bands);
if band_cols==3
    A_bands=A_bands(:,2);
    P_bands=P_bands(:,2);
end

[noamps,nophases]=size(MI);

figure();
imagesc(MI);
colorbar
axis xy

if nargin>4
    title(char(fig_title))
else
    title('Modulation Index')
end

if nargin>5
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel(['Amplitude-Modulated (',char(units),')']);
else
    xlabel('Phase-Modulating');
    ylabel('Amplitude-Modulated');
end

if nargin>2
    
    for i=1:noamps
        A_labels{i}=num2str(A_bands(i));
    end
    
    for i=1:nophases
        P_labels{i}=num2str(P_bands(i));
    end
    
    set(gca,'XTick',[1:(nophases+1)],'YTick',[1:(noamps+1)],'XTickLabel',P_labels,'YTickLabel',A_labels);

end

saveas(gcf,[filename,'.fig']);
