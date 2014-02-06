function wavelet_mouse_eeg_analysis(sampling_freq,challenge_list,challenge_name,challenge_descriptor,challenge_params,challenge_labels)

challenge_list_name=char(challenge_list);
challenge_name=char(challenge_name);
challenge_descriptor=char(challenge_descriptor);
if nargin<5
    for i=1:length(challenge_params)
        challenge_labels{i}=num2str(challenge_params(i));
    end
end

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=challenge_list_name(1:end-5);

bands_lo=4.25:.5:11.75;
bands_hi=25:10:175;

for i=1:16
    P_labels{i}=num2str(bands_lo(i));
    A_labels{i}=num2str(bands_hi(i));
end

H=zeros(16,no_challenges,2,5);
H_MI=zeros(16,no_challenges,2,4);

H_format='';
for i=1:no_challenges-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

MI_graph_titles={'MI';'MI p-Value';'MI Normal z-Score';'MI Lognormal z-Score';'Thresholded MI (Empirical p-Value)';'Thresholded MI (Normal p-Value)';'Thresholded MI (Lognormal p-Value)';'Normal p-Value of MI';'Lognormal p-Value of MI'};

MI_graph_labels={'MI';'PV';'ZS';'LZS';'MI_pt';'MI_nt';'MI_lt';'MI_npv';'MI_lpv'};

dirnames{1}=['Wavelet\HAF_Data_Plots'];
dirnames{2}=['Wavelet\AVP_Data'];
dirnames{3}=['Wavelet\AVP_Plots'];
dirnames{4}=['Wavelet\MI_Data_Plots'];
for i=1:4
    mkdir (dirnames{i});
end

present_dir=pwd;

for j=1:no_challenges

    listname=char(listnames(j));
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);

    MI=zeros(16,16,filenum,9);
%     nMI=zeros(16,16,filenum,5);
    max_bands=zeros(filenum,2,4);
%     max_nMI_bands=zeros(filenum,2,5);
    times=zeros(filenum,no_challenges);

    for k=1:filenum

        tic;

        [bands_lo,bands_hi,MI(:,:,k,1),MI(:,:,k,2),MI(:,:,k,3),MI(:,:,k,4),MI(:,:,k,5),MI(:,:,k,6),MI(:,:,k,7),MI(:,:,k,8),MI(:,:,k,9)]=CFC_September_wav(char(filenames(k)),sampling_freq,20,100,.05,linspace(4.25,11.75,16)',linspace(25,175,16)','Hz',dirnames);

        times(k,j)=toc;

        close('all')
        fclose('all');

        for l=1:9

            mi=MI(:,:,k,l);
            maxMI=max(max(mi));
            if maxMI~=0
                [r,c]=find(mi==maxMI);
                max_bands(k,1,l)=mean(bands_hi(r));
                max_bands(k,2,l)=mean(bands_lo(c));
            else
                max_bands(k,1,l)=nan;
                max_bands(k,2,l)=nan;
            end

        end

    end

    avgMI=mean(MI,3);
