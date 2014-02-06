function Percent_MI=emd_inv_entropy_pMI_all(MI,F,resolution,spacing,units,filename)

[noamps,nophases]=size(MI);

if noamps==nophases
    nomodes=noamps;
else
    display('MI must be square.')
end

MI=triu(MI,1);
maxMI=max(max(MI));

xmin=mean(mean(F));
ymin=mean(mean(F));
xmax=xmin;
ymax=ymin;

for i=1:nomodes-1
    for j=i+1:nomodes
        if MI(i,j)~=0
            xmin=min(min(F(:,j)),xmin);
            xmax=max(max(F(:,j)),xmax);
            ymin=min(min(F(:,i)),ymin);
            ymax=max(max(F(:,i)),ymax);
        end
    end
end

Percent_MI=zeros(resolution,resolution);
x_bin_centers=zeros(resolution,1);
y_bin_centers=zeros(resolution,1);

if xmin~=xmax
    
    [signal_length,nomodes]=size(F);

    x_bins=makebands(resolution,xmin,xmax,spacing);
    x_bins_low=x_bins(:,1); x_bin_centers=x_bins(:,2); x_bins_high=x_bins(:,3);

    y_bins=makebands(resolution,ymin,ymax,spacing);
    y_bins_low=y_bins(:,1); y_bin_centers=y_bins(:,2); y_bins_high=y_bins(:,3);

    MIsum=sum(MI,2);

    for i=1:nomodes-1
        if MIsum(i)~=0
            for k=1:resolution
                amp_locs=find(y_bins_low(k)<=F(:,i) & F(:,i)<y_bins_high(k));
                for j=i+1:nomodes
                    mi=MI(i,j);
                    if mi~=0
                        phase_freqs=F(amp_locs,j);
                        for l=1:resolution
                            phase_locs=find(x_bins_low(l)<=phase_freqs & phase_freqs<x_bins_high(l));
                            Percent_MI(k,l)=Percent_MI(k,l)+mi*length(phase_locs)/signal_length;
                        end
                    end
                end
            end
        end
    end

    Percent_MI=100*Percent_MI/sum(MIsum);

end
    
figure();

colorplot(Percent_MI)

title('Percent Thresholded Inverse Entropy')

if resolution<=15
    for m=1:resolution
        xlabels{m}=num2str(x_bin_centers(m));
        ylabels{m}=num2str(y_bin_centers(m));
    end
    set(gca,'XTick',[1.5:(resolution+1.5)],'YTick',[1.5:(resolution+1.5)],'XTickLabel',xlabels,'YTickLabel',ylabels);
elseif resolution<=150
    tickspacing=floor(resolution/10);
    noticks=floor(resolution/tickspacing);
    for m=1:noticks
        ticks(m)=(m-1)*tickspacing+1;
        xlabels{m}=num2str(x_bin_centers((m-1)*tickspacing+1));
        ylabels{m}=num2str(y_bin_centers((m-1)*tickspacing+1));
    end
    set(gca,'XTick',ticks,'XTickLabel',xlabels,'YTick',ticks,'YTickLabel',ylabels);
else
    xticks=[xmin xmax];
    yticks=[ymin ymax];
    set(gca,'XTick',[1.5 resolution+1.5],'XTickLabel',xticks,'YTick',[1.5 resolution+1.5],'YTickLabel',yticks);
end
axis xy

if nargin>4
    xlabel(['Phase-Modulating Frequency (',units,')'])
    ylabel(['Amplitude-Modulated Frequency (',units,')'])
else
    xlabel(['Phase-Modulating Frequency'])
    ylabel(['Amplitude-Modulated Frequency'])
end

if nargin>5
    saveas(gcf,[filename,'_inv_entropy_pMI_all.fig'])
    fid=fopen([filename,'_inv_entropy_pMI_all.txt'],'w');
    token='';
    for i=1:resolution
        token=[token,'%f\t'];
    end
    token=[token,'%f\n'];
    fprintf(fid,token,[NaN y_bin_centers'; x_bin_centers Percent_MI]');
end
fclose('all')
