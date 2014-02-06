function fbank_mouse_eeg_analysis_May13

challenge_list='sk50_control_conditions.list';
challenge_name='sk50_control';
challenge_descriptor='Mouse EEG';
% challenge_params=[0 1 2];
challenge_labels={'Wake','NREM','REM'};

sampling_freq=600;
secs_per_epoch=4;
datalength=secs_per_epoch*sampling_freq;

% challenge_list_name=char(challenge_list);
% challenge_name=char(challenge_name);
% challenge_descriptor=char(challenge_descriptor);
% if nargin<5
%     for i=1:length(challenge_params)
%         challenge_labels{i}=num2str(challenge_params(i));
%     end
% end

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);
% challenge_name=challenge_name(1:end-5);

bands=makebands(10,1/datalength,sampling_freq/2,2);
ud_centers=flipud(bands(:,2));
no_bands=length(bands);
bands_lo=4:.25:12;
no_bands_lo=length(bands_lo);
bands_hi=20:5:180;
no_bands_hi=length(bands_hi);

for i=1:no_bands_lo
    P_labels{i}=num2str(bands_lo(i));
end
for i=1:no_bands_hi
    A_labels{i}=num2str(bands_hi(i));
end

H=zeros(no_bands_lo,no_challenges,2,5);
H_MI=zeros(10,no_challenges,2,4);

H_format='';
for i=1:no_challenges-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

MI_graph_titles={'MI';'MI p-Value';'MI Normal z-Score';'MI Lognormal z-Score'};
bMI_graph_titles={'Binned MI';'Thresholded MI (Empirical p-Value)';'Thresholded MI (Normal p-Value)';'Thresholded MI (Lognormal p-Value)';'Normal p-Value of MI';'Lognormal p-Value of MI'};

MI_graph_labels={'MI';'PV';'ZS';'LZS'};
bMI_graph_labels={'bMI';'bMI_pt';'bMI_nt';'bMI_lt';'bMI_npv';'bMI_lpv'};

% band_starts=[4; 12; 40; 100];
% band_ends=[12; 40; 100; 200];
% band_centers=[8; 26; 70; 150];
% custom_bands=[band_starts band_centers band_ends];
% ud_centers=flipud(band_centers);

dirnames{1}='FFT/Filter_Bank/HAF_Data_Plots';
dirnames{2}='FFT/Filter_Bank/AVP_Data';
dirnames{3}='FFT/Filter_Bank/AVP_Plots';
dirnames{4}='FFT/Filter_Bank/MI_Data_Plots';
for i=1:4
    mkdir (dirnames{i});
end

present_dir=pwd;

for j=1:no_challenges

    listname=char(listnames(j));
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);

    MI=zeros(no_bands,no_bands,filenum,4);
    nMI=zeros(no_bands_hi,no_bands_lo,filenum,6);
    max_bands=zeros(filenum,2,4);
    max_nMI_bands=zeros(filenum,2,6);
%     times=zeros(filenum,no_challenges);

    parfor k=1:filenum

%         tic;

        temp_bands_hi=bands_hi;
        temp_bands_lo=bands_lo;

        temp_MI=zeros(no_bands,no_bands,1,4);
        temp_nMI=zeros(no_bands_hi,no_bands_lo,1,6);
        temp_max_bands=zeros(1,2,4);
        temp_max_nMI_bands=zeros(1,2,6);
        
        [temp_bands,temp_MI(:,:,:,1),temp_MI(:,:,:,2),temp_MI(:,:,:,3),temp_MI(:,:,:,4),temp_nMI(:,:,:,1),temp_nMI(:,:,:,2),temp_nMI(:,:,:,3),temp_nMI(:,:,:,4),temp_nMI(:,:,:,5),temp_nMI(:,:,:,6)]=CFC_September_fbank_beta(char(filenames(k)),600,5,20,100,.05,[4 12],33,[20 180],33,0,.9,'custom','Hz',dirnames,bands);

        temp_ud_centers=flipud(temp_bands(:,2));
        
        MI(:,:,k,:)=temp_MI;
        nMI(:,:,k,:)=temp_nMI;
        
