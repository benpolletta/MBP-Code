function Percent_MI=emd_inv_entropy_plot_pMI(MI,F,x_lims,x_bins,y_lims,y_bins,spacing,units,filename)

spacing=char(spacing);

% x_lims and y_lims are vector containing the limits of the plot. x_bins
% and y_bins are scalar arguments giving the number of bins.

Percent_MI=zeros(y_bins,x_bins);

[signal_length,nomodes]=size(F);

x_bands=makebands(x_bins,x_lims(1),x_lims(2),spacing);
x_bins_low=x_bands(:,1); x_bin_centers=x_bands(:,2); x_bins_high=x_bands(:,3);

y_bands=makebands(y_bins,y_lims(1),y_lims(2),spacing);
y_bins_low=y_bands(:,1); y_bin_centers=y_bands(:,2); y_bins_high=y_bands(:,3);

MIsum=sum(MI,2);

for i=1:nomodes-1
    if MIsum(i)~=0
        for k=1:y_bins
            amp_locs=find(y_bins_low(k)<=F(:,i) & F(:,i)<y_bins_high(k));
            for j=i+1:nomodes
                mi=MI(i,j);
                if mi~=0
                    phase_freqs=F(amp_locs,j);
                    for l=1:x_bins
                        phase_locs=find(x_bins_low(l)<=phase_freqs & phase_freqs<x_bins_high(l));
                        Percent_MI(k,l)=Percent_MI(k,l)+mi*length(phase_locs)/signal_length;
                    end
                end
            end
        end
    end
end

Percent_MI=100*Percent_MI/sum(MIsum);

figure();

colorplot(Percent_MI)
title('Percent Thresholded Inverse Entropy')

for m=1:x_bins
    xlabels{m}=num2str(x_bin_centers(m));
end
for n=1:y_bins
    ylabels{n}=num2str(y_bin_centers(n));
end
set(gca,'XTick',[1.5:(x_bins+1.5)],'YTick',[1.5:(y_bins+1.5)],'XTickLabel',xlabels,'YTickLabel',ylabels);
axis xy

if nargin>7
    xlabel(['Phase-Modulating Frequency (',units,')'])
    ylabel(['Amplitude-Modulated Frequency (',units,')'])
else
    xlabel(['Phase-Modulating Frequency'])
    ylabel(['Amplitude-Modulated Frequency'])
end

if nargin>8
    saveas(gcf,[filename,'_inv_entropy_pMI.fig'])
    fid=fopen([filename,'_inv_entropy_pMI.txt'],'w');
    token='';
    for i=1:x_bins
        token=[token,'%f\t'];
    end
    token=[token,'%f\n'];
    fprintf(fid,token,[NaN y_bin_centers'; x_bin_centers Percent_MI]');
end
fclose('all')