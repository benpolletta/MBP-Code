function [times,max_bands,H]=r_trend_fft_mlab(orders)

LO=length(orders);

present_dir=pwd;

for m=1:LO
    
    order=orders(m);
    
    if order==0
        order_folder='Matlab_BW_optimal';
        pct_pass=0.9;
    else
        order_folder=['Matlab_BW_order_',num2str(order)];
        pct_pass=1;
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
    
    times=zeros(50,10);
    MI=zeros(15,15,50,4);
    max_bands=zeros(50,4,2,10);
    H=zeros(15,10,4,2);

    for j=1:10
        
        filenames=textread(['t_level_',num2str(.2*j),'.list'],'%s%*[^\n]');
        filenum=length(filenames);

        for k=1:filenum

            tic;

            [bands_lo,bands_hi,MI(:,:,k,1),MI(:,:,k,2),MI(:,:,k,3),MI(:,:,k,4)]=CFC_April_fft(char(filenames(k)),600,20,100,.05,.05,[3 9],15,[20 110],15,order,pct_pass,'Hz',dirnames);

            times(k,j)=toc;

            close('all')
            fclose('all')
            
        end
        
        cd (order_dir);

        fid3=fopen(['fft_times_r_trend',num2str(.2*j),'.txt'],'w')
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

        fid1=fopen(['hist_hi_bin_r_trend',num2str(.2*j),'.fig'],'w')
        fid2=fopen(['hist_lo_bin_r_trend',num2str(.2*j),'.fig'],'w')

        for l=1:4
            fid=fopen(['avg_',graph_labels{l},'_r_trend',num2str(.2*j),'.txt'],'w')
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
            title(['Mean ',graph_titles{l},', Random Trend Level ',num2str(.2*j)],'FontSize',30)
            axis xy
            set(gca,'XTick',[1.5:15.5],'YTick',[1.5:15.5],'XTickLabel',P_labels,'YTickLabel',A_labels,'FontSize',16)
            xlabel('Phase-Modulating Freq. (Hz)','FontSize',24)
            ylabel('Amp.-Modulated Freq. (Hz)','FontSize',24)
            saveas(gcf,['avg_',graph_labels{l},'_r_trend',num2str(.2*j),'.fig'])

            figure()
            subplot(2,1,1)
            hist(max_bands(:,l,1,j),bands_hi(:,2))
            title(['Histogram of Max. ',graph_titles{l},' Amplitude Bin, Random Trend Level ',num2str(.2*j)])
            set(gca,'XTick',bands_lo(:,2),'XTickLabel',A_labels)
            xlabel('Center Freq. (Hz)')

            subplot(2,1,2)
            hist(max_bands(:,l,2,j),bands_lo(:,2))
            title(['Histogram of Max. ',graph_titles{l},' Phase Bin, Random Trend Level ',num2str(.2*j)])
            set(gca,'XTick',bands_hi(:,2),'XTickLabel',P_labels)
            xlabel('Center Freq. (Hz)')
            saveas(gcf,['hist_',graph_labels{l},'_bin_r_trend',num2str(.2*j),'.fig'])
        end

        fprintf(fid1,'%f\t%f\t%f\t%f\n',max_bands(:,:,1,j)')
        fprintf(fid2,'%f\t%f\t%f\t%f\n',max_bands(:,:,2,j)')
        
        cd (present_dir);
    end

    cd (order_dir);
    
    for l=1:4
        figure()
        subplot(2,1,1)
        H(:,:,l,1)=hist(reshape(max_bands(:,l,1,:),50,10),bands_hi(:,2));
        colorplot(H(:,:,l,1))
        axis xy
        title(['Histogram of Max. Bin for ',graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:15.5,'YTickLabel',A_labels,'XTick',1.5:11.5,'XTickLabel',[1:10]*.2,'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)
%         xlabel('Random Trend Level','FontSize',24)

        subplot(2,1,2)
        H(:,:,l,2)=hist(reshape(max_bands(:,l,2,:),50,10),bands_lo(:,2));
        colorplot(H(:,:,l,2))
        axis xy
%         title(['Histogram of Max. Phase Bin for ',graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:15.5,'YTickLabel',P_labels,'XTick',1.5:11.5,'XTickLabel',[1:10]*.2,'FontSize',16)
        ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
        xlabel('Random Trend Level','FontSize',24)
        saveas(gcf,['hist_',graph_labels{l},'_bin_r_trend.fig'])
    end

    figure()
    boxplot(times)
    title('Boxplot of Elapsed Times for FFT Analysis')
    set(gca,'XTickLabel',[1:10]*.2)
    xlabel('Random Trend Level')
    saveas(gcf,'fft_boxplot_times_r_trend.fig')
    
    cd (present_dir);
    
end