%         times(k,j)=toc;

        close('all')
        fclose('all');

        for l=1:4

            mi=temp_MI(:,:,:,l);
            maxMI=max(max(triu(mi,1)));
            if maxMI~=0
                [r,c]=find(mi==maxMI);
                temp_max_bands(:,:,l)=[mean(temp_ud_centers(r)) mean(temp_ud_centers(c))];
            else
                temp_max_bands(:,:,l)=[nan nan];
            end

        end

        max_bands(k,:,:)=temp_max_bands;
        
        for l=1:6

            nmi=temp_nMI(:,:,:,l);
            maxnmi=max(max(nmi));
            if maxnmi~=0
                [r,c]=find(nmi==maxnmi);
                temp_max_nMI_bands(:,:,l)=[mean(temp_bands_hi(r)) mean(temp_bands_lo(c))];
            else
                temp_max_nMI_bands(:,:,l)=[nan nan];
            end

        end
        
        max_nMI_bands(k,:,:)=temp_max_nMI_bands;

    end

    avgMI=mean(MI,3);
    avgnMI=mean(nMI,3);

    mkdir ('FFT/Filter_Bank/Aggregate')
    cd ('FFT/Filter_Bank/Aggregate')

    whitebg('w')

    for m=1:4

        fid=fopen(['avg_',MI_graph_labels{m},'_',listname(1:end-5),'.txt'],'w');
        [r,c,~]=size(avgMI(:,:,:,m));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgMI(:,:,:,m),r,c)');
        fclose(fid);
        
        fid1=fopen(['max_',MI_graph_labels{m},'_bands_',listname(1:end-5),'.txt'],'w');
        fprintf(fid1,'%f\t%f\n',max_bands(:,:,m)');
        fclose(fid1);
        
    end
    
    for m=1:6

        fid=fopen(['avg_',bMI_graph_labels{m},'_',listname(1:end-5),'.txt'],'w');
        [r,c,~]=size(avgnMI(:,:,:,m));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgnMI(:,:,:,m),r,c)');
        fclose(fid);
        
        fid1=fopen(['max_',bMI_graph_labels{m},'_bands_',listname(1:end-5),'.txt'],'w');
        fprintf(fid1,'%f\t%f\n',max_nMI_bands(:,:,m)');
        fclose(fid1);
        
    end

%     fid2=fopen(['max_bands_hi_',listname(1:end-5),'.txt'],'w')
%     fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
%     fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,1,:),filenum,3)')
% 
%     fid3=fopen(['max_bands_lo_',listname(1:end-5),'.txt'],'w')
%     fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}))
%     fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,2,:),filenum,3)')

