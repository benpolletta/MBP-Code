function emd_sim_analysis(challenge_list,challenge_name,challenge_descriptor,challenge_params,challenge_labels)

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);

H_format='';
for i=1:no_challenges-1
    H_format=[H_format,'%f\t'];
end
H_format=[H_format,'%f\n'];

graph_titles={'MI';'MI p-Value';'MI z-Score';'Percent MI';'Binned MI'};

graph_labels={'MI';'PV';'ZS';'PMI';'BMI'};

bands_lo=3.2:.4:8.8;
bands_hi=23:6:107;

for i=1:15
    A_labels{i}=num2str(bands_hi(i));
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

max_bands=zeros(50,2,no_challenges,3);
max_nMI_bands=zeros(50,2,no_challenges,2);
H=zeros(15,no_challenges,2);

for j=1:no_challenges

    filenames=textread(char(listnames(j)),'%s');
    filenum=length(filenames);

    nMI=zeros(15,15,filenum,2);

    for k=26:filenum

        MI=[]; bands=[];

%         tic;

        filename=char(filenames(k));
%         filename=filename(1:end-4);
%         filename=[filename,'_low_hi.txt'];
        [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),nMI(:,:,k,1),nMI(:,:,k,2)]=CFC_April(filename,600,5,20,100,.05,.05,[3 9],15,[20 110],15,'linear','Hz',dirnames);
        
%         [bands,MI(:,:,1),MI(:,:,2),MI(:,:,3),nMI(:,:,k,1),nMI(:,:,k,2)]=CFC_April(char(filenames(k)),600,5,20,100,.05,.05,[3 9],15,[20 110],15,'linear','Hz',dirnames);

