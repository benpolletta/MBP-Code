function avg_fft_save(cond_listname,sampling_freq,signal_length)

close('all')

if isempty(cond_listname)
    
    [cond_listname,listpath]=uigetfile('*list','Choose a list of condition lists to fft.');

else
    
    listpath=pwd;
    listpath=[listpath,'/'];
    
end

cond_lists=textread([listpath,cond_listname],'%s');
cond_num=length(cond_lists);

f=(sampling_freq/2)*([1:signal_length/2+1]-1)/(signal_length/2);
% format=make_format(signal_length/2+1,'f');
f(f>200)=[];
no_freqs=length(f);

all_avg_fft=nan(cond_num,no_freqs);
all_se_fft=nan(cond_num,no_freqs);

for j=1:cond_num
    
    listname=char(cond_lists(j));
    fftname=[listname(1:end-5),'_fft'];
    
    filenames=textread([listpath,listname],'%s');
    filenum=length(filenames);
    
    all_fft=zeros(filenum,no_freqs);

    parfor i=1:filenum

        filename=char(filenames(i));
                
        data=load(['../',filename]);
        data=data';
        data=detrend(data);

        % data_hat=fft(data);
        data_hat=pmtm(data,[],signal_length);
        
        all_fft(i,:)=data_hat(1:no_freqs);
        
    end
    
%     fid=fopen([fftname,'.txt'],'w');
%     fprintf(fid,format,f);
%     fprintf(fid,format,all_fft');
%     fclose(fid);
    
    save([fftname,'.mat'],'f','all_fft')
    
    mean_fft=nanmean(all_fft);
    se_fft=nanstd(all_fft)/sqrt(filenum);
    
%     figure(j)
%     loglog(f,mean_fft,'k')
%     hold on
%     loglog(f,mean_fft+se_fft,'-k')
%     loglog(f,mean_fft-se_fft,'-k')
%     title(['Avg. FFT for ',listname])
%     xlabel('Frequency (Hz)')
%     ylabel('Power')
%     saveas(gcf,fftname,'fig')
%     close(gcf)
    
    all_avg_fft(j,:)=mean_fft;
    all_se_fft(j,:)=se_fft;
    
end

save([cond_listname(1:end-5),'_avg_fft.mat'],'all_avg_fft','all_se_fft')

% for j=1:cond_num
%     
%     figure(j)
% 
%     plot(f,all_avg_fft(j,:))
% 
% end
% 
% figure_replotter_line(length(f),1:cond_num,subplot_dims(1),subplot_dims(2),cond_labels,[]);
% saveas(gcf,[cond_listname(1:end-5),'_avg_fft.fig'])
% saveas(gcf,[cond_listname(1:end-5),'_avg_fft.pdf'])