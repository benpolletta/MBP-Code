function Percent_ZS=emd_inv_entropy_plot_pZS(ZS,F,x_lims,x_bins,y_lims,y_bins,units,filename)

% x_lims and y_lims are vector containing the limits of the plot. x_bins
% and y_bins are scalar arguments giving the number of bins.

Percent_ZS=zeros(y_bins,x_bins);

[signal_length,nomodes]=size(F);

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
%         points{index}=[cycle_pieces total_phase_frac*ZS(i,j)];
%     end
% end

ZSsum=sum(ZS,2);

for i=1:nomodes-1
    if ZSsum(i)~=0
        for k=1:y_bins
            amp_locs=find(y_bins_low(k)<=F(:,i) & F(:,i)<y_bins_high(k));
            for j=i+1:nomodes
                zs=ZS(i,j);
                if zs~=0
                    phase_freqs=F(amp_locs,j);
                    for l=1:x_bins
                        phase_locs=find(x_bins_low(l)<=phase_freqs & phase_freqs<x_bins_high(l));
                        Percent_ZS(k,l)=Percent_ZS(k,l)+zs*length(phase_locs)/signal_length;
                    end
                end
            end
        end
    end
end

Percent_ZS=100*Percent_ZS/sum(ZSsum);

figure();

colorplot(Percent_ZS)
title('Percent Thresholded Inverse Entropy z-Score')

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
    saveas(gcf,[filename,'_inv_entropy_pZS.fig'])
    fid=fopen([filename,'_inv_entropy_pZS.txt'],'w');
    token='';
    for i=1:x_bins
        token=[token,'%f\t'];
    end
    token=[token,'%f\n'];
    fprintf(fid,token,[NaN x_bin_centers; y_bin_centers' Percent_ZS]');
end
fclose('all')

% function Percent_ZS=emd_inv_entropy_plot_block(ZS,F,P,cycle_bounds,cycle_freqs,x_lims,x_bins,y_lims,y_bins,units,filename)