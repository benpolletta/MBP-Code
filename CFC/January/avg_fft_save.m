function [all_avg_fft,all_se_fft]=avg_fft_save(cond_listname,sampling_freq,signal_length,cond_labels,subplot_dims)

close('all')

if isempty(cond_listname)
    
    [cond_listname,listpath]=uigetfile('*list','Choose a list of condition lists to fft.');

else
    
    listpath=pwd;
    listpath=[listpath,'/'];
    
end

cond_lists=textread([listpath,cond_listname],'%s');
cond_num=length(cond_lists);

f=sampling_freq*([1:signal_length/2+1]-1)/(signal_length);
format=make_format(signal_length/2+1,'f');

all_avg_fft=nan(cond_num,signal_length/2+1);
all_se_fft=nan(cond_num,signal_length/2+1);

for j=1:cond_num
    
    listname=char(cond_lists(j));
    fftname=[listname(1:end-5),'_avg_fft'];
    
    filenames=textread([listpath,listname],'%s');
    filenum=length(filenames);
    
    all_fft=zeros(filenum,signal_length/2+1);

    parfor i=1:filenum

        filename=char(filenames(i));
                
        data=load(['../',filename]);
        data=data';
        data=detrend(data);

%         data_hat(i,:)=fft(data(:,3));
        data_hat=pmtm(data,[],signal_length);
        
        all_fft(i,:)=data_hat';
        
    end
    
    fid=fopen([fftname,'.txt'],'w');
    fprintf(fid,format,f);
    fprintf(fid,format,all_fft');
    fclose(fid);
    
    save([fftname,'.mat'],'all_fft')
    
    mean_fft=nanmean(all_fft);
    se_fft=nanstd(all_fft)/sqrt(filenum);
    
    figure(j)
    loglog(f,mean_fft,'k')
    hold on
    loglog(f,mean_fft+se_fft,'-k')
    loglog(f,mean_fft-se_fft,'-k')
    title(['Avg. FFT for ',listname])
    xlabel('Frequency (Hz)')
    ylabel('Power')
    saveas(gcf,fftname,'fig')
    close(gcf)
    
    all_avg_fft(j,:)=mean_fft;
    all_se_fft(j,:)=se_fft;
    
end

save([cond_listname(1:end-5),'_avg_fft.mat'],'all_avg_fft','all_se_fft')

for j=1:cond_num
    
    figure(j)

    plot(f,all_avg_fft(j,:))

end

figure_replotter_line(length(f),1:cond_num,subplot_dims(1),subplot_dims(2),cond_labels,[]);
saveas(gcf,[cond_listname(1:end-5),'_avg_fft.fig'])
saveas(gcf,[cond_listname(1:end-5),'_avg_fft.pdf'])

% figure_replotter_line(length(f),1:cond_num,4,3,cond_labels,[20 110]);
% saveas(gcf,[cond_listname(1:end-5),'_gamma.fig'])
% saveas(gcf,[cond_listname(1:end-5),'_gamma.pdf'])
% 
% figure_replotter_line(length(f),1:cond_num,4,3,cond_labels,[125 175]);
% saveas(gcf,[cond_listname(1:end-5),'_HFO.fig'])
% saveas(gcf,[cond_listname(1:end-5),'_HFO.pdf'])