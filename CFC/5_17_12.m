figure(); 
subplot(11,3,2); 
plot(t,signal,'k');
set(gca,'YLim',[-2.75,2.75],'XTick',0:5,'YTickLabel','','XTickLabel','')
box; 
ylabel('Signal','FontSize',16); 
title('Fourier Bandpass Filter (Butterworth, 3rd Order)','FontSize',30); 
for j=1:3 
    for i=1:10 
        subplot(11,3,3*(i-1)+j+3); 
        plot(t,sigs(:,i+(j-1)*10),'k'); 
        set(gca,'YLim',[-1 1],'YTickLabel','','XTickLabel',''); 
        ylabel([num2str(bands(i+(j-1)*10,2)),' Hz'],'FontSize',16); 
        box; 
    end
end

figure(); 
subplot(8,1,1); 
plot(t,signal,'k'); 
set(gca,'YLim',[-2.75,2.75],'XTick',0:5,'YTickLabel','','XTickLabel','')
box; 
ylabel('Signal','FontSize',18); 
title('Empirical Mode Decomposition','FontSize',30); 

for i=1:7; 
    subplot(8,1,i+1); 
    plot(t,hht(i,:),'k');
    set(gca,'YLim',[-2.75,2.75],'XTick',0:5,'YTickLabel','','XTickLabel','')
    box; 
    ylabel(['Mode ',num2str(i)],'FontSize',18); 
end

for i=1:6
    for j=2:7
        set(subplot(7,7,(i-1)*7+j),'YTickLabel','','XTickLabel','')
        ylabel('')
        xlabel('')
    end
end

for i=1:6
    set(subplot(7,7,(i-1)*7+1),'YTickLabel','','XTickLabel','')
    xlabel('')
end

for i=1:6
    set(subplot(7,7,(i-1)*7+1),'YTickLabel','','XTickLabel','')
    xlabel('')
end

for j=2:7
    set(subplot(7,7,42+j),'YTickLabel','','XTickLabel','')
    ylabel('')
end