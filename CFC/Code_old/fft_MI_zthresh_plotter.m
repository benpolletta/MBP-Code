function fft_MI_zthresh_plotter(filter_dir,challenge_list,challenge_name,challenge_descriptor,challenge_params,challenge_labels)

MI_dir=['FFT\',filter_dir,'\MI_Data_Plots'];
agg_dir=['FFT\',filter_dir,'\Aggregate'];

listnames=textread(challenge_list,'%s%*[^\n]');
listnum=length(listnames);

present_dir=pwd;

max_bMI_bands=zeros(50,listnum,2);

bands_lo=3.2:.4:8.8;
bands_hi=23:6:107;

MI_format='%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n';
H_format='';
for i=1:length(challenge_params)-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

for i=1:listnum
    
    listname=char(listnames(i));

    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);

    All_MI_zthresh=zeros(15,15,filenum);

    for j=1:filenum
        
        filename=char(filenames(j));
        filename=filename(1:end-4);
        
        cd (char(MI_dir))
        
%         MIfilename=[filename,'_a_15_from_20_to_110_v_p_15_from_3_to_9_inv_entropy.txt'];
        MIfilename=[filename,'_inv_entropy.txt'];
        Zfilename=[filename,'_inv_entropy_zscores.txt'];

        MI=load(MIfilename);
        MI=MI(2:end,2:end);
        [r,c]=size(MI);

        fid=fopen([filename,'_inv_entropy.txt'],'w');
        fprintf(fid,MI_format,[NaN bands_lo; bands_hi' MI]');
        fclose(fid);
        
        ZS=load(Zfilename);
        ZS=ZS(2:end,2:end);

        MI_zthresh=MI;
        z_threshold=.05/nchoosek(c,2);
        MI_zthresh(normcdf(ZS,0,1)<1-z_threshold)=0;
        
        All_MI_zthresh(:,:,j)=MI_zthresh;

        maxMIzt=max(max(MI_zthresh));
        [r,c]=find(MI_zthresh==maxMIzt);
        max_MI_zt_bands(j,i,1)=mean(bands_hi(r));
        max_MI_zt_bands(j,i,2)=mean(bands_lo(c));
        
        fid1=fopen([filename,'_inv_entropy_zthresh.txt'],'w');
        fprintf(fid1,MI_format,[NaN bands_lo; bands_hi' MI_zthresh]');
        fclose(fid1);

        colorplot(MI_zthresh)
        axis xy
        title(['MI Values with z-Score Higher than ',num2str(z_threshold)],'FontSize',30)
        set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',bands_lo,'YTickLabel',bands_hi,'FontSize',16)
        xlabel(['Phase-Modulating Freq. (Hz)'],'FontSize',24)
        ylabel(['Amplitude-Modulated Freq. (Hz)'],'FontSize',24)
        saveas(gcf,[filename,'_inv_entropy_zthresh.fig'])
        
        cd (present_dir);
        
    end

    cd (agg_dir);
    
    avg_MI_zthresh=mean(All_MI_zthresh,3);
    
    fid=fopen([listname,'_avg_MI_zthresh.txt'],'w');
    fprintf(fid,MI_format,[NaN bands_lo; bands_hi' avg_MI_zthresh]');
    fclose(fid);
    
    figure()
    colorplot(avg_MI_zthresh)
    axis xy
    title(['Mean Thresholded MI for ',challenge_descriptor,' ',char(challenge_labels(i))],'FontSize',30)
    set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',bands_lo,'YTickLabel',bands_hi,'FontSize',16)
    xlabel(['Phase-Modulating Freq. (Hz)'],'FontSize',24)
    ylabel(['Amplitude-Modulated Freq. (Hz)'],'FontSize',24)
    saveas(gcf,[listname,'_avg_MI_zthresh.fig'])
    
    figure()
    colorplot(avg_MI_zthresh)
    axis xy
    set(gca,'XTick',[1.5 8.5 15.5],'YTick',[1.5 8.5 15.5],'XTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'YTickLabel',[bands_hi(1) bands_hi(8) bands_hi(15)],'FontSize',16)
    saveas(gcf,[listname,'_avg_MI_zthresh_minimal.fig'])
    
    fclose('all')
    
    cd (present_dir);
    
end

cd (agg_dir);

H(:,:,1)=hist(max_MI_zt_bands(:,:,1),bands_hi);
    
fid5=fopen([challenge_name,'_hists_hi_MI_zthresh.txt'],'w');
fprintf(fid5,H_format,[challenge_params; H(:,:,1)]');

H(:,:,2)=hist(max_MI_zt_bands(:,:,2),bands_lo);

fid6=fopen([challenge_name,'_hists_lo_MI_zthresh.txt'],'w');
fprintf(fid6,H_format,[challenge_params; H(:,:,2)]');

figure()
subplot(2,1,1)
colorplot(H(:,:,1))
axis xy
title(['Histogram of Bin for Max. Thresholded MI'],'FontSize',30)
set(gca,'YTick',1.5:16.5,'YTickLabel',bands_hi,'XTick',1.5:6.5,'XTickLabel',challenge_labels,'FontSize',16)
ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

subplot(2,1,2)
colorplot(H(:,:,2))
axis xy
set(gca,'YTick',1.5:16.5,'YTickLabel',bands_lo,'XTick',1.5:6.5,'XTickLabel',challenge_labels,'FontSize',16)
ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
xlabel(challenge_descriptor,'FontSize',24)
saveas(gcf,['hist_MI_zthresh_bin_',challenge_name,'.fig'])

figure()
colormap('gray')
subplot(2,1,1)
colorplot(H(:,:,1))
caxis([0 50])
colorbar
axis xy
set(gca,'YTick',[1.5 8.5 15.5],'YTickLabel',[bands_hi(1) bands_hi(8) bands_hi(15)],'XTick',[],'FontSize',16)
    
subplot(2,1,2)
colorplot(H(:,:,2))
caxis([0 50])
colorbar
axis xy
if listnum==5
    set(gca,'YTick',[1.5 8.5 15.5],'YTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'XTick',[1.5 3.5 5.5],'XTickLabel',[challenge_labels(1) challenge_labels(3) challenge_labels(5)],'FontSize',16)
elseif listnum==10
    set(gca,'YTick',[1.5 8.5 15.5],'YTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'XTick',[1.5 4.5 7.5 10.5],'XTickLabel',[challenge_labels(1) challenge_labels(4) challenge_labels(7) challenge_labels(10)],'FontSize',16)
end
saveas(gcf,['hist_MI_zthresh_bin_',challenge_name,'_minimal.fig'])

fclose('all')

cd (present_dir);