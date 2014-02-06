function fbank_bMI_plotter_missing_MI(challenge_list,challenge_fig_list,challenge_name,challenge_descriptor,challenge_params,challenge_labels)

listnames=textread(challenge_list,'%s%*[^\n]');
listnum=length(listnames);

figlistnames=textread(challenge_fig_list,'%s%*[^\n]');
figlistnum=length(figlistnames);

if listnum~=figlistnum
    display('Number of file lists and number of figure lists must be equal.')
end

max_bMI_bands=zeros(50,listnum,2);

bands_lo=3.2:.4:8.8;
bands_hi=23:6:107;

for i=1:listnum
    
    listname=char(listnames(i));
    figlistname=char(figlistnames(i));
    
    [All_bMI,avg_bMI]=batch_bMI_missing_MI(listname,figlistname,4,'FFT\Filter_Bank_Divisor_2\MI_Data_Plots','FFT\Filter_Bank_Divisor_2\HAF_Data_Plots',[3 9],15,[20 110],15,2,'Hz');
    
    [noamps,nophases,filenum]=size(All_bMI);
    
    for j=1:filenum
        
        bMI=All_bMI(:,:,j);
        maxbMI=max(max(bMI));
        if maxbMI>0
            [r,c]=find(bMI==maxbMI);
            max_bMI_bands(j,i,1)=mean(bands_hi(r));
            max_bMI_bands(j,i,2)=mean(bands_lo(c));
        else 
            max_bMI_bands(j,i,1)=nan;
            max_bMI_bands(j,i,2)=nan;
        end
    
    end
    
end

H(:,:,1)=hist(max_bMI_bands(:,:,1),bands_hi);
    
fid5=fopen([challenge_name,'_hists_hi_bMI.txt'],'w');
fprintf(fid5,'%f\t%f\t%f\t%f\t%f\n',[challenge_params; H(:,:,1)]');

H(:,:,2)=hist(max_bMI_bands(:,:,2),bands_lo);

fid6=fopen([challenge_name,'_hists_lo_bMI.txt'],'w');
fprintf(fid6,'%f\t%f\t%f\t%f\t%f\n',[challenge_params; H(:,:,2)]');

figure()
subplot(2,1,1)
colorplot(H(:,:,1))
caxis([0 50])
colorbar
axis xy
title(['Histogram of Bin for Max. Binned MI'],'FontSize',30)
set(gca,'YTick',1.5:16.5,'YTickLabel',bands_hi,'XTick',1.5:6.5,'XTickLabel',challenge_labels,'FontSize',16)
ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

subplot(2,1,2)
colorplot(H(:,:,2))
caxis([0 50])
colorbar
axis xy
set(gca,'YTick',1.5:16.5,'YTickLabel',bands_lo,'XTick',1.5:6.5,'XTickLabel',challenge_labels,'FontSize',16)
ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
xlabel(challenge_descriptor,'FontSize',24)
saveas(gcf,['hist_bMI_bin_',challenge_name,'.fig'])

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
saveas(gcf,['hist_bMI_',challenge_name,'_minimal.fig'])

fclose('all')