%     fid4=fopen(['fbank_times_',listname(1:end-5),'.txt'],'w');
%     fprintf(fid4,'%f\n',times(:,j));

    for l=1:4

        figure()
        colorplot(nantriu(avgMI(:,:,:,l),1))
        title(['Mean ',MI_graph_titles{l},' ',challenge_descriptor,' ',challenge_labels{j}])
        axis ij
        set(gca,'XTick',[1.5:(no_bands+.5)],'YTick',[1.5:(no_bands+.5)],'XTickLabel',ud_centers,'YTickLabel',ud_centers)
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,[listname(1:end-5),'_avg_',MI_graph_labels{l},'.fig'])

        figure()
        colormap('gray')
        colorplot(nantriu(avgMI(:,:,:,l),1))
        axis ij
        set(gca,'FontSize',16)
        saveas(gcf,[listname(1:end-5),'_avg_',MI_graph_labels{l},'_minimal.fig'])
        close(gcf)
        
        figure()
        [h,b]=hist(max_bands(:,1,l),bands(:,2));
        H_MI(:,j,1,l)=h/filenum;
        subplot(2,1,1)
        plot(b,h)
        title(['Histogram of Max. Amp. Bin for ',MI_graph_titles{l},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_hi,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
%         saveas(gcf,[listname(1:end-5),'_hist_',MI_graph_labels{l},'_hi.fig'])

%         figure()
        [h,b]=hist(max_bands(:,2,l),bands(:,2));
        H_MI(:,j,2,l)=h/filenum;
        subplot(2,1,2)
        plot(b,h)
        title(['Histogram of Max. Phase Bin for ',MI_graph_titles{l},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_lo,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,[listname(1:end-5),'_hist_',MI_graph_labels{l},'.fig'])
        close(gcf)
        
    end
    
    for l=1:6

        figure()
        colorplot(avgnMI(:,:,:,l))
        title(['Mean ',bMI_graph_titles{l},' ',challenge_descriptor,' ',challenge_labels{j}])
        axis xy
        set(gca,'XTick',[1.5:(no_bands_lo+.5)],'YTick',[1.5:(no_bands_hi+.5)],'XTickLabel',P_labels,'YTickLabel',A_labels)
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,[listname(1:end-5),'_avg_',bMI_graph_labels{l},'.fig'])

        figure()
        colormap('gray')
        colorplot(avgnMI(:,:,:,l))
        axis xy
        set(gca,'XTick',(1:6:no_bands_lo)+.5,'YTick',(1:6:no_bands_hi)+.5,'XTickLabel',P_labels(1:6:no_bands_hi),'YTickLabel',A_labels(1:6:no_bands_hi),'FontSize',16)
        saveas(gcf,[listname(1:end-5),'_avg_',bMI_graph_labels{l},'_minimal.fig'])
        close(gcf)
        
        figure()
        [h,b]=hist(max_nMI_bands(:,1,l),bands_hi);
        H(:,j,1,l)=h/filenum;
        plot(b,h)
        title(['Histogram of Max. Amp. Bin for ',bMI_graph_titles{l},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_hi,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
%         saveas(gcf,[listname(1:end-5),'_hist_',bMI_graph_labels{l},'_hi.fig'])

%         figure()
        [h,b]=hist(max_nMI_bands(:,2,l),bands_lo);
        H(:,j,2,l)=h/filenum;
        plot(b,h)
        title(['Histogram of Max. Phase Bin for ',bMI_graph_titles{l},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_lo,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,[listname(1:end-5),'_hist_',bMI_graph_labels{l},'.fig'])
        close(gcf)
        
    end

    fclose('all');
    
    clear nMI MI max_bands max_nMI_bands
    
    pack
    
    cd (present_dir)

end

cd (['FFT/Filter_Bank/Aggregate'])

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

    for l=1:4

        fid5=fopen([challenge_name,'_hists_hi_',MI_graph_labels{l},'.txt'],'w');
        fprintf(fid5,H_format,H_MI(:,:,1,l)');

        fid6=fopen([challenge_name,'_hists_lo_',MI_graph_labels{l},'.txt'],'w');
        fprintf(fid6,H_format,H_MI(:,:,2,l)');

        figure()
        subplot(2,1,1)
        colorplot(H_MI(:,:,1,l))
        axis xy
        title(['Histogram of Max. Bin for ',MI_graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:(no_bands+.5),'YTickLabel',bands(:,2),'XTick',1.5:(no_challenges+.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

        subplot(2,1,2)
        colorplot(H_MI(:,:,2,l))
        axis xy
        set(gca,'YTick',1.5:(no_bands+.5),'YTickLabel',bands(:,2),'XTick',1.5:(no_challenges+.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
        xlabel(challenge_descriptor,'FontSize',24)
        saveas(gcf,['hist_',MI_graph_labels{l},'_',challenge_name,'.fig'])

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
%         if no_challenges==5
            set(gca,'XTick',1:no_challenges+.5,'XTickLabel',challenge_labels,'FontSize',16)
%         elseif no_challenges==10
%             set(gca,'XTick',[1.5 4.5 7.5 10.5],'XTickLabel',[challenge_labels(1) challenge_labels(4) challenge_labels(7) challenge_labels(10)],'FontSize',16)
%         end
        saveas(gcf,['hist_',MI_graph_labels{l},'_',challenge_name,'_minimal.fig'])
        close(gcf)

    end

    for l=1:6

        fid5=fopen([challenge_name,'_hists_hi_',bMI_graph_labels{l},'.txt'],'w');
        fprintf(fid5,H_format,H(:,:,1,l)');

        fid6=fopen([challenge_name,'_hists_lo_',bMI_graph_labels{l},'.txt'],'w');
        fprintf(fid6,H_format,H(:,:,2,l)');

        figure()
        subplot(2,1,1)
        colorplot(H(:,:,1,l))
        axis xy
        title(['Histogram of Max. Bin for ',bMI_graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:(no_bands_hi+.5),'YTickLabel',A_labels,'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

        subplot(2,1,2)
        colorplot(H(:,:,2,l))
        axis xy
        set(gca,'YTick',1.5:(no_bands_lo+.5),'YTickLabel',P_labels,'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
        xlabel(challenge_descriptor,'FontSize',24)
        saveas(gcf,['hist_',bMI_graph_labels{l},'_',challenge_name,'.fig'])

        figure()
        colormap('gray')
        subplot(2,1,1)
        colorplot(H(:,:,1,l))
        %     caxis([0 50])
        colorbar
        axis xy
        set(gca,'YTick',(1:6:no_bands_hi)+.5,'YTickLabel',bands_hi(1:6:no_bands_hi),'XTick',[],'FontSize',16)

        subplot(2,1,2)
        colorplot(H(:,:,2,l))
        %     caxis([0 50])
        colorbar
        axis xy
%         if no_challenges==5
            set(gca,'YTick',(1:6:no_bands_lo)+.5,'YTickLabel',P_labels(1:6:no_bands_lo),'XTick',(1:no_challenges)+.5,'XTickLabel',challenge_labels,'FontSize',16)
%         elseif no_challenges==10
%             set(gca,'YTick',(1:6:no_bands_lo)+.5,'YTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'XTick',[1.5 4.5 7.5 10.5],'XTickLabel',[challenge_labels(1) challenge_labels(4) challenge_labels(7) challenge_labels(10)],'FontSize',16)
%         end
        saveas(gcf,['hist_',bMI_graph_labels{l},'_',challenge_name,'_minimal.fig'])
        close(gcf)

    end

end
    
% figure()
% boxplot(times)
% title('Boxplot of Elapsed Times for Filter Bank Analysis')
% set(gca,'XTickLabel',challenge_labels)
% xlabel(challenge_descriptor)
% saveas(gcf,'fbank_times_boxplot.fig')

fclose('all');

cd (present_dir);