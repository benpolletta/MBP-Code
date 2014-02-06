function Binned_MI=inv_entropy_bMI_all_batch(MI_list,F_lo_list,F_hi_list,resolution,spacing,units,filename)

MI_names=textread(MI_list,'%s');
F_lo_names=textread(F_lo_list,'%s');
F_hi_names=textread(F_hi_list,'%s');

MI_num=length(MI_names);
if length(F_lo_names)~=MI_num | length(F_hi_names)~=MI_num
    display('The number of files in F_lo_list and F_hi_list must be the same as the number of files in MI_list.')
    return;
end

for i=1:MI_num
    
    MI_name=char(MI_names(i));
    MI=load(MI_name);
    
    MI_name=char(MI_names(i));
    MI=load(MI_name);
    
[noamps,nophases]=size(MI);

MI=triu(MI,1);
maxMI=max(max(MI));

xmin=mean(mean(F_lo));
ymin=mean(mean(F_hi));
xmax=xmin;
ymax=ymin;

for i=1:noamps-1
    for j=1:nophases
        if MI(i,j)~=0
            xmin=min(min(F_lo(:,j)),xmin);
            xmax=max(max(F_lo(:,j)),xmax);
            ymin=min(min(F_hi(:,i)),ymin);
            ymax=max(max(F_hi(:,i)),ymax);
        end
    end
end

Binned_MI=zeros(resolution,resolution);
x_bin_centers=zeros(resolution,1);
y_bin_centers=zeros(resolution,1);

if xmin~=xmax
    
    [signal_length,nomodes]=size(F_lo);

    x_bins=makebands(resolution,xmin,xmax,spacing);
    x_bins_low=x_bins(:,1); x_bin_centers=x_bins(:,2); x_bins_high=x_bins(:,3);

    y_bins=makebands(resolution,ymin,ymax,spacing);
    y_bins_low=y_bins(:,1); y_bin_centers=y_bins(:,2); y_bins_high=y_bins(:,3);

    MIsum=sum(MI,2);

    for i=1:noamps-1
        if MIsum(i)~=0
            for k=1:resolution
                amp_locs=find(y_bins_low(k)<=F_hi(:,i) & F_hi(:,i)<y_bins_high(k));
                for j=1:nophases
                    mi=MI(i,j);
                    if mi~=0
                        phase_freqs=F_lo(amp_locs,j);
                        for l=1:resolution
                            phase_locs=find(x_bins_low(l)<=phase_freqs & phase_freqs<x_bins_high(l));
                            Binned_MI(k,l)=Binned_MI(k,l)+mi*length(phase_locs)/signal_length;
                        end
                    end
                end
            end
        end
    end
    
end
    
figure();

colorplot(Binned_MI)

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

if nargin>5
    xlabel(['Phase-Modulating Frequency (',units,')'])
    ylabel(['Amplitude-Modulated Frequency (',units,')'])
else
    xlabel(['Phase-Modulating Frequency'])
    ylabel(['Amplitude-Modulated Frequency'])
end

if nargin>6
    saveas(gcf,[filename,'_inv_entropy_bMI_all'],'fig')
    fid=fopen([filename,'_inv_entropy_bMI_all.txt'],'w');
    token='';
    for i=1:resolution
        token=[token,'%f\t'];
    end
    token=[token,'%f\n'];
    fprintf(fid,token,[NaN y_bin_centers'; x_bin_centers Binned_MI]');
end
fclose('all')
