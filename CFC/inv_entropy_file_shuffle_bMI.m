function [MI_stats]=inv_entropy_file_shuffle_bMI(noshufs,nobins,threshold,file_list_lo,file_list_hi,freq_list_lo,freq_list_hi,nophases,noamps,datalength,x_lims,x_bins,y_lims,y_bins);

stat_labels={'pt_cutoffs','z_means','z_stds','lz_means','lz_stds','skews'};

MI_stats=zeros(noamps,nophases,5);
MIvals=zeros(noshufs,noamps,nophases);
bMIvals=zeros(y_bins,x_bins,noshufs);

filenames_lo=textread(char(file_list_lo),'%s');
filenum_lo=length(filenames_lo);

freqnames_lo=textread(char(freq_list_lo),'%s');
freqnum_lo=length(freqnames_lo);

filenames_hi=textread(char(file_list_hi),'%s');
filenum_hi=length(filenames_hi);

freqnames_hi=textread(char(freq_list_hi),'%s');
freqnum_hi=length(freqnames_hi);

modes_lo=zeros(datalength,nophases,filenum_lo);
for i=1:filenum_lo
    modes_lo(:,:,i)=load(char(filenames_lo(i)));
end

modes_hi=zeros(datalength,noamps,filenum_hi);
for j=1:filenum_hi
    modes_hi(:,:,j)=load(char(filenames_hi(j)));
end

freqs_lo=zeros(datalength,nophases,filenum_lo);
for i=1:filenum_lo
    freqs_lo(:,:,i)=load(char(freqnames_lo(i)));
end

freqs_hi=zeros(datalength,noamps,filenum_hi);
for j=1:filenum_hi
    freqs_hi(:,:,j)=load(char(freqnames_hi(j)));
end

lo_indices=cumsum(ones(1,nophases));
hi_indices=cumsum(ones(1,noamps));

shuffle_indices_lo=rand(noshufs,nophases);
shuffle_indices_lo=ceil(shuffle_indices_lo*filenum_lo);

shuffle_indices_hi=rand(noshufs,noamps);
shuffle_indices_hi=ceil(shuffle_indices_hi*filenum_hi);

shuffle_name=[file_list_lo(1:end-5),'_',file_list_hi(1:end-5),'_',num2str(noshufs),'_p_',num2str(threshold)];

fid=fopen([shuffle_name,'.txt'],'w')
fid_bMI=fopen([shuffle_name,'_bMI.txt'],'w')

params=[];
for i=1:(nophases+noamps)
    params=[params,'%d\t'];
end

for i=1:(x_bins*y_bins-1)
    bMI_params=[params,'%f\t'];
end
bMI_params=[params,'%f\n'];
    
for i=1:(nophases*noamps-1)
    params=[params,'%f\t'];
end
params=[params, '%f\n'];

for i=1:noshufs
    
    A_shuf=zeros(datalength,noamps);
    
    for j=1:noamps
        A_shuf(:,j)=modes_hi(:,j,shuffle_indices_hi(i,j));
    end
    
    P_shuf=zeros(datalength,nophases);

    for k=1:nophases
        P_shuf(:,k)=modes_lo(:,k,shuffle_indices_lo(i,k));
    end
    
    AF_shuf=zeros(datalength,noamps);
    
    for j=1:noamps
        AF_shuf(:,j)=freqs_hi(:,j,shuffle_indices_hi(i,j));
    end
    
    PF_shuf=zeros(datalength,nophases);

    for k=1:nophases
        PF_shuf(:,k)=freqs_lo(:,k,shuffle_indices_lo(i,k));
    end
    
    [bincenters,M_shuf,L_shuf]=amp_v_phase_no_save(nobins,A_shuf,P_shuf);
    MI=inv_entropy_no_save(M_shuf);
    MIvals(i,:,:)=MI;
    
    Binned_MI=inv_entropy_plot_bMI(MI,PF_shuf,AF_shuf,x_lims,x_bins,y_lims,y_bins,'linear',0);
    bMIvals(:,:,i)=Binned_MI;
    
    fprintf(fid,params,[shuffle_indices_hi(i,:) shuffle_indices_lo(i,:) reshape(MI,1,nophases*noamps)]);
    fprintf(fid_bMI,bMI_params,[shuffle_indices_hi(i,:) shuffle_indices_lo(i,:), reshape(Binned_MI,1,x_bins*y_bins)]);
    
end

fclose(fid);

MI_stats(:,:,1)=quantile(MIvals,threshold);

MI_stats(:,:,2)=mean(MIvals);
MI_stats(:,:,3)=std(MIvals);

MI_stats(:,:,4)=mean(log(MIvals));
MI_stats(:,:,5)=std(log(MIvals));

% Computing skewness.

for i=1:noshufs
    Mn(i,:,:)=MI_stats(:,:,2);
end

multiplier=sqrt(noshufs-1)/(sqrt(noshufs)*(noshufs-2));
MI_stats(:,:,6)=multiplier*sum((MIvals-Mn).^3)./(std(MIvals,1).^(1.5));

% Saving stats.

params=[];
for i=1:nophases-1
    params=[params,'%f\t'];
end
params=[params, '%f\n'];

for i=1:6
    
    fid=fopen([shuffle_name,'_',stat_labels{i},'.txt'],'w');
    fprintf(fid,params,MI_stats(:,:,i)');
    fclose(fid);
    
end

% Plotting and saving histograms.

figure();

for k=1:nophases
    for j=1:noamps
        subplot(noamps,nophases,noamps*(k-1)+j);
        hist(MIvals(:,j,k))
    end
end

saveas(gcf,[shuffle_name,'_hist.fig'])

figure();

for k=1:nophases
    for j=1:noamps
        subplot(noamps,nophases,noamps*(k-1)+j);
        hist(log(MIvals(:,j,k)))
    end
end

saveas(gcf,[shuffle_name,'_ln_hist.fig'])

figure();

colorplot(mean(bMIvals,3))
title(['Mean Binned Modulation Index ',num2str(noshufs),' Shuffles'])
set(gca,'XTick',[1.5:(x_bins+1.5)],'YTick',[1.5:(y_bins+1.5)],'XTickLabel',[x_lims(1)+diff(x_lims)/(2*x_bins):diff(x_lims)/x_bins:x_lims(2)-diff(x_lims)/(2*x_bins)],'YTickLabel',[y_lims(1)+diff(y_lims)/(2*y_bins):diff(y_lims)/y_bins:y_lims(2)-diff(y_lims)/(2*y_bins)]);
axis xy
xlabel(['Phase-Modulating Frequency'])
ylabel(['Amplitude-Modulated Frequency'])
saveas(gcf,[shuffle_name,'_avg_bMI.fig'])

figure();

colorplot(std(bMIvals,3))
title(['S.D. Binned Modulation Index ',num2str(noshufs),' Shuffles'])
set(gca,'XTick',[1.5:(x_bins+1.5)],'YTick',[1.5:(y_bins+1.5)],'XTickLabel',[x_lims(1):diff(x_lims)/x_bins:x_lims(2)],'YTickLabel',[y_lims(1):diff(y_lims)/y_bins:y_lims(2)]);
axis xy
xlabel(['Phase-Modulating Frequency'])
ylabel(['Amplitude-Modulated Frequency'])
saveas(gcf,[shuffle_name,'_sd_bMI.fig'])