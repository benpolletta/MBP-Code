function emd_spectrogram(A,F,f_bins,sampling_freq,units,filename)

[datalength,nomodes]=size(A);

S=zeros(datalength,f_bins);

lowest_freq=min(min(F));
highest_freq=max(max(F));
f_bin_width=(highest_freq-lowest_freq)/f_bins;
f_bin_starts=lowest_freq:f_bin_width:highest_freq-f_bin_width;
f_bin_centers=f_bin_starts+f_bin_width/2;
f_bin_ends=f_bin_starts+f_bin_width;

t=1:datalength;
t=t/sampling_freq;

for i=1:datalength
    for j=1:f_bins
        S(i,j)=sum(A(i,F(i,:)<f_bin_ends(j) & F(i,:)>=f_bin_starts(j)));
    end
end

h=pcolor(t,f_bin_centers,S');
set(h,'EdgeColor','none')
colorbar
title('Spectrogram from Empirical Mode Decomposition')
% set(gca,'YTick',1.5:(f_bins+.5),'YTickLabel',f_bin_centers)
xlabel('Time')

if nargin>4
    ylabel(['Frequency (',char(units),')'])
else
    ylabel(['Frequency'])
end

if nargin>5
    saveas(gcf,[filename,'_emd_spectrogram.fig'])
end

hold off
