function [times,max_bands,H]=scn_days_emd

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

bands_lo=makebands(20,.5,24,'log');
bands_lo=bands_lo(:,2);
bands_hi=makebands(20,2,24*6,'log');
bands_hi=bands_hi(:,2);

for i=1:20
    A_labels{i}=num2str(bands_hi(i));
    P_labels{i}=num2str(bands_lo(i));
end

protocols={'DD';'LD'};

max_bands=zeros(19,2,3,2);
max_bands(:,:,:,:)=nan;

max_pMI_bands=zeros(19,2,2);
max_pMI_bands(:,:,:)=nan;

for j=1:2

    filenames=textread([protocols{j},'_days.hht.list'],'%s%*[^\n]');
    filenum=length(filenames);

    for k=1:filenum

        MI=[]; Percent_MI=[];

        tic;

        [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),Percent_MI]=CFC_April(char(filenames(k)),24*60*6,3,20,100,.05,.05,[.5 24],20,[2 24*6],20,'log','perday',dirnames);

        times(k,j)=toc;

        close('all');
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
   
    fid=fopen(['avg_pMI_',protocols{j},'.txt'],'w')
    [r,c,junk]=size(avgpMI(:,:,:));
    format='';
    for i=1:c-1
        format=[format,'%f\t'];
    end
    format=[format,'%f\n'];
    fprintf(fid,format,reshape(avgpMI(:,:,:),r,c)');

    fid1=fopen(['max_pMI_bands_',protocols{j},'.txt'],'w')
    fprintf(fid1,'%f\t%f\n',reshape(max_pMI_bands(:,j,:),19,2)')

    fid2=fopen(['max_bands_hi_',protocols{j},'.txt'],'w')
    fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
    fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,1),19,3)')

    fid3=fopen(['max_bands_lo_',protocols{j},'.txt'],'w')
    fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
    fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,2),19,3)')

    fid4=fopen(['emd_times_',protocols{j},'.txt'],'w')
    fprintf(fid4,'%f\n',times(:,j))
    
    figure()
    colorplot(avgpMI(:,:,:))
    title(['Mean Percent MI, ',num2str(protocols{j})],'FontSize',30)
    axis xy
    set(gca,'XTick',[1.5:21.5],'YTick',[1.5:21.5],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
    xlabel('Phase-Modulating Frequency (day^{-1})','FontSize',20)
    ylabel('Amplitude-Modulated Frequency (day^{-1})','FontSize',20)
    saveas(gcf,['avg_pMI_',protocols{j},'.fig'])

    figure()
    hist(max_pMI_bands(:,j,1),bands_hi)
    title(['Histogram of Max. Amplitude Bin for ',graph_titles{4},', ',num2str(protocols{j})])
    xlabel('Center Frequency (day^{-1})')
    saveas(gcf,['hist_',graph_labels{4},'_hi_bin_',protocols{j},'.fig'])

    figure()
    hist(max_pMI_bands(:,j,2),bands_lo)
    title(['Histogram of Max. Phase Bin for ',graph_titles{4},', ',num2str(protocols{j})])
    xlabel('Center Frequency (day^{-1})')
    saveas(gcf,['hist_',graph_labels{4},'_lo_bin_',protocols{j},'.fig'])

    fclose('all')
end

for l=1:3

    figure(l)
    subplot(2,1,1)
    boxplot(max_bands(:,:,l,1))
    title(['Mean\pm S.D. of Amp. Freq. for Max. ',graph_titles{l}])
    set(gca,'XTickLabel',protocols)
    xlabel('Protocol')
    ylabel(['Frequency of Max. ',graph_titles{l},' (day^{-1})'])
    %         saveas(gcf,['mean_',graph_labels{l},'_bin_hi_',protocols{j},'.fig'])

    subplot(2,1,2)
    boxplot(max_bands(:,:,l,2))
    title(['Mean\pm S.D. of Phase Freq. for Max. ',graph_titles{l}])
    set(gca,'XTickLabel',protocols)
    xlabel('Protocol')
    ylabel(['Frequency of Max. ',graph_titles{l},' (day^{-1})'])
    %         saveas(gcf,['mean_',graph_labels{l},'_bin_lo_',protocols{j},'.fig'])
    saveas(gcf,['mean_',graph_labels{l},'_bin_',protocols{j},'.fig'])

end

figure()
subplot(2,1,1)
H=hist(max_pMI_bands(:,:,1),bands_hi);
colorplot(H)
axis xy
title(['Histogram of Max. Amplitude Bin for ',graph_titles{4}])
set(gca,'YTick',1.5:21.5,'YTickLabel',A_labels,'XTick',1.5:3.5,'XTickLabel',protocols)
ylabel('Center Frequency (day^{-1})')
xlabel('Protocol')
%     saveas(gcf,['hist_',graph_labels{4},'_hi_bin_',protocols{j},'.fig'])

subplot(2,1,2)
H=hist(max_pMI_bands(:,:,2),bands_lo);
colorplot(H)
axis xy
title(['Histogram of Max. Phase Bin for ',graph_titles{4}])
set(gca,'YTick',1.5:21.5,'YTickLabel',P_labels,'XTick',1.5:3.5,'XTickLabel',protocols)
ylabel('Center Frequency (day^{-1})')
xlabel('Protocol')
%     saveas(gcf,['hist_',graph_labels{4},'_lo_bin_',protocols{j},'.fig'])
saveas(gcf,['hist_',graph_labels{4},'_bin_',protocols{j},'.fig'])

figure()
boxplot(times)
title('Boxplot of Elapsed Times for EMD Analysis')
set(gca,'XTick',1.5:6.5,'XTickLabel',protocols)
xlabel('Protocol')
saveas(gcf,['emd_scn_days_times_boxplot.fig'])