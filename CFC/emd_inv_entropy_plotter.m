function emd_inv_entropy_plotter(MI,filename,A_bands,P_bands,units,dirname)

[noamps,nophases]=size(MI);

MI=fliplr(triu(MI,1));
P_bands=flipud(P_bands);

figure();
colorplot(MI);
axis ij;
title('Inverse Entropy for Phase-Amplitude Curve')

if nargin>4
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel(['Amplitude-Modulated (',char(units),')']);
else
    xlabel('Phase-Modulating');
    ylabel('Amplitude-Modulated');
end

if nargin>2
    for i=1:noamps
        A_labels{i}=num2str(A_bands(i,2));
    end
    for i=1:nophases
        P_labels{i}=num2str(P_bands(i,2));
    end
    set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
end

if nargin>5
    saveas(gcf,[dirname,'\',filename,'_emd_inv_entropy.fig']);
elseif nargin>1
    saveas(gcf,[filename,'_emd_inv_entropy.fig']);
end