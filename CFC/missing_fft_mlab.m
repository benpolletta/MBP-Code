function [times,max_bands,H]=r_trend_fft_mlab

orders=[0 3];

present_dir=pwd;

for m=1:2
    
    order=orders(m);
    
    if order==0
        order_folder='Matlab_BW_optimal';
    else
        order_folder=['Matlab_BW_order_',num2str(order)];
    end
    
    order_dir=['FFT\',order_folder,'\Aggregate'];
    mkdir (order_dir);
    
    dirnames{1}=['FFT\',order_folder,'\HAF_Data_Plots'];
    dirnames{2}=['FFT\',order_folder,'\AVP_Data'];
    dirnames{3}=['FFT\',order_folder,'\AVP_Plots'];
    dirnames{4}=['FFT\',order_folder,'\MI_Data_Plots'];
    for i=1:4
        mkdir (dirnames{i});
    end

    graph_titles{1}='MI';
    graph_titles{2}='MI p-Value';
    graph_titles{3}='MI z-Score';
    graph_titles{4}='Percent MI';

    graph_labels{1}='MI';
    graph_labels{2}='PV';
    graph_labels{3}='ZS';
    graph_labels{4}='PMI';

    max_bands=zeros(50,4,2,5);
    
    for j=1:5
        
        filenames=textread(['p_missing_',num2str(.05*j),'.list'],'%s%*[^\n]');
        filenum=length(filenames);
        
        MI=zeros(15,15,50,4);

        for k=1:filenum

            tic;

            [bands_lo,bands_hi,MI(:,:,k,1),MI(:,:,k,2),MI(:,:,k,3),MI(:,:,k,4)]=CFC_April_fft(char(filenames(k)),600,20,100,.05,.05,[3 9],15,[20 110],15,order,'Hz',dirnames);

            times(k,j)=toc;

            close('all')
            fclose('all')
            
        end
        
        cd (order_dir);

        fid3=fopen(['fft_times_missing_',num2str(.05*j),'.txt'],'w')
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

        fid1=fopen(['hist_hi_bin_missing_',num2str(.05*j),'.fig'],'w')
        fid2=fopen(['hist_lo_bin_missing_',num2str(.05*j),'.fig'],'w')

        for l=1:4
            fid=fopen(['avg_',graph_labels{l},'_missing_',num2str(.05*j),'.txt'],'w')
            [r,c,junk,junk_jr]=size(avgMI(:,:,:,l));
            format='';
            for i=1:c-1
                format=[format,'%f\t'];
            end
            format=[format,'%f\n'];
            fprintf(fid,format,reshape(avgMI(:,:,:,l),r,c)');

            if l~=4
                fprintf(fid1,'%s\t',graph_labels{l})
                fprintf(fid2,'%s\t',graph_labels{l})
            else
                fprintf(fid1,'%s\n',graph_labels{l})
                fprintf(fid2,'%s\n',graph_labels{l})
            end
            
            figure()
            colorplot(avgMI(:,:,:,l))
            title(['Mean ',graph_titles{l},', ',num2str(5*j),'% Missing'],'FontSize',30)
            axis xy
            set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
            xlabel('Phase-Modulating Freq. (Hz)','FontSize',24)
            ylabel('Amp.-Modulated Freq. (Hz)','FontSize',24)
            saveas(gcf,['avg_',graph_labels{l},'_missing_',num2str(.05*j),'.fig'])

            figure()
            subplot(2,1,1)
            hist(max_bands(:,l,1,j),bands_hi(:,2))
            title(['Histogram of Max. ',graph_titles{l},' Amplitude Bin, ',num2str(5*j),'% Missing'])
            set(gca,'XTick',bands_lo(:,2),'XTickLabel',A_labels)
            xlabel('Center Freq. (Hz)')

            subplot(2,1,2)
            hist(max_bands(:,l,2,j),bands_lo(:,2))
            title(['Histogram of Max. ',graph_titles{l},' Phase Bin, ',num2str(5*j),'% Missing'])
            set(gca,'XTick',bands_hi(:,2),'XTickLabel',P_labels)
            xlabel('Center Freq. (Hz)')
            saveas(gcf,['hist_',graph_labels{l},'_bin_missing_',num2str(.05*j),'.fig'])
        end

        fprintf(fid1,'%f\t%f\t%f\t%f\n',max_bands(:,:,1,j)')
        fprintf(fid2,'%f\t%f\t%f\t%f\n',max_bands(:,:,2,j)')
        
        cd (present_dir);
    end

    cd (order_dir);
    
    for l=1:4
        figure()
        subplot(2,1,1)
        H(:,:,l,1)=hist(reshape(max_bands(:,l,1,:),50,5),bands_hi(:,2));
        colorplot(H(:,:,l,1))
        axis xy
        title(['Histogram of Max. Bin for ',graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:15.5,'YTickLabel',A_labels,'XTick',1.5:6.5,'XTickLabel',5*[1:5],'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)
%         xlabel('Percent Missing Data','FontSize',24)

        subplot(2,1,2)
        H(:,:,l,2)=hist(reshape(max_bands(:,l,2,:),50,5),bands_lo(:,2));
        colorplot(H(:,:,l,2))
        axis xy
%         title(['Histogram of Max. Phase Bin for ',graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:15.5,'YTickLabel',P_labels,'XTick',1.5:6.5,'XTickLabel',5*[1:5],'FontSize',16)
        ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
        xlabel('Percent Data Missing','FontSize',24)
        saveas(gcf,['hist_',graph_labels{l},'_bin_missing.fig'])
    end

    figure()
    boxplot(times)
    title('Boxplot of Elapsed Times for FFT Analysis')
    set(gca,'XTickLabel',5*[1:5])
    xlabel('Percent Missing Data')
    saveas(gcf,'fft_boxplot_times_missing.fig')
    
    cd (present_dir);
    
end