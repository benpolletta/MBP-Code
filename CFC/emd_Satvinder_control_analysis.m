function emd_Satvinder_control_analysis

challenge_list='sk50_control_conditions.list';
challenge_name='sk50_control';
challenge_descriptor='Mouse EEG';
% challenge_params=[0 1 2];
challenge_labels={'Wake','NREM','REM'};

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);

no_files=360;

H_format='';
for i=1:no_challenges-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

graph_titles={'MI';'MI p-Value';'MI z-Score';'Binned MI';'Binned p-Thresholded MI';'Binned z-Thresholded MI'};

graph_labels={'MI';'PV';'ZS';'bMI';'bMI_pt';'bMI_zt'};

bands_lo=4:.25:12;
no_bands_lo=length(bands_lo);
bands_hi=20:5:180;
no_bands_hi=length(bands_hi);

for i=1:no_bands_hi
    A_labels{i}=num2str(bands_hi(i));
end
for i=1:no_bands_lo
    P_labels{i}=num2str(bands_lo(i));
end

dirnames{1}='HAF_Data_Plots';
dirnames{2}='AVP_Data';
dirnames{3}='AVP_Plots';
dirnames{4}='MI_Data_Plots';
for i=1:4
    mkdir (dirnames{i});
end

present_dir=pwd;

max_bands=zeros(no_files,2,no_challenges,3);
max_nMI_bands=zeros(no_files,2,no_challenges,2);
H=zeros(no_bands_lo,no_challenges,2);

for j=1:no_challenges

    listname=char(listnames(j));
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);

    nMI=zeros(no_bands_hi,no_bands_lo,filenum,3);

    parfor k=1:filenum
        
        temp_bands_hi=bands_hi;
        temp_bands_lo=bands_lo;

        MI=[]; 
        temp_nMI=zeros(no_bands_hi,no_bands_lo,1,3);

%         tic;

        filename=char(filenames(k));
        filename=filename(1:end-4);
        filename=[filename,'_low_hi.txt'];
        [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),temp_nMI(:,:,:,1),temp_nMI(:,:,:,2),temp_nMI(:,:,:,3)]=CFC_April_emd_beta(filename,600,5,20,100,.05,.05,[4 12],33,[20 180],33,'linear','Hz',dirnames);
        
%         [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),nMI(:,:,k,1),nMI(:,:,k,2)]=CFC_April(char(filenames(k)),600,5,20,100,.05,.05,[3 9],15,[20 110],15,'linear','Hz',dirnames);

%         times(k,j)=toc;

        close('all')
        fclose('all');

        for l=1:3

            mi=MI(:,:,l);
            maxMI=max(max(mi));
            if maxMI~=0
                [r,c]=find(mi==maxMI);
                max_bands(k,:,j,l)=[mean(bands(r,2)) mean(bands(c,2))];
            else
                max_bands(k,:,j,l)=[nan nan];
            end

            nmi=temp_nMI(:,:,:,l);
            maxnmi=max(max(nmi));
            if maxnmi~=0
                [r,c]=find(nmi==maxnmi);
                max_nMI_bands(k,:,j,l)=[mean(temp_bands_hi(r)) mean(temp_bands_lo(c))];
            else
                max_nMI_bands(k,:,j,l)=[nan nan];
            end

        end

    end

    avgnMI=mean(nMI,3);

    mkdir ('Aggregate')
    cd ('Aggregate')

    whitebg('w')

    fid2=fopen(['max_bands_hi_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
    fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}));
    fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,1,j,:),50,3)');

    fid3=fopen(['max_bands_lo_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
    fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}));
    fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,2,j,:),50,3)');

    fid4=fopen(['emd_times_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
    fprintf(fid4,'%f\n',times(:,j));

    for l=1:3

        fid=fopen(['avg_',graph_labels{3+l},'_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
        [r,c,~]=size(avgnMI(:,:,:,l));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgnMI(:,:,:,l),r,c)');

        fid1=fopen(['max_',graph_labels{3+l},'_bands_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
        fprintf(fid1,'%f\t%f\n',max_nMI_bands(:,:,j,l)');
        
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
        set(gca,'XTick',(1:6:no_bands_lo)+.5,'YTick',(1:6:no_bands_hi)+.5,'XTickLabel',P_labels{1:6:no_bands_hi},'YTickLabel',A_labels{1:6:no_bands_hi},'FontSize',16)
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

    cd (present_dir)

    fclose('all')
end

cd ('Aggregate')

for l=1:3

    figure()
    subplot(2,1,1)
    boxplot(max_bands(:,:,l,1))
    title(['Boxplot of Bin for Max. ',graph_titles{l}],'FontSize',30)
    set(gca,'XTickLabel',challenge_labels,'FontSize',16)
    ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

    subplot(2,1,2)
    boxplot(max_bands(:,:,l,2))
    set(gca,'XTickLabel',challenge_labels,'FontSize',16)
    ylabel({'Phase Bin';'Center Freq.'},'FontSize',24)
    xlabel('Rise Time/Fall Time','Fontsize',24)
    saveas(gcf,['boxplot_',graph_labels{l},'_',challenge_name,'.fig'])

end

if no_challenges>1

    for l=1:3
        
        H(:,:,1)=hist(reshape(max_nMI_bands(:,1,:,l),50,no_challenges),bands_hi);
        
        fid5=fopen([challenge_name,'_hists_hi_',graph_labels{3+l},'.txt'],'w');
        fprintf(fid5,H_format,[challenge_params; H(:,:,1)]');
        
        H(:,:,2)=hist(reshape(max_nMI_bands(:,2,:,l),50,no_challenges),bands_lo);
        
        fid6=fopen([challenge_name,'_hists_lo_',graph_labels{3+l},'.txt'],'w');
        fprintf(fid6,H_format,[challenge_params; H(:,:,2)]');

        figure()
        subplot(2,1,1)
        colorplot(H(:,:,1))
        axis xy
        title(['Histogram of Max. Bin for ',bMI_graph_titles{l}],'FontSize',30)
        set(gca,'YTick',1.5:(no_bands_hi+.5),'YTickLabel',A_labels,'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

        subplot(2,1,2)
        colorplot(H(:,:,2))
        axis xy
        set(gca,'YTick',1.5:(no_bands_lo+.5),'YTickLabel',P_labels,'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
        ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
        xlabel(challenge_descriptor,'FontSize',24)
        saveas(gcf,['hist_',bMI_graph_labels{l},'_',challenge_name,'.fig'])

        figure()
        colormap('gray')
        subplot(2,1,1)
        colorplot(H(:,:,1))
        %     caxis([0 50])
        colorbar
        axis xy
        set(gca,'YTick',(1:6:no_bands_hi)+.5,'YTickLabel',bands_hi(1:6:no_bands_hi),'XTick',[],'FontSize',16)

        subplot(2,1,2)
        colorplot(H(:,:,2))
        %     caxis([0 50])
        colorbar
        axis xy
%         if no_challenges==5
            set(gca,'YTick',(1:6:no_bands_lo)+.5,'YTickLabel',P_labels{1:6:no_bands_lo},'XTick',(1:no_challenges)+.5,'XTickLabel',challenge_labels,'FontSize',16)
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
% saveas(gcf,'emd_times_boxplot.fig')

fclose('all')

cd (present_dir);