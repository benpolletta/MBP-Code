function [BP]=band_power(listname,sampling_freq,signal_length,band_limits,band_labels)

% band_limits is 2 by n, where n is the number of bands, and the first row
% is the low frequency limit, and the second row is the high frequency
% limit.

if isempty(listname)
    
    [listname,listpath]=uigetfile('*list','Choose a list of condition lists to fft.');

else
    
    listpath=pwd;
    
end

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

BP=zeros(filenum,5);

f=sampling_freq*[1:signal_length/2]/(signal_length);

[no_bands,cols]=size(band_limits);

if cols~=2
    display('band_limits is 2 by n, where n is the number of bands, and the first row is the low frequency limit, and the second row is the high frequency limit.')
    return
end

for i=1:no_bands
    band_indices{i}=find(band_limits(i,1)<=f & f<=band_limits(i,2));
end

format=make_format(no_bands,'f');

fid=fopen([listname(1:end-5),'_band_power.txt'],'w');

fprintf(fid,['%s\t%s\t',format],'epoch_name','state',f);

for i=1:filenum
    
    filename=char(filenames(i));
    data=load(filename);
    data=data(:,3)';
    
    data_hat=pmtm(data,[],signal_length);
    
    for j=1:no_bands
        
        BP(i,j)=sum(abs(data_hat(band_indices{j})).^2);
    
    end
    
end



fprintf(fid,'%f\n',BP');

fclose(fid);

figure()
boxplot(BP)
title(['Band Power for ',listname])
set(gca,'XTickLabel',band_labels)
xlabel('Band')
ylabel('Power')
saveas(gcf,[listname(1:end-5),'_band_power.fig'])