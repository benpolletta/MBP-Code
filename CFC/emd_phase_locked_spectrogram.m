function emd_phase_locked_spectrogram(mode_for_phase,P,A,F,no_unwraps,sampling_freq,units,filename)

[datalength,nomodes]=size(A);

Pmod=mod(P(:,mode_for_phase),2*pi*no_unwraps)/pi;
freq=[min(F(:,mode_for_phase)) mean(F(:,mode_for_phase)) max(F(:,mode_for_phase))];

A=A(:,1:mode_for_phase-1);
maxA=max(max(A));
cmap=jet(1000);
Acolors=max(round(1000*A/maxA),1);

figure()
whitebg(cmap(1,:))

for i=1:datalength
    for j=1:mode_for_phase-1;
        plot(Pmod(i),F(i,j),'.','color',cmap(Acolors(i,j),:))
        hold on
    end
end

ticks=0:8:64;
colorbar('YTick',ticks,'YTickLabel',maxA*ticks/64)
xlabel(['Phase of Mode ',num2str(mode_for_phase),' (\pi)'])

if nargin>3    
    title(['Spectrogram Locked to Phase of Mode ',num2str(mode_for_phase),', Frequency ',num2str(freq(2)),' (',num2str(freq(1)),' to ',num2str(freq(3)),') ',char(units)])
    ylabel(['Frequency (',char(units),')'])
else
    title(['Spectrogram Locked to Phase of Mode ',num2str(mode_for_phase),', Frequency ',num2str(freq(2)),' (',num2str(freq(1)),' to ',num2str(freq(3)),')'])
    ylabel(['Frequency'])
end

if nargin>4
    saveas(gcf,[filename,'_emd_spectrogram_on_mode',num2str(mode_for_phase),'.fig'])
end

hold off
