function wavelet_mouse_eeg_PLV(sampling_freq,challenge_list,challenge_descriptor,challenge_labels,subplot_dims)

close('all')

challenge_list_name=char(challenge_list);
challenge_descriptor=char(challenge_descriptor);

% if nargin<5
%     for i=1:length(challenge_params)
%         challenge_labels{i}=num2str(challenge_params(i));
%     end
% end

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=[challenge_list_name(1:end-5),'_PLV'];

if length(challenge_labels)==no_challenges
    
    for i=1:length(challenge_labels)
    
        PP_titles{i}=[challenge_descriptor,' ',challenge_labels{i},', Mean Preferred Phase from PLV'];
        MI_titles{i}=[challenge_descriptor,' ',challenge_labels{i},', Mean Phase-Locking Value'];
    
    end
    
elseif length(challenge_labels)==sum(subplot_dims)
    
    for i=1:no_challenges
        
        col_index=mod(i,subplot_dims(2));
        if col_index==0
            col_index=subplot_dims(2);
        end
        row_index=ceil(i/subplot_dims(2));
        
        PP_titles{i}=[challenge_descriptor,' ',challenge_labels{subplot_dims(2)+row_index},' ',challenge_labels{col_index},', Mean Preferred Phase from PLV'];
        MI_titles{i}=[challenge_descriptor,' ',challenge_labels{subplot_dims(2)+row_index},' ',challenge_labels{col_index},', Mean Phase-Locking Value'];
        
    end
        
end

bands_lo=1:.25:12;
bands_hi=20:5:200;
bincenters=-.95:.1:.95;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

avg_PP_all=zeros(length(bands_hi),length(bands_lo),no_challenges);
avg_MI_all=zeros(length(bands_hi),length(bands_lo),no_challenges);

for j=2:no_challenges

    listname=char(listnames(j));

    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);

    listname=listname(1:end-5);
    cd (listname)
    
    dirname=[listname,'_PLV'];
    mkdir (dirname)
    
    avg_PP=zeros(length(bands_hi),length(bands_lo));
    avg_MI=zeros(length(bands_hi),length(bands_lo));
    
    parfor k=1:filenum

        filename=char(filenames(k));
        filename=filename(1:end-4);
        dataname=[filename,'_AP.mat'];
        
        Data=load(dataname);
        
        [PP,MI]=PLV(sampling_freq,Data.P_lo,Data.A_hi,Data.bands_lo,filename,dirname);
        
        avg_PP=avg_PP+exp(sqrt(-1)*PP)/filenum;
        avg_MI=avg_MI+MI;

    end
   
    avg_PP=angle(avg_PP);
    avg_MI=avg_MI/filenum;
    
    avg_PP_all(:,:,j)=avg_PP;
    avg_MI_all(:,:,j)=avg_MI;

    avg_name=['AVG_',dirname];
    mkdir (avg_name)
    cd (avg_name)

    save([avg_name,'.mat'],'bands_lo','bands_hi','avg_PP','avg_MI');
        
    MI_plotter_Jan(avg_MI,avg_name,bands_hi,bands_lo,MI_titles{j},'Hz');
    
    MI_plotter_Jan(avg_PP/pi,[avg_name,'_pp'],bands_hi,bands_lo,PP_titles{j},'Hz');
        
    clear avg_PP avg_MI
    
    cd (present_dir)

end

if no_challenges>1
    
    save([challenge_list_name,'_avgPLV.mat'],'bands_lo','bands_hi','avg_PP_all','avg_MI_all')
    
%     figure()
%     
%     max_MI=max(max(max(avg_MI_all(:,:,:))));
%     min_MI=min(min(min(avg_MI_all(:,:,:))));
%     
%     for i=1:no_challenges
%     
%         subplot(subplot_dims(1),subplot_dims(2),i)
%         
%         imagesc(avg_MI_all(:,:,i))
%         
%         caxis([min_MI max_MI])
%         
%         title(char(challenge_labels(i)))
%         
%         set(gca,'XTick',2.5:4:noamps+1.5,'XTickLabel',bands_lo)
%         set(gca,'YTick',1.5:1:nophases+1.5,'YTickLabel',bands_hi)
%         
%         if mod(i,subplot_dims(2))==1
%             ylabel('Amp.-Giving Freq. (Hz)')
%         end
%         
%         if mod(i,subplot_dims(2))==0
%             colorbar
%         end
%         
%         if ceil(i/subplot_dims(2))==subplot_dims(1)
%             xlabel('Phase-Giving Freq. (Hz)')
%         end
%         
%     end
    
    figure_replotter([1:2:2*no_challenges],subplot_dims(1),subplot_dims(2),bands_lo,bands_hi,MI_titles);
    
    saveas(gcf,[challenge_list_name,'_avgMI.fig'])
    
    figure_replotter([2:2:2*no_challenges],subplot_dims(1),subplot_dims(2),bands_lo,bands_hi,PP_titles);
    
    saveas(gcf,[challenge_list_name,'_avgPP.fig'])
    
end

fclose('all')

cd (present_dir);