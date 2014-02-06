function emd_spectrogram(A,F,sampling_freq,units,filename)

[datalength,nomodes]=size(A);

t=1:datalength;
t=t/sampling_freq;

maxA=max(max(A));
cmap=jet(1000);
Acolors=max(round(1000*A/maxA),1);

figure()
whitebg(cmap(1,:))

for i=1:datalength
    for j=1:nomodes
        plot(t(i),F(i,j),'.','color',cmap(Acolors(i,j),:))
        hold on
    end
end

ticks=0:8:64;
colorbar('YTick',ticks,'YTickLabel',maxA*ticks/64)
title('Spectrogram from Empirical Mode Decomposition')
xlabel('Time')

if nargin>3
    ylabel(['Frequency (',char(units),')'])
else
    ylabel(['Frequency'])
end

if nargin>4
    saveas(gcf,[filename,'_emd_spectrogram.fig'])
end

hold off
