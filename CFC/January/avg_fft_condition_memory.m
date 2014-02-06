function all_avg_fft=avg_fft_condition_memory(cond_listname,sampling_freq,signal_length,cond_labels)

if isempty(cond_listname)
    
    [cond_listname,listpath]=uigetfile('*list','Choose a list of condition lists to fft.');

else
    
    listpath=pwd;
    
end

cond_lists=textread([listpath,'/',cond_listname],'%s');

cond_num=length(cond_lists);

f=sampling_freq*([1:signal_length/2+1]-1)/(signal_length);
% format=make_format(signal_length/2,'f');

all_avg_fft=nan(cond_num,signal_length/2+1);
% all_se_fft=nan(cond_num,signal_length/2+1);

for j=1:cond_num
    
    listname=char(cond_lists(j));
    fftname=[listname(1:end-5),'_avg_fft'];
%     fid=fopen([fftname,'.txt'],'w');
    
    filenames=textread([listpath,'/',listname],'%s');
    filenum=length(filenames);
    
    mean_fft=zeros(1,signal_length/2+1);

    parfor i=1:filenum

        filename=char(filenames(i));
        data=load(filename);
        data=data';

%         data_hat(i,:)=fft(data(:,3));
        data_hat=pmtm(data,[],signal_length);
        
        mean_fft=mean_fft+data_hat';
        
%         fprintf(fid,format,data_hat);
    end
    
    mean_fft=mean_fft/filenum;
    
    figure()
    loglog(f,mean_fft,'k')
    title(['Avg. FFT for ',listname])
    xlabel('Frequency (Hz)')
    ylabel('Power')
    saveas(gcf,fftname,'fig')
    
    all_avg_fft(j,:)=mean_fft;
    
end

figure()
plot(f,all_avg_fft')

xlabel('Frequency')
if nargin>2
    legend(cond_labels)
else
    legend(cond_lists)
end
saveas(gcf,[cond_listname(1:end-5),'_avg_fft.fig'])