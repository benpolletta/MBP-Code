function [times,max_bands]=r_trend_fft

dirnames{1}='FFT\HAF_Data_Plots';
dirnames{2}='FFT\AVP_Data';
dirnames{3}='FFT\AVP_Plots';
dirnames{4}='FFT\MI_Data_Plots';
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

for j=1:10
    
    filenames=textread(['t_level_',num2str(.2*j),'.list'],'%s%*[^\n]');
    filenum=length(filenames);

    for k=1:filenum
        
        tic;
        
        [bands_lo,bands_hi,MI(:,:,k,1),MI(:,:,k,2),MI(:,:,k,3),MI(:,:,k,4)]=CFC_April_fft(char(filenames(k)),600,20,100,.05,.05,[3 9],15,[20 110],15,'Hz',dirnames);
        
        times(k,j)=toc;
        
        close('all')
        fclose('all')
    end
    
    fid3=fopen(['fft_times_t_level_',num2str(.2*j),'.txt'],'w')
    fprintf(fid3,'%f\n',times(:,j))
    
    for p=1:15
        A_labels{p}=num2str(bands_hi(p,2));
        P_labels{p}=num2str(bands_lo(p,2));
    end

    avgMI=mean(MI,3);

    for m=1:50
        for n=1:4
            mi=MI(:,:,m,n);
            maxmi=max(max(mi));
            [r,c]=find(mi==maxmi);
            max_bands(m,n,1,j)=mean(bands_hi(r,2));
            max_bands(m,n,2,j)=mean(bands_lo(c,2));
        end
    end

    fid1=fopen(['hist_hi_bin_t_level_',num2str(.2*j),'.fig'],'w')
    fid2=fopen(['hist_lo_bin_t_level_',num2str(.2*j),'.fig'],'w')
    
    for l=1:4
        figure() 
        colorplot(avgMI(:,:,:,l))
        title(['Mean ',graph_titles{l},' (50 Realizations), White Noise Level ',num2str(.2*j)])
        axis xy
        set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels)
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,['avg_',graph_labels{l},'_t_level_',num2str(.2*j),'.fig'])
        
        fid=fopen(['avg_',graph_labels{l},'_t_level_',num2str(.2*j),'.txt'],'w')
        [r,c,junk,junk_jr]=size(avgMI(:,:,:,l));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgMI(:,:,:,l),r,c)');
        
        figure()
        hist(max_bands(:,l,1,j),bands_hi(:,2))
        title(['Histogram of Max. ',graph_titles{l},' Amplitude Bin, White Noise Level ',num2str(.2*j)])
        set(gca,'XTick',1.5:15.5,'XTickLabel',A_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,['hist_',graph_labels{l},'_hi_bin_t_level_',num2str(.2*j),'.fig'])
        
        figure()
        hist(max_bands(:,l,2,j),bands_lo(:,2))
        title(['Histogram of Max. ',graph_titles{l},' Phase Bin, White Noise Level ',num2str(.2*j)])
        set(gca,'XTick',1.5:15.5,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,['hist_',graph_labels{l},'_lo_bin_t_level_',num2str(.2*j),'.fig'])
        
        if l~=4
            fprintf(fid1,'%s\t',graph_labels{l})
            fprintf(fid2,'%s\t',graph_labels{l})
        else
            fprintf(fid1,'%s\n',graph_labels{l})
            fprintf(fid2,'%s\n',graph_labels{l})
        end
    end
   
    fprintf(fid1,'%f\t%f\t%f\t%f\n',max_bands(:,:,1,j)')
    fprintf(fid2,'%f\t%f\t%f\t%f\n',max_bands(:,:,2,j)')
end

for l=1:4
    figure()
    H=hist(reshape(max_bands(:,l,1,:),50,10),bands_hi(:,2));
    colorplot(H)
    axis xy
    title(['Histogram of Max. Amplitude Bin for ',graph_titles{4}])
    set(gca,'YTick',1.5:15.5,'YTickLabel',A_labels,'XTick',1.5:10.5,'XTickLabel',t_level_labels)
    ylabel('Center Frequency (Hz)')
    xlabel('Random Trend Intensity')
    saveas(gcf,['hist_',graph_labels{4},'_hi_bin_r_trend.fig'])

    figure()
    H=hist(reshape(max_bands(:,l,2,:),50,10),bands_lo(:,2));
    colorplot(H)
    axis xy
    title(['Histogram of Max. Phase Bin for ',graph_titles{4}])
    set(gca,'YTick',1.5:15.5,'YTickLabel',P_labels,'XTick',1.5:10.5,'XTickLabel',t_level_labels)
    ylabel('Center Frequency (Hz)')
    xlabel('Random Trend Intensity')
    saveas(gcf,['hist_',graph_labels{4},'_lo_bin_r_trend.fig'])
end

figure()
boxplot(times)
title('Boxplot of Elapsed Times for FFT Analysis')
set(gca,'XTickLabel',t_level_labels)
xlabel('White Noise Level')
saveas(gcf,'fft_boxplot_times_r_trend.fig')