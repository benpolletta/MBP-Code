function [times,max_bands,max_pMI_bands]=r_trend_emd

dirnames{1}='HAF_Data_Plots';
dirnames{2}='AVP_Data';
dirnames{3}='AVP_Plots';
dirnames{4}='MI_Data_Plots';
for i=1:4
    mkdir (dirnames{i});
end

graph_titles{1}='Modulation Index';
graph_titles{2}='Modulation Index p-Value';
graph_titles{3}='Modulation Index z-Score';
graph_titles{4}='Percent Modulation Index';

graph_labels{1}='MI';
graph_labels{2}='PV';
graph_labels{3}='ZS';
graph_labels{4}='PMI';

bands_lo=3.2:.4:8.8;
bands_hi=23:6:107;

for i=1:15
    A_labels{i}=num2str(bands_hi(i));
    P_labels{i}=num2str(bands_lo(i));
end

for j=1:10
    
    t_level_labels{j}=num2str(.2*j);
    
    filenames=textread(['r_trend_',num2str(.2*j),'.hht.list'],'%s%*[^\n]');
    filenum=length(filenames);

    for k=1:filenum
        
        MI=[]; pMI=[];
        
        tic;
        
        [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),Percent_MI]=CFC_April(char(filenames(k)),600,20,100,.05,.05,[3 9],15,[20 110],15,'Hz',dirnames);
        
        times(k,j)=toc;
        
        close('all')
        fclose('all');
        
        pMI(:,:,k)=Percent_MI;
        
        for l=1:3
        
            mi=MI(:,:,l);
            maxMI=max(max(mi));
            [r,c]=find(mi==maxMI);
            max_bands(k,j,l,1)=mean(bands(r,2));
            max_bands(k,j,l,2)=mean(bands(c,2));
        
        end
        
        pmi=Percent_MI;
        maxpmi=max(max(pmi));
        [r,c]=find(pmi==maxpmi);
        max_pMI_bands(k,j,1)=mean(bands_hi(r));
        max_pMI_bands(k,j,2)=mean(bands_lo(c));
        
    end

    avgpMI=mean(pMI,3);
    
    figure()
    colorplot(avgpMI(:,:,:))
    title(['Mean Percent Modulation Index (50 Realizations), Random Trend Level ',num2str(.2*j)])
    axis xy
    set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels)
    xlabel('Phase-Modulating Frequency (Hz)')
    ylabel('Amplitude-Modulated Frequency (Hz)')
    saveas(gcf,['avg_pMI_t_level_',num2str(.2*j),'.fig'])

    fid=fopen(['avg_pMI_t_level_',num2str(.2*j),'.txt'],'w')
    [r,c,junk]=size(avgpMI(:,:,:));
    format='';
    for i=1:c-1
        format=[format,'%f\t'];
    end
    format=[format,'%f\n'];
    fprintf(fid,format,reshape(avgpMI(:,:,:),r,c)');
    
    figure()
    hist(max_pMI_bands(:,j,1),bands_hi)
    title(['Histogram of Max. Amplitude Bin for ',graph_titles{4},', Random Trend Level ',num2str(.2*j)])
    set(gca,'XTick',1.5:10.5,'XTickLabel',P_labels)
    xlabel('Center Frequency (Hz)')
    saveas(gcf,['hist_',graph_labels{4},'_hi_bin_t_level_',num2str(.2*j),'.fig'])

    figure()
    hist(max_pMI_bands(:,j,2),bands_lo)
    title(['Histogram of Max. Phase Bin for ',graph_titles{4},', Random Trend Level ',num2str(.2*j)])
    set(gca,'XTick',1.5:10.5,'XTickLabel',P_labels)
    xlabel('Center Frequency (Hz)')
    saveas(gcf,['hist_',graph_labels{4},'_lo_bin_t_level_',num2str(.2*j),'.fig'])

    fid1=fopen(['max_pMI_bands_t_level_',num2str(.2*j),'.txt'],'w')
    fprintf(fid1,'%f\t%f\n',max_pMI_bands')
    
    fid2=fopen(['max_bands_hi_t_level_',num2str(.2*j),'.txt'],'w')
    fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
    fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,1),50,3)')
    
    fid3=fopen(['max_bands_lo_t_level_',num2str(.2*j),'.txt'],'w')
    fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
    fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,2),50,3)')
    
    fid4=fopen(['emd_times_t_level_',num2str(.2*j),'.txt'],'w')
    fprintf(fid4,'%f\n',times(:,j))
    
    fclose('all')
end

for l=1:3
        
    figure(l)
    subplot(2,1,1)
    errorbar(mean(max_bands(:,:,l,1)),std(max_bands(:,:,l,1)))
    title(['Mean \pm S.D. of Amplitude Frequency for Max. ',graph_titles{l}])
    set(gca,'XTickLabel',t_level_labels)
    xlabel('Random Trend Level')
    ylabel(['Frequency of Max. ',graph_titles{l},' (Hz)'])
%     saveas(gcf,['boxplot_r_trend_hi_freq_',graph_labels{l},'.fig'])
    
%     figure()
    subplot(2,1,2)
    errorbar(mean(max_bands(:,:,l,2)),std(max_bands(:,:,l,2)))
    title(['Mean \pm S.D. of Phase Frequency Bin for Max. ',graph_titles{l}])
    set(gca,'XTickLabel',t_level_labels)
    xlabel('Random Trend Level')
    ylabel(['Frequency of Max. ',graph_titles{l},' (Hz)'])
%     saveas(gcf,['boxplot_r_trend_lo_freq_',graph_labels{l},'.fig'])
    saveas(gcf,['boxplot_r_trend_lo_freq_',graph_labels{l},'.fig'])
   
end

figure()
subplot(2,1,1)
H=hist(max_pMI_bands(:,:,1),bands_hi);
colorplot(H)
axis xy
title(['Histogram of Max. Amplitude Bin for ',graph_titles{4}])
set(gca,'YTick',1.5:15.5,'YTickLabel',A_labels,'XTick',1.5:10.5,'XTickLabel',t_level_labels)
ylabel('Center Frequency (Hz)')
xlabel('Random Trend Intensity')
% saveas(gcf,['hist_',graph_labels{4},'_hi_bin_r_trend.fig'])

% figure()
subplot(2,1,2)
H=hist(max_pMI_bands(:,:,2),bands_lo);
colorplot(H)
axis xy
title(['Histogram of Max. Phase Bin for ',graph_titles{4}])
set(gca,'YTick',1.5:15.5,'YTickLabel',P_labels,'XTick',1.5:10.5,'XTickLabel',t_level_labels)
ylabel('Center Frequency (Hz)')
xlabel('Random Trend Intensity')
% saveas(gcf,['hist_',graph_labels{4},'_lo_bin_r_trend.fig'])
saveas(gcf,['hist_',graph_labels{4},'_bin_r_trend.fig'])

figure()
boxplot(times)
title('Boxplot of Elapsed Times for EMD Analysis')
set(gca,'XTickLabel',t_level_labels)
xlabel('Random Trend Level')
saveas(gcf,'emd_r_trend_times_boxplot.fig')