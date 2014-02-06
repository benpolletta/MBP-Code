function fft_inv_entropy_plotter_Jan(MI,filename,A_bands,P_bands,tit_le,y_label,units,save_flag)

[~,band_cols]=size(A_bands);
if band_cols==3
    A_bands=A_bands(:,2);
    P_bands=P_bands(:,2);
end

[noamps,nophases]=size(MI);

figure();
imagesc(MI);
axis xy
colorbar;

if ~isempty(tit_le)
    title(tit_le)
else
    title('Inverse Entropy for Phase-Amplitude Curve')
end

if nargin>4
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel({y_label;['Amplitude-Modulated (',char(units),')']});
else
    xlabel('Phase-Modulating');
    ylabel({y_label;'Amplitude-Modulated'});
end

if nargin>2
%     for i=1:noamps
%         A_labels{i}=num2str(A_bands(i));
%     end
%     for i=1:nophases
%         P_labels{i}=num2str(P_bands(i));
%     end
    set(gca,'XTick',[0.5:5:(nophases+.5)],'YTick',[0.5:5:(noamps+.5)],'XTickLabel',P_bands(1:5:nophases),'YTickLabel',A_bands(1:5:noamps));
end

if save_flag==1
    saveas(gcf,[filename,'_ie.fig']);
end
