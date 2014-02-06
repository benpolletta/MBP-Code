function Binned_MI=emd_inv_entropy_plot_bMI(MI,F,x_lims,x_bins,y_lims,y_bins,spacing,saveopt,units,filename)

spacing=char(spacing);

% x_lims and y_lims are vector containing the limits of the plot. x_bins
% and y_bins are scalar arguments giving the number of bins.

[signal_length,junk]=size(F);
[noamps,nophases]=size(MI);

if noamps==nophases
    nomodes=noamps;
else
    display('MI must be a square matrix.')
end

Binned_MI=nan(y_bins,x_bins,nomodes,nomodes);

x_bands=makebands(x_bins,x_lims(1),x_lims(2),spacing);
x_bins_low=x_bands(:,1); x_bin_centers=x_bands(:,2); x_bins_high=x_bands(:,3);

y_bands=makebands(y_bins,y_lims(1),y_lims(2),spacing);
y_bins_low=y_bands(:,1); y_bin_centers=y_bands(:,2); y_bins_high=y_bands(:,3);

MIsum=sum_keep_nans(MI,2);

for i=1:nomodes-1
    if ~isnan(MIsum(i))
        for k=1:y_bins
            amp_locs=find(y_bins_low(k)<=F(:,i) & F(:,i)<y_bins_high(k));
            for j=i+1:nomodes
                mi=MI(i,j);
                if ~isnan(mi)
                    phase_freqs=F(amp_locs,j);
                    for l=1:x_bins
                        phase_locs=find(x_bins_low(l)<=phase_freqs & phase_freqs<x_bins_high(l));
                        Binned_MI(k,l,i,j)=mi*length(phase_locs)/signal_length;
                    end
                end
            end
        end
    end
end

Binned_MI=sum_keep_nans(sum_keep_nans(Binned_MI,4),3);

if saveopt==1

    figure();

    colorplot(Binned_MI)
    title('Binned Thresholded Inverse Entropy')

    for m=1:x_bins
        xlabels{m}=num2str(x_bin_centers(m));
    end
    for n=1:y_bins
        ylabels{n}=num2str(y_bin_centers(n));
    end
    set(gca,'XTick',[1.5:(x_bins+1.5)],'YTick',[1.5:(y_bins+1.5)],'XTickLabel',xlabels,'YTickLabel',ylabels);
    axis xy

    if nargin>8
        xlabel(['Phase-Modulating Frequency (',units,')'])
        ylabel(['Amplitude-Modulated Frequency (',units,')'])
    else
        xlabel(['Phase-Modulating Frequency'])
        ylabel(['Amplitude-Modulated Frequency'])
    end

    if nargin>9
        saveas(gcf,[filename,'_inv_entropy_bMI.fig'])
        fid=fopen([filename,'_inv_entropy_bMI.txt'],'w');
        token='';
        for i=1:x_bins
            token=[token,'%f\t'];
        end
        token=[token,'%f\n'];
        fprintf(fid,token,[NaN y_bin_centers'; x_bin_centers Binned_MI]');
    end

end
    
fclose('all')