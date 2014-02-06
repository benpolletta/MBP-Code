function [MI_stats]=inv_entropy_file_shuffle(noshufs,nobins,threshold,file_list_lo,file_list_hi,nophases,noamps,datalength)

% Call this script from HAF_Data_Plots, or any directory where the amps and
% phases of the filtered components can be reached.

if threshold<.5
    threshold=1-threshold;
end

stat_labels={'pt_cutoffs','z_means','z_stds','z_cutoffs','lz_means','lz_stds','lz_cutoffs','skews'};
stat_titles={'Empirical p-Value Cutoff','Mean MI','Standard Deviation MI','Standard Normal Cutoff','Mean Log MI','Standard Deviation Log MI','Lognormal Cutoff','Skewness'};

MI_stats=zeros(noamps,nophases,5);

filenames_lo=textread(char(file_list_lo),'%s');
filenum_lo=length(filenames_lo);

filenames_hi=textread(char(file_list_hi),'%s');
filenum_hi=length(filenames_hi);

modes_lo=zeros(datalength,nophases,filenum_lo);
for i=1:filenum_lo
    modes_lo(:,:,i)=load(char(filenames_lo(i)));
end

modes_hi=zeros(datalength,noamps,filenum_hi);
for j=1:filenum_hi
    modes_hi(:,:,j)=load(char(filenames_hi(j)));
end

lo_indices=cumsum(ones(1,nophases));
hi_indices=cumsum(ones(1,noamps));

shuffle_indices_lo=rand(noshufs,nophases);
shuffle_indices_lo=ceil(shuffle_indices_lo*filenum_lo);

shuffle_indices_hi=rand(noshufs,noamps);
shuffle_indices_hi=ceil(shuffle_indices_hi*filenum_hi);

shuffle_name=[file_list_lo(1:end-5),'_',file_list_hi(1:end-5),'_',num2str(noshufs),'_p_',num2str(threshold)];

fid=fopen([shuffle_name,'.txt'],'w');

params=[];
for i=1:(nophases+noamps)
    params=[params,'%d\t'];
end
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
    
    [bincenters,M_shuf,L_shuf]=amp_v_phase_no_save(nobins,A_shuf,P_shuf);
    MI=inv_entropy_no_save(M_shuf);
    MIvals(i,:,:)=MI;
    
    fprintf(fid,params,[shuffle_indices_hi(i,:) shuffle_indices_lo(i,:) reshape(MI,1,nophases*noamps)]);

end

fclose(fid);

MI_stats(:,:,1)=quantile(MIvals,threshold);

z_means=mean(MIvals);
z_stds=std(MIvals);
MI_stats(:,:,2)=z_means;
MI_stats(:,:,3)=z_stds;
MI_stats(:,:,4)=norminv(threshold,z_means,z_stds);

lz_means=mean(log(MIvals));
lz_stds=std(log(MIvals));
MI_stats(:,:,5)=lz_means;
MI_stats(:,:,6)=lz_stds;
MI_stats(:,:,7)=exp(norminv(threshold,lz_means,lz_stds));

% Computing skewness.

for i=1:noshufs
    Mn(i,:,:)=z_means;
end

multiplier=sqrt(noshufs-1)/(sqrt(noshufs)*(noshufs-2));
MI_stats(:,:,8)=multiplier*sum((MIvals-Mn).^3)./(std(MIvals,1).^(1.5));

% Saving stats.

params=[];
for i=1:nophases-1
    params=[params,'%f\t'];
end
params=[params, '%f\n'];

for i=1:8
    
    fid=fopen([shuffle_name,'_',stat_labels{i},'.txt'],'w');
    fprintf(fid,params,MI_stats(:,:,i)');
    fclose(fid);
    
    figure()
    colorplot(MI_stats(:,:,i));
    axis xy
    title([stat_titles{i},' p = ',num2str(threshold)]);
    saveas(gcf,[shuffle_name,'_',stat_labels{i},'.fig']);
    
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