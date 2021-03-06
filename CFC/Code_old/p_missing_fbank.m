function [times,max_bands]=asym_emd

graph_titles{1}='MI';
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

divisors=[2 2.09];

for m=1:2
    
    divisor=divisors(m);
    div_folder=['Filter_Bank_Divisor_',num2str(divisor)];
    
    dirnames{1}=['FFT\',div_folder,'\HAF_Data_Plots'];
    dirnames{2}=['FFT\',div_folder,'\AVP_Data'];
    dirnames{3}=['FFT\',div_folder,'\AVP_Plots'];
    dirnames{4}=['FFT\',div_folder,'\MI_Data_Plots'];
    for i=1:4
        mkdir (dirnames{i});
    end

    present_dir=pwd;

    max_bands=zeros(50,5,3,2);
    max_pMI_bands=zeros(50,2,5);
    H=zeros(15,5,2);
    
    for j=1:5

        p_missing_labels{j}=num2str(5*j);

        filenames=textread(['p_missing_',num2str(.05*j),'.list'],'%s%*[^\n]');
        filenum=length(filenames);

        for k=1:filenum

            MI=[]; pMI=[];

            tic;

            [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),Percent_MI]=CFC_April_fbank(char(filenames(k)),600,5,20,100,.05,.05,[3 9],15,[20 110],15,0,.9,divisor,'Hz',dirnames);

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
            max_pMI_bands(k,1,j)=mean(bands_hi(r));
            max_pMI_bands(k,2,j)=mean(bands_lo(c));

        end

        avgpMI=mean(pMI,3);

        mkdir (['FFT\',div_folder,'\Aggregate'])
        cd (['FFT\',div_folder,'\Aggregate'])
        
        fid=fopen(['avg_pMI_p_missing',num2str(5*j),'.txt'],'w')
        [r,c,junk]=size(avgpMI(:,:,:));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgpMI(:,:,:),r,c)');

        fid1=fopen(['max_pMI_bands_p_missing',num2str(5*j),'.txt'],'w')
        fprintf(fid1,'%f\t%f\n',max_pMI_bands(:,:,j)')

        fid2=fopen(['max_bands_hi_p_missing',num2str(5*j),'.txt'],'w')
        fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
        fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,1),50,3)')

        fid3=fopen(['max_bands_lo_p_missing',num2str(5*j),'.txt'],'w')
        fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
        fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,j,:,2),50,3)')

        fid4=fopen(['emd_times_p_missing',num2str(5*j),'.txt'],'w')
        fprintf(fid4,'%f\n',times(:,j))

        figure()
        colorplot(avgpMI(:,:,:))
        title(['Mean Percent MI, ',num2str(5*j),' Percent Data Missing'],'FontSize',30)
        axis xy
        set(gca,'XTick',[1.5:(15+1.5)],'YTick',[1.5:(15+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,['avg_pMI_p_missing',num2str(5*j),'.fig'])

        figure()
        subplot(2,1,1)
        hist(max_pMI_bands(:,1,j),bands_hi)
        title(['Histogram of Max. Bin for ',graph_titles{4},', ',num2str(5*j),' Percent Data Missing'],'FontSize',30)
        xlabel('Amp. Bin Center Freq. (Hz)')
        
        subplot(2,1,2)
        hist(max_pMI_bands(:,2,j),bands_lo)
        xlabel('Phase Bin Center Freq. (Hz)')
        saveas(gcf,['hist_',graph_labels{4},'_bin_p_missing',num2str(5*j),'.fig'])

        cd (present_dir)
        
        fclose('all')
    end

    cd (['FFT\',div_folder,'\Aggregate'])
    
    for l=1:3

        figure()
        subplot(2,1,1)
        boxplot(max_bands(:,:,l,1))
        title(['Boxplot of Bin for Max. ',graph_titles{l}],'FontSize',30)
        set(gca,'XTickLabel',p_missing_labels,'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

        subplot(2,1,2)
        boxplot(max_bands(:,:,l,2))
        set(gca,'XTickLabel',p_missing_labels,'FontSize',16)
        ylabel({'Phase Bin';'Center Freq.'},'FontSize',24)
        xlabel('Percent Data Missing','Fontsize',24)
        saveas(gcf,['boxplot_',graph_labels{l},'_noise.fig'])

    end
    
    H(:,:,1)=hist(reshape(max_pMI_bands(:,1,:),50,5),bands_hi);
    
    fid5=fopen('asym_hists_hi_pMI.txt','w');
    fprintf(fid5,'%f\t%f\t%f\t%f\t%f\n',[5*[1:5]; H(:,:,1)]');
    
    H(:,:,2)=hist(reshape(max_pMI_bands(:,2,:),50,5),bands_lo);
    
    fid6=fopen('asym_hists_lo_pMI.txt','w');
    fprintf(fid6,'%f\t%f\t%f\t%f\t%f\n',[5*[1:5]; H(:,:,2)]');
    
    figure()
    subplot(2,1,1)
    colorplot(H(:,:,1))
    axis xy
    title(['Histogram of Max. Bin for ',graph_titles{4}],'FontSize',30)
    set(gca,'YTick',1.5:16.5,'YTickLabel',A_labels,'XTick',1.5:6.5,'XTickLabel',p_missing_labels,'FontSize',16)
    ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

    subplot(2,1,2)
    colorplot(H(:,:,2))
    axis xy
    set(gca,'YTick',1.5:16.5,'YTickLabel',P_labels,'XTick',1.5:6.5,'XTickLabel',p_missing_labels,'FontSize',16)
    ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
    xlabel('Percent Data Missing','FontSize',24)
    saveas(gcf,['hist_',graph_labels{4},'_bin_noise.fig'])

    figure()
    boxplot(times)
    title('Boxplot of Elapsed Times for EMD Analysis')
    set(gca,'XTickLabel',p_missing_labels)
    xlabel('Percent Data Missing')
    saveas(gcf,'fbank_times_boxplot.fig')

    fclose('all')
    
    cd (present_dir);
    
end