function Binned_MI=inv_entropy_plot_bMI(MI,F_lo,F_hi,x_lims,x_bins,y_lims,y_bins,spacing,saveopt,units,filename)

spacing=char(spacing);

% x_lims and y_lims are vector containing the limits of the plot. x_bins
% and y_bins are scalar arguments giving the number of bins.

Binned_MI=zeros(y_bins,x_bins);

[signal_length,junk]=size(F_lo);
[noamps,nophases]=size(MI);

x_bands=makebands(x_bins,x_lims(1),x_lims(2),spacing);
x_bins_low=x_bands(:,1); x_bin_centers=x_bands(:,2); x_bins_high=x_bands(:,3);

y_bands=makebands(y_bins,y_lims(1),y_lims(2),spacing);
y_bins_low=y_bands(:,1); y_bin_centers=y_bands(:,2); y_bins_high=y_bands(:,3);

MIsum=sum(MI,2);

for i=1:noamps
    if MIsum(i)~=0
        for k=1:y_bins
            amp_locs=find(y_bins_low(k)<=F_hi(:,i) & F_hi(:,i)<y_bins_high(k));
            for j=1:nophases
                mi=MI(i,j);
                if mi~=0
                    phase_freqs=F_lo(amp_locs,j);
                    for l=1:x_bins
                        phase_locs=find(x_bins_low(l)<=phase_freqs & phase_freqs<x_bins_high(l));
                        Binned_MI(k,l)=Binned_MI(k,l)+mi*length(phase_locs)/signal_length;
                    end
                end
            end
        end
    end
end

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

    fclose('all')
    
end