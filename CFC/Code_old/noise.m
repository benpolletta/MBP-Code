function noise

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

for j=6:10
    
    filenames=textread(['noise_',num2str(j/10),'.list'],'%s%*[^\n]');
    filenum=length(filenames);

    for k=1:filenum
        
        tic;
        
        [bands_lo,bands_hi,MI(:,:,k,1),MI(:,:,k,2),MI(:,:,k,3),MI(:,:,k,4)]=CFC_April_fft(char(filenames(k)),600,20,100,.05,.05,[3 9],15,[20 110],15,'Hz',dirnames);
        
        times(k,j)=toc;
        
        close('all')
        fclose('all')
    end
    
    fid3=fopen(['fft_times_noise_',num2str(j/10),'.txt','w')
    fprintf(fid3,'%f\n',times(:,j))
    
    for p=1:15
        A_labels{p}=num2str(bands_hi(p,2));
    end
    for p=1:15
        P_labels{p}=num2str(bands_lo(p,2));
    end

    avgMI=mean(MI,3);

    for m=1:50
        for n=1:4
            mi=MI(:,:,m,n);
            maxmi=max(max(mi));
            [r,c]=find(mi==maxmi);
            max_bands(m,n,1)=mean(bands_hi(r,2));
            max_bands(m,n,2)=mean(bands_lo(c,2));
        end
    end

    fid1=fopen(['hist_hi_bin_noise_',num2str(j/10),'.fig'],'w')
    fid2=fopen(['hist_lo_bin_noise_',num2str(j/10),'.fig'],'w')
    
    for l=1:4
        figure() 
        colorplot(avgMI(:,:,:,l))
        title(['Mean ',graph_titles{l},' (50 Realizations), White Noise Level ',num2str(j/10)])
        axis xy
        set(gca,'XTick',[1.5:(15+1.5)],'YTick',[1.5:(15+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels)
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,['avg_',graph_labels{l},'_noise_',num2str(j/10),'.fig'])
        
        fid=fopen(['avg_',graph_labels{l},'_noise_',num2str(j/10),'.txt'],'w')
        [r,c,junk,junk_jr]=size(avgMI(:,:,:,l));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgMI(:,:,:,l),r,c)');
        
        figure()
        hist(max_bands(:,l,1),bands_hi(:,2))
        title(['Histogram of Max. ',graph_titles{l},' Amplitude Bin, White Noise Level ',num2str(j/10)])
        set(gca,'XTick',bands_hi(:,2),'XTickLabel',A_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,['hist_',graph_labels{l},'_hi_bin_noise_',num2str(j/10),'.fig'])
        
        figure()
        hist(max_bands(:,l,2),bands_lo(:,2))
        title(['Histogram of Max. ',graph_titles{l},' Phase Bin, White Noise Level ',num2str(j/10)])
        set(gca,'XTick',bands_lo(:,2),'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,['hist_',graph_labels{l},'_lo_bin_noise_',num2str(j/10),'.fig'])
        
        if l~=4
            fprintf(fid1,'%s\t',graph_labels{l})
            fprintf(fid2,'%s\t',graph_labels{l})
        else
            fprintf(fid1,'%s\n',graph_labels{l})
            fprintf(fid2,'%s\n',graph_labels{l})
        end
    end
   
    fprintf(fid1,'%f\t%f\t%f\t%f\n',max_bands(:,:,1)')
    fprintf(fid2,'%f\t%f\t%f\t%f\n',max_bands(:,:,2)')
end

figure()
boxplot(times)
title('Boxplot of Elapsed Times for FFT Analysis')
set(gca,'XTickLabel',noise_labels)
xlabel('White Noise Level')
saveas(gcf,'fft_boxplot_times.fig')