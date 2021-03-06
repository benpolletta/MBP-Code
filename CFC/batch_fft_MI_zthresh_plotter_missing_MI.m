function batch_fft_MI_zthresh_plotter_missing_MI(filter_dir,challenge_list,challenge_fig_list,challenge_name,challenge_descriptor,challenge_params,challenge_labels)

whitebg('w')
colormap('gray')

MI_dir=['FFT\',filter_dir,'\MI_Data_Plots'];
Agg_dir=['FFT\',filter_dir,'\Aggregate'];

listnames=textread(challenge_list,'%s%*[^\n]');
listnum=length(listnames);

figlistnames=textread(challenge_fig_list,'%s%*[^\n]');
figlistnum=length(figlistnames);

if listnum~=figlistnum
    display('The number of lists and the number of figures lists must be equal.')
end

present_dir=pwd;

avg_MI_zt=zeros(15,15,listnum);
max_MI_zt_bands=zeros(50,2,listnum);

bands_lo=3.2:.4:8.8;
bands_hi=23:6:107;

MI_format='%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n';
H_format='';
for i=1:length(challenge_params)-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

for i=1:listnum
    
    datalist=char(listnames(i));
    figlist=char(figlistnames(i));

    [avg_MI_zt(:,:,i),max_MI_zt_bands(:,:,i)]=fft_MI_zthresh_plotter_missing_MI(datalist,figlist,4,MI_dir,Agg_dir,[3 9],15,[20 110],15,'linear','Hz');
    
end

cd (Agg_dir);

H(:,:,1)=hist(reshape(max_MI_zt_bands(:,1,:),50,listnum),bands_hi);
H(:,:,2)=hist(reshape(max_MI_zt_bands(:,2,:),50,listnum),bands_lo);

fid5=fopen([challenge_name,'_hists_hi_MI_zthresh.txt'],'w');
fprintf(fid5,H_format,[challenge_params; H(:,:,1)]');

fid6=fopen([challenge_name,'_hists_lo_MI_zthresh.txt'],'w');
fprintf(fid6,H_format,[challenge_params; H(:,:,2)]');

figure()
subplot(2,1,1)
colorplot(H(:,:,1))
axis xy
title(['Histogram of Bin for Max. Thresholded MI'],'FontSize',30)
set(gca,'YTick',1.5:16.5,'YTickLabel',bands_hi,'XTick',1.5:(listnum+1.5),'XTickLabel',challenge_labels,'FontSize',16)
ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

subplot(2,1,2)
colorplot(H(:,:,2))
axis xy
set(gca,'YTick',1.5:16.5,'YTickLabel',bands_lo,'XTick',1.5:(listnum+1.5),'XTickLabel',challenge_labels,'FontSize',16)
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