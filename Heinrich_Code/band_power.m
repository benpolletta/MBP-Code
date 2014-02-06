function [BP]=band_power(sampling_freq,signal_length)

[listname,listpath]=uigetfile('*list','Choose a list of files to calculate band power.')

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

BP=zeros(filenum,5);

f=sampling_freq*[1:signal_length/2]/(signal_length);

band_limits=[.1 4 12 40 100 200];

for i=1:5
    band_indices{i}=find(band_limits(i)<=f & f<=band_limits(i+1));
end

band_labels={'delta','theta','alpha/beta','low gamma','high gamma'};

for i=1:filenum
    
    filename=char(filenames(i));
    data=load(filename);
    data=data(:,3)';
    
    data_hat=fft(data);
    
    for j=1:5
        
        BP(i,j)=sum(abs(data_hat(band_indices{j})).^2);
    
    end
    
end

fid=fopen([listname(1:end-5),'_band_power.txt'],'w');
fprintf(fid,'%f\n',BP');
fclose(fid);

figure()
boxplot(BP)
title(['Band Power for ',listname])
set(gca,'XTickLabel',band_labels)
xlabel('Band')
ylabel('Power')
saveas(gcf,[listname(1:end-5),'_band_power.fig'])