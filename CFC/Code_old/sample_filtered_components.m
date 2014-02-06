whitebg('w')

[raw_filename,raw_pathname]=uigetfile('*rep47.txt','Choose Raw File To Plot');

t=[1:1800]/600;

[He_low_filename,He_low_pathname]=uigetfile('*modes.txt','Choose Low Modes');

low_modes=load([He_low_pathname,He_low_filename]);
[no_low_modes,junk]=size(low_modes);

[He_hi_filename,He_hi_pathname]=uigetfile('*modes.txt','Choose High Modes');

hi_modes=load([He_hi_pathname,He_hi_filename]);
[no_hi_modes,junk]=size(hi_modes);

fft_bands_lo=makebands(15,3,9,'linear');
fft_bands_hi=makebands(15,20,110,'linear');

for i=1:no_low_modes
    subplot(no_low_modes+no_hi_modes,1,i)
    plot(t,low_modes(1:1800,i),'k')
    box off
    ylabel({num2str(fft_bands_lo(i,2));'Hz'})
    set(gca,'XTickLabel','','YTickLabel','')
end

for i=1:no_hi_modes
    subplot(no_low_modes+no_hi_modes,1,no_low_modes+i)
    plot(t,hi_modes(1:1800,i),'k')
    box off
    set(gca,'YLabel',{num2str(fft_bands_hi(i,2));'Hz'},'XTickLabel','','YTickLabel','')
end

saveas(gcf,[dirname,filename(1:end-4),'.fig'])