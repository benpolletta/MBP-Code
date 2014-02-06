function fft_inv_entropy_plotter(MI,filename,A_bands,P_bands,units)

[noamps,nophases]=size(MI);

figure();
colorplot(MI);
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

    Abandslabel=['a_',num2str(length(A_bands)),'_from_',num2str(A_bands(1,1)),'_to_',num2str(A_bands(end,end))];
    Pbandslabel=['p_',num2str(length(P_bands)),'_from_',num2str(P_bands(1,1)),'_to_',num2str(P_bands(end,end))];
    bandslabel=[Abandslabel,'_v_',Pbandslabel];
end

if nargin>1
    if length([filename,'_',bandslabel,'_inv_entropy.fig'])<=32
        saveas(gcf,[filename,'_',bandslabel,'_inv_entropy.fig']);
    elseif length([filename,'_ie.fig'])<=32
        saveas(gcf,[filename,'_ie.fig']);
    else
        saveas(gcf,[filename(1:24),'_avp.fig'])
    end
end