%         times(k,j)=toc;

        close('all')
        fclose('all');

        for l=1:3

            mi=MI(:,:,l);
            maxMI=max(max(mi));
            if maxMI~=0
                [r,c]=find(mi==maxMI);
                max_bands(k,1,j,l)=mean(bands(r,2));
                max_bands(k,2,j,l)=mean(bands(c,2));
            else
                max_bands(k,1,j,l)=nan;
                max_bands(k,2,j,l)=nan;
            end

        end

        for l=1:2

            nmi=nMI(:,:,k,l);
            maxnmi=max(max(nmi));
            if maxnmi~=0
                [r,c]=find(nmi==maxnmi);
                max_nMI_bands(k,1,j,l)=mean(bands_hi(r));
                max_nMI_bands(k,2,j,l)=mean(bands_lo(c));
            else
                max_nMI_bands(k,1,j,l)=nan;
                max_nMI_bands(k,2,j,l)=nan;
            end

        end

    end

    avgnMI=mean(nMI,3);

    mkdir ('Aggregate')
    cd ('Aggregate')

    whitebg('w')

    for l=1:2

        fid=fopen(['avg_',graph_labels{3+l},'_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
        [r,c,junk]=size(avgnMI(:,:,:,l));
        format='';
        for i=1:c-1
            format=[format,'%f\t'];
        end
        format=[format,'%f\n'];
        fprintf(fid,format,reshape(avgnMI(:,:,:,l),r,c)');

        fid1=fopen(['max_',graph_labels{3+l},'_bands_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
        fprintf(fid1,'%f\t%f\n',max_nMI_bands(:,:,j,l)');

    end

    fid2=fopen(['max_bands_hi_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
    fprintf(fid2,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}));
    fprintf(fid2,'%f\t%f\t%f\n',reshape(max_bands(:,1,j,:),50,3)');

    fid3=fopen(['max_bands_lo_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
    fprintf(fid3,'%s\t%s\t%s\n',char(graph_labels{1}),char(graph_labels{2}),char(graph_labels{3}));
    fprintf(fid3,'%f\t%f\t%f\n',reshape(max_bands(:,2,j,:),50,3)');

    fid4=fopen(['emd_times_',challenge_name,'_',num2str(challenge_params(j)),'.txt'],'w');
    fprintf(fid4,'%f\n',times(:,j));

    for l=1:2

        figure()
        colorplot(avgnMI(:,:,:,l))
        title(['Mean ',graph_titles{3+l},' (50 Realizations), ',challenge_descriptor,' ',challenge_labels{j}])
        axis xy
        set(gca,'XTick',[1.5:(15+1.5)],'YTick',[1.5:(15+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels)
        xlabel('Phase-Modulating Frequency (Hz)')
        ylabel('Amplitude-Modulated Frequency (Hz)')
        saveas(gcf,['avg_',graph_labels{3+l},'_',challenge_name,'_',num2str(challenge_params(j)),'.fig'])

        figure()
        colormap('gray')
        colorplot(avgnMI(:,:,:,l))
        axis xy
        set(gca,'XTick',[1.5 8.5 15.5],'YTick',[1.5 8.5 15.5],'XTickLabel',[P_labels(1) P_labels(8) P_labels(15)],'YTickLabel',[A_labels(1) A_labels(8) A_labels(15)],'FontSize',16)
        saveas(gcf,['avg_',graph_labels{3+l},'_',challenge_name,'_',num2str(challenge_params(j)),'_minimal.fig'])

        figure()
        hist(max_nMI_bands(:,1,j,l),bands_hi)
        title(['Histogram of Max. Amp. Bin for ',graph_titles{3+l},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_hi,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,['hist_',graph_labels{3+l},'_hi_bin_',challenge_name,'_',num2str(challenge_params(j)),'.fig'])

        figure()
        hist(max_nMI_bands(:,2,j,l),bands_lo)
        title(['Histogram of Max. Phase Bin for ',graph_titles{3+l},', ',challenge_descriptor,' ',challenge_labels{j}])
        %     set(gca,'XTick',bands_lo,'XTickLabel',P_labels)
        xlabel('Center Frequency (Hz)')
        saveas(gcf,['hist_',graph_labels{3+l},'_lo_bin_',challenge_name,'_',num2str(challenge_params(j)),'.fig'])
        
    end

    cd (present_dir)

    close('all')
    fclose('all');

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

for l=1:2

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
    title(['Histogram of Max. Bin for ',graph_titles{3+l}],'FontSize',30)
    set(gca,'YTick',1.5:16.5,'YTickLabel',A_labels,'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
    ylabel({'Amp. Bin';'Center Freq. (Hz)'},'FontSize',24)

    subplot(2,1,2)
    colorplot(H(:,:,2))
    axis xy
    set(gca,'YTick',1.5:16.5,'YTickLabel',P_labels,'XTick',1.5:(no_challenges+1.5),'XTickLabel',challenge_labels,'FontSize',16)
    ylabel({'Phase Bin';'Center Freq. (Hz)'},'FontSize',24)
    xlabel(challenge_descriptor,'FontSize',24)
    saveas(gcf,['hist_',graph_labels{3+l},'_',challenge_name,'.fig'])

    figure()
    colormap('gray')
    subplot(2,1,1)
    colorplot(H(:,:,1))
    caxis([0 50])
    colorbar
    axis xy
    set(gca,'YTick',[1.5 8.5 15.5],'YTickLabel',[bands_hi(1) bands_hi(8) bands_hi(15)],'XTick',[],'FontSize',16)

    subplot(2,1,2)
    colorplot(H(:,:,2))
    caxis([0 50])
    colorbar
    axis xy
    if no_challenges==5
        set(gca,'YTick',[1.5 8.5 15.5],'YTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'XTick',[1.5 3.5 5.5],'XTickLabel',[challenge_labels(1) challenge_labels(3) challenge_labels(5)],'FontSize',16)
    elseif no_challenges==10
        set(gca,'YTick',[1.5 8.5 15.5],'YTickLabel',[bands_lo(1) bands_lo(8) bands_lo(15)],'XTick',[1.5 4.5 7.5 10.5],'XTickLabel',[challenge_labels(1) challenge_labels(4) challenge_labels(7) challenge_labels(10)],'FontSize',16)
    end
    saveas(gcf,['hist_',graph_labels{3+l},'_',challenge_name,'_minimal.fig'])

    close('all')
    
end

% figure()
% boxplot(times)
% title('Boxplot of Elapsed Times for Filter Bank Analysis')
% set(gca,'XTickLabel',challenge_labels)
% xlabel(challenge_descriptor)
% saveas(gcf,'emd_times_boxplot.fig')

fclose('all')

cd (present_dir);