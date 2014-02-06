function Percent_MI=emd_inv_entropy_plot_pMI(MI,F_hi,F_lo,x_lims,x_bins,y_lims,y_bins,units,filename)

% x_lims and y_lims are vector containing the limits of the plot. x_bins
% and y_bins are scalar arguments giving the number of bins.

Percent_MI=zeros(y_bins,x_bins);

[signal_length,nophases]=size(F_lo);
[signal_length,noamps]=size(F_hi);

x_bin_width=(x_lims(2)-x_lims(1))/x_bins;
x_bins_low=x_lims(1):x_bin_width:(x_lims(2)-x_bin_width);
x_bins_high=x_bins_low+x_bin_width;
x_bin_centers=(x_bins_high+x_bins_low)/2;

y_bin_width=(y_lims(2)-y_lims(1))/y_bins;
y_bins_low=y_lims(1):y_bin_width:(y_lims(2)-y_bin_width);
y_bins_high=y_bins_low+y_bin_width;
y_bin_centers=(y_bins_high+y_bins_low)/2;

% for i=1:noamps-1
%     for j=i+1:nophases
%         index=j-i+(i-1)*(nophases-i/2);
%         total_phase=P(end,j)-P(1,j)+P(end,i)-P(1,i);
%         lo_cycle_bounds=cycle_bounds{j};
%         hi_cycle_bounds=cycle_bounds{i};
%         all_cycle_bounds=[lo_cycle_bounds; hi_cycle_bounds];
%         [cycle_pieces,sort_indices]=sort(all_cycle_bounds);
%         lo_cycle_freqs=cycle_freqs{j};
%         hi_cycle_freqs=cycle_freqs{i};
%         cycle_pieces=collate(lo_cycle_bounds,hi_cycle_bounds);
%         lo_phase_change=P(cycle_pieces(:,1),j)-P(cycle_pieces(:,2),j);
%         hi_phase_change=P(cycle_pieces(:,1),i)-P(cycle_pieces(:,2),i);
%         total_phase_frac=(lo_phase_change+hi_phase_change)/total_phase;
%         points{index}=[cycle_pieces total_phase_frac*MI(i,j)];
%     end
% end

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

if nargin>6
    xlabel(['Phase-Modulating Frequency (',units,')'])
    ylabel(['Amplitude-Modulated Frequency (',units,')'])
else
    xlabel(['Phase-Modulating Frequency'])
    ylabel(['Amplitude-Modulated Frequency'])
end

if nargin>7
    saveas(gcf,[filename,'_inv_entropy_pMI.fig'])
    fid=fopen([filename,'_inv_entropy_pMI.txt'],'w');
    token='';
    for i=1:x_bins
        token=[token,'%f\t'];
    end
    token=[token,'%f\n'];
    fprintf(fid,token,[NaN x_bin_centers; y_bin_centers' Percent_MI]');
end
fclose('all')

% function Percent_MI=emd_inv_entropy_plot_block(MI,F,P,cycle_bounds,cycle_freqs,x_lims,x_bins,y_lims,y_bins,units,filename)