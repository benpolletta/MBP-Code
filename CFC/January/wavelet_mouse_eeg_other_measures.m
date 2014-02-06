function wavelet_mouse_eeg_analysis_Jan_gamma(sampling_freq,challenge_list,challenge_name,challenge_descriptor,challenge_params,challenge_labels,subplot_dims)

challenge_list_name=char(challenge_list);
challenge_name=char(challenge_name);
challenge_descriptor=char(challenge_descriptor);
if nargin<5
    for i=1:length(challenge_params)
        challenge_labels{i}=num2str(challenge_params(i));
    end
end

labels={'_plv','_canolty'};
titles={'Phase-Locking Value','Canoltys Modulation Index'};

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=challenge_list_name(1:end-5);

bands_lo=4:.25:12;
bands_hi=20:5:180;
bincenters=-.95:.1:.95;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

% avg_M_all=zeros(20,length(bands_hi),length(bands_lo),no_challenges);
avg_MI_all=zeros(length(bands_hi),length(bands_lo),no_challenges);

for j=1:no_challenges

    listname=char(listnames(j));
    mkdir ([listname(1:end-5),'_PLV_canolty'])
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);

    avg_PP=zeros(length(bands_hi),length(bands_lo),2);
    avg_MI=zeros(length(bands_hi),length(bands_lo),2);
    
    parfor k=1:filenum

        filename=char(filenames(k));
        dirname=[listname(1:end-5),'_PLV_canolty'];

        [PP(:,:,1),MI(:,:,1)]=PLV(sampling_freq,P,A,bands_lo,filename,dirname);

        [PP(:,:,2),MI(:,:,2)]=canolty_MI(P,A,filename,dirname);
        
        avg_PP=avg_PP+exp(sqrt(-1)*PP)/filenum;
        avg_MI=avg_MI+MI/filenum;

    end
    
    avg_PP_all(:,:,:,j)=angle(avg_PP);
    avg_MI_all(:,:,:,j)=avg_MI;

    avg_name=['AVG_',listname(1:end-5)];
    mkdir (avg_name)
    cd (avg_name)

    save(['AVG_',listname(1:end-5),'.mat'],'bands_lo','bands_hi','avg_PP','avg_MI');
    
    for l=1:2
        
        MI_plotter_Jan(avg_MI(:,:,l),[avg_name,labels{i}],bands_hi,bands_lo,['Mean ',titles{i}],'Hz');
        
        MI_plotter_Jan(avg_PP(:,:,l),[avg_name,labels{i},'_pp'],bands_hi,bands_lo,['Mean Preferred Phase from ',titles{i}],'Hz');
        
    end
        
    clear avg_PP avg_MI
    
    cd (present_dir)

end

if no_challenges>1
    
    figure()
    
    max_MI=max(max(max(avg_MI_all(:,:,:))));
    min_MI=min(min(min(avg_MI_all(:,:,:))));
    
    for i=1:no_challenges
    
        subplot(subplot_dims(1),subplot_dims(2),i)
        
        imagesc(avg_MI_all(:,:,i))
        
        caxis([min_MI max_MI])
        
        title(char(challenge_labels(i)))
        
        set(gca,'XTick',2.5:4:noamps+1.5,'XTickLabel',bands_lo)
        set(gca,'YTick',1.5:1:nophases+1.5,'YTickLabel',bands_hi)
        
        if mod(i,subplot_dims(2))==1
            ylabel('Amp.-Giving Freq. (Hz)')
        end
        
        if mod(i,subplot_dims(2))==0
            colorbar
        end
        
        if ceil(i/subplot_dims(2))==subplot_dims(1)
            xlabel('Phase-Giving Freq. (Hz)')
        end
        
    end
    
    saveas(gcf,[challenge_list_name,'_avg_MI.fig'])
    
end

fclose('all')

cd (present_dir);