%     avgnMI=mean(nMI,3);

    mkdir (['Wavelet\Aggregate'])
    cd (['Wavelet\Aggregate'])

    whitebg('w')

    for m=1:9

        fid=fopen(['avg_',MI_graph_labels{m},'_',listname(1:end-5),'.txt'],'w')
        [r,c,junk]=size(avgMI(:,:,:,m));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgMI(:,:,:,m),r,c)');
        fclose(fid)
        
        fid1=fopen(['max_',MI_graph_labels{m},'_bands_',listname(1:end-5),'.txt'],'w')
        fprintf(fid1,'%f\t%f\n',max_bands(:,:,m)')
        fclose(fid1)
        
        figure()
        colorplot(avgMI(:,:,:,m))
        title(['Mean ',MI_graph_titles{m},' ',challenge_descriptor,' ',challenge_labels{j}])
        axis xy
        set(gca,'XTick',[1.5:17.5],'YTick',[1.5:17.5],'XTickLabel',bands_lo(:,2),'YTickLabel',bands_hi(:,2))
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,[listname(1:end-5),'_avg_',MI_graph_labels{m},'.fig'])

        figure()
        colormap('gray')
        colorplot(triu(avgMI(:,:,:,m),1))
        axis xy
        set(gca,'FontSize',16)
        saveas(gcf,[listname(1:end-5),'_avg_',MI_graph_labels{m},'_minimal'],'pdf')
        close(gcf)
        
        figure()
        [h,b]=hist(max_bands(:,1,m),bands_hi(:,2));
        H_MI(:,j,1,m)=h/filenum;
        subplot(2,1,1)
        bar(b,h)
        title(['Histogram of Max. Amp. Bin for ',MI_graph_titles{m},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_hi,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
%         saveas(gcf,[listname(1:end-5),'_hist_',MI_graph_labels{m},'_hi.fig'])

%         figure()
        [h,b]=hist(max_bands(:,2,m),bands_lo(:,2));
        H_MI(:,j,2,m)=h/filenum;
        subplot(2,1,2)
        bar(b,h)
        title(['Histogram of Max. Phase Bin for ',MI_graph_titles{m},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_lo,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,[listname(1:end-5),'_hist_',MI_graph_labels{m},'.fig'])
        close(gcf)
        
    end
    
%     for m=1:5
% 
%         fid=fopen(['avg_',bMI_graph_labels{m},'_',listname(1:end-5),'.txt'],'w')
%         [r,c,junk]=size(avgnMI(:,:,:,m));
%         format='';
%         for i=1:c-1
%             format=[format,'%f\t'];
%         end
%         format=[format,'%f\n'];
%         fprintf(fid,format,reshape(avgnMI(:,:,:,m),r,c)');
%         fclose(fid)
%         
%         fid1=fopen(['max_',bMI_graph_labels{m},'_bands_',listname(1:end-5),'.txt'],'w')
%         fprintf(fid1,'%f\t%f\n',max_nMI_bands(:,:,m)')
%         fclose(fid1)
%         
%     end

%     fid2=fopen(['max_bands_hi_',listname(1:end-5),'.txt'],'w')
%     fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
%     fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,1,:),filenum,3)')
% 
%     fid3=fopen(['max_bands_lo_',listname(1:end-5),'.txt'],'w')
%     fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
%     fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,2,:),filenum,3)')

    fid4=fopen(['fbank_times_',listname(1:end-5),'.txt'],'w')
    fprintf(fid4,'%f\n',times(:,j))

    fclose('all')
    
    clear nMI MI max_bands max_nMI_bands
    
    pack
    
    cd (present_dir)

end

cd (['Wavelet\Aggregate'])

% for l=1:3
% 
%     figure()
%     subplot(2,1,1)
%     boxplot(max_bands(:,:,l,1))
%     title(['Boxplot of Bin for Max. ',graph_titles{l}],'FontSize',30)
%     set(gca,'XTickLabel',challenge_labels,'FontSize',16)
%     ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)
% 
%     subplot(2,1,2)
%     boxplot(max_bands(:,:,l,2))
%     set(gca,'XTickLabel',challenge_labels,'FontSize',16)
%     ylabel({'Phase Bin';'Center Freq.'},'FontSize',24)
%     xlabel('Rise Time/Fall Time','Fontsize',24)
%     saveas(gcf,['boxplot_',graph_labels{l},'_',challenge_name,'.fig'])
% 
% end

if no_challenges>1
    
    for l=1:9

        fid5=fopen([challenge_list_name,'_hists_hi_',MI_graph_labels{l},'.txt'],'w');
        fprintf(fid5,H_format,[challenge_params; H_MI(:,:,1,l)]');

        fid6=fopen([challenge_list_name,'_hists_lo_',MI_graph_labels{l},'.txt'],'w');
        fprintf(fid6,H_format,[challenge_params; H_MI(:,:,2,l)]');

        figure()
        subplot(2,1,1)
        colorplot(H_MI(:,:,1,l))
        axis xy
        title(['Histogram of Max. Bin for ',MI_graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:17.5,'YTickLabel',bands_hi(:,2),'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

        subplot(2,1,2)
        colorplot(H_MI(:,:,2,l))
        axis xy
        set(gca,'YTick',1.5:17.5,'YTickLabel',bands_lo(:,2),'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
        xlabel(challenge_descriptor,'FontSize',24)
        saveas(gcf,['hist_',MI_graph_labels{l},'_',challenge_list_name,'.fig'])

        figure()
        colormap('gray')
        subplot(2,1,1)
        colorplot(H_MI(:,:,1,l))
        %     caxis([0 50])
        colorbar
        axis xy
        set(gca,'XTick',[],'FontSize',16)

        subplot(2,1,2)
        colorplot(H_MI(:,:,2,l))
        %     caxis([0 50])
        colorbar
        axis xy
        if no_challenges==5
            set(gca,'XTick',[1.5 3.5 5.5],'XTickLabel',[challenge_labels(1) challenge_labels(3) challenge_labels(5)],'FontSize',16)
        elseif no_challenges==10
            set(gca,'XTick',[1.5 4.5 7.5 10.5],'XTickLabel',[challenge_labels(1) challenge_labels(4) challenge_labels(7) challenge_labels(10)],'FontSize',16)
        end
        saveas(gcf,['hist_',MI_graph_labels{l},'_',challenge_list_name,'_minimal'],'pdf')
        close(gcf)

    end
    
end

figure()
boxplot(times)
title('Boxplot of Elapsed Times for Filter Bank Analysis')
set(gca,'XTickLabel',challenge_labels)
xlabel(challenge_descriptor)
saveas(gcf,'fbank_times_boxplot.fig')

fclose('all')

cd (present_dir);