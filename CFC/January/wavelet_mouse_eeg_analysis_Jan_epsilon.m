function wavelet_mouse_eeg_analysis_Jan_epsilon(sampling_freq,challenge_list,titles,row_labels,subplot_dims)

close('all')

challenge_list_name=char(challenge_list);

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=challenge_list_name(1:end-5);

bands_lo=1:.25:30;
bands_hi=20:5:250;
bincenters=-.95:.1:.95;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

% avg_M_all=zeros(20,length(bands_hi),length(bands_lo),no_challenges);
avg_MI_all=zeros(length(bands_hi),length(bands_lo),no_challenges);

for j=1:no_challenges

    challenge_row=ceil(j/subplot_dims(1));
    challenge_col=mod(j,subplot_dims(2));
    if challenge_col==0
        challenge_col=subplot_dims(2);
    end
    
    listname=char(listnames(j));
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    dirname=listname(1:end-5);
    mkdir (dirname)
    
    avg_M=zeros(length(bincenters),length(bands_hi),length(bands_lo));
    avg_MI=zeros(length(bands_hi),length(bands_lo));
    
    parfor k=1:filenum

        filename=char(filenames(k));

        [M,MI]=CFC_Jan_wav_gamma(filename(1:end),sampling_freq,20,bands_lo,bands_hi,dirname);

        if ~any(isnan(M))
            
            avg_M=avg_M+M/filenum;
        
        else
            
            display(['Inverse entropy for filename ',filename',' is NaN.']);
        
        end
        
        avg_MI=avg_MI+MI/filenum;
        
    end
    
%     avg_M_all(:,:,:,j)=avg_M;
    avg_MI_all(:,:,j)=avg_MI;

    avg_name=['AVG_',listname(1:end-5)];
    mkdir (avg_name)
    cd (avg_name)

    save(['AVG_',listname(1:end-5),'.mat'],'bands_lo','bands_hi','avg_M','avg_MI');
        
    avp_curve_plotter_Jan(bincenters,avg_M,avg_name,bands_hi,bands_lo,'Hz');
    
    fft_inv_entropy_plotter_Jan(avg_MI,avg_name,bands_hi,bands_lo,{'Mean IE';row_labels{min(challenge_row,length(row_labels))};titles{min(challenge_col,length(titles))}},'','Hz',1);
    
    clear avg_M avg_MI
    
    cd (present_dir)

end

if no_challenges>1
        
    save([challenge_list_name,'_avgMI.mat'],'avg_MI_all')
    
    figure()
    
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

    try
        
        figure_replotter_labels([2:2:2*no_challenges],subplot_dims(1),subplot_dims(2),5,6,bands_lo,bands_hi,titles,[],row_labels)
    
        saveas(gcf,[challenge_list_name,'_avgMI.fig'])
    
    end
        
end

fclose('all')

cd (present_dir);