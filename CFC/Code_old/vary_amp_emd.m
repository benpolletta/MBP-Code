function [times,max_bands,H]=vary_amp_emd

dirnames{1}='HAF_Data_Plots';
dirnames{2}='AVP_Data';
dirnames{3}='AVP_Plots';
dirnames{4}='MI_Data_Plots';
for i=1:4
    mkdir (dirnames{i});
end

graph_titles{1}='Modulation Index';
graph_titles{2}='MI p-Value';
graph_titles{3}='MI z-Score';
graph_titles{4}='Percent MI';

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

    percent_bw_labels{j}=[num2str(65*(1-j*.05)),' - ',num2str(65*(1+j*.05))];

    filenames=textread(['65pm',num2str(65*j*.05),'.hht.list'],'%s%*[^\n]');
    filenum=length(filenames);

    for k=1:filenum

        MI=[]; pMI=[];

        tic;

        [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),Percent_MI]=CFC_April(char(filenames(k)),600,5,20,100,.05,.05,[3 9],15,[20 110],15,'linear','Hz',dirnames);

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

    fid=fopen(['avg_pMI_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.txt'],'w')
    [r,c,junk]=size(avgpMI(:,:,:));
    format='';
    for i=1:c-1
        format=[format,'%f\t'];
    end
    format=[format,'%f\n'];
    fprintf(fid,format,reshape(avgpMI(:,:,:),r,c)');

    fid1=fopen(['max_pMI_bands_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.txt'],'w')
    fprintf(fid1,'%f\t%f\n',reshape(max_pMI_bands(:,j,:),50,2)')

    fid2=fopen(['max_bands_hi_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.txt'],'w')
    fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
    fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,1),50,3)')

    fid3=fopen(['max_bands_lo_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.txt'],'w')
    fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
    fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,2),50,3)')

    fid4=fopen(['emd_times_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.txt'],'w')
    fprintf(fid4,'%f\n',times(:,j))

    fclose('all')
        
    figure()
    colorplot(avgpMI(:,:,:))
    title(['Mean Percent Modulation Index, Slow Osc. from ',num2str(65*(1-j*.05)),'-',num2str(65*(1+j*.05)),'Hz'],'FontSize',30)
    axis xy
    set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
    xlabel('Phase-Modulating Frequency (Hz)','FontSize',24)
    ylabel('Amplitude-Modulated Frequency (Hz)','FontSize',24)
    saveas(gcf,['avg_pMI_65pm',num2str(65*j*.05),'.fig'])

    figure()
    hist(max_pMI_bands(:,j,1),bands_hi)
    title(['Histogram of Max. Amplitude Bin for ',graph_titles{4},', Low Freq. Osc. from ',num2str(65*(1-j*.05)),'-',num2str(65*(1+j*.05)),'Hz'])
    set(gca,'XTick',bands_hi,'XTickLabel',A_labels)
    xlabel('Center Frequency (Hz)')
    saveas(gcf,['hist_',graph_labels{4},'_hi_bin_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.fig'])

    figure()
    hist(max_pMI_bands(:,j,2),bands_lo)
    title(['Histogram of Max. Phase Bin for ',graph_titles{4},', Low Freq. Osc. from ',num2str(65*(1-j*.05)),'-',num2str(65*(1+j*.05)),'Hz'])
    set(gca,'XTick',bands_lo,'XTickLabel',P_labels)
    xlabel('Center Frequency (Hz)')
    saveas(gcf,['hist_',graph_labels{4},'_lo_bin_vary_amp_',num2str(65),'pm',num2str(65*j*.05),'.fig'])
end

for l=1:3

    figure()
    subplot(2,1,1)
    errorbar(mean(max_bands(:,:,l,1)),std(max_bands(:,:,l,1)))
    title(['Mean\pm S.D. of Frequency for Max. ',graph_titles{l}],'FontSize',30)
    set(gca,'XTickLabel',percent_bw_labels,'FontSize',16)
%     xlabel('Frequency Range, Slow Oscillation')
    ylabel(['Amp. Freq. of Max. ',graph_titles{l},' (Hz)'],'FontSize',24)
    %         saveas(gcf,['mean_',graph_labels{l},'_bin_hi_vary_amp_',num2str(65),'.fig'])

    subplot(2,1,2)
    errorbar(mean(max_bands(:,:,l,2)),std(max_bands(:,:,l,2)))
%     title(['Mean\pm S.D. of Phase Frequency for Max. ',graph_titles{l}])
    set(gca,'XTickLabel',percent_bw_labels,'FontSize',16)
    xlabel('Frequency Range, Slow Oscillation','FontSize',24)
    ylabel(['Phase Freq. of Max. ',graph_titles{l},' (Hz)'],'FontSize',24)
    %         saveas(gcf,['mean_',graph_labels{l},'_bin_lo_vary_amp_',num2str(65),'.fig'])
    saveas(gcf,['mean_',graph_labels{l},'_bin_vary_amp.fig'])

end

H(:,:,1)=hist(max_pMI_bands(:,:,1),bands_hi);

fid5=fopen('vary_amp_hists_hi_pMI.txt','w');
fprintf(fid5,'%f\t%f\t%f\t%f\t%f\n',H(:,:,1)');

H(:,:,2)=hist(max_pMI_bands(:,:,2),bands_lo);

fid6=fopen('vary_amp_hists_lo_pMI.txt','w');
fprintf(fid6,'%f\t%f\t%f\t%f\t%f\n',H(:,:,2)');

figure()
subplot(2,1,1)
colorplot(H(:,:,1))
axis xy
title(['Histogram of Max. Bin for ',graph_titles{4}],'FontSize',30)
set(gca,'YTick',1.5:15.5,'YTickLabel',A_labels,'XTick',1.5:11.5,'XTickLabel',percent_bw_labels,'FontSize',16)
ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)
% xlabel('Frequency Range, Slow Oscillation')
%     saveas(gcf,['hist_',graph_labels{4},'_hi_bin_vary_amp_',num2str(65),'.fig'])

subplot(2,1,2)
colorplot(H(:,:,2))
axis xy
% title(['Histogram of Max. Phase Bin for ',graph_titles{4}],'FontSize',30)
set(gca,'YTick',1.5:15.5,'YTickLabel',P_labels,'XTick',1.5:11.5,'XTickLabel',percent_bw_labels,'FontSize',16)
ylabel({'Phase Bin';'Center Freq. (Hz)'})
xlabel('Frequency Range, Slow Oscillation','FontSize',24)
%     saveas(gcf,['hist_',graph_labels{4},'_lo_bin_vary_amp_',num2str(65),'.fig'])
saveas(gcf,['hist_',graph_labels{4},'_bin_vary_amp.fig'])

figure()
boxplot(times)
title('Boxplot of Elapsed Times for EMD Analysis')
set(gca,'XTick',1.5:10.5,'XTickLabel',percent_bw_labels)
xlabel('Frequency Range, Slow Oscillation')
saveas(gcf,['emd_vary_amp_times_boxplot.fig'])