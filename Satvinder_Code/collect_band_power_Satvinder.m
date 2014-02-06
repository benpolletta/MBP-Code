function [BP]=collect_power_Satvinder(sampling_freq,signal_length);

present_dir=pwd;

[listname,listpath]=uigetfile('*list','Choose a list of files to calculate band power.')

[subjects,states,filenames,end_epochs]=textread([listpath,listname],'%s%s%s%d');
filenum=length(filenames);

altogether_fid=fopen([listpath,listname(1:end-5),'_bp.txt'],'w');

BP=zeros(filenum,5);

f=sampling_freq*[1:signal_length/2]/(signal_length);

band_limits=[.1 4 8 12 40 100 200];
no_bands=length(band_limits)-1;

band_labels={'delta','theta','alpha','beta','gamma','HFO'};

fprintf(altogether_fid,'%s\t%s\t','subject','state');

for i=1:no_bands
    band_indices{i}=find(band_limits(i)<=f & f<=band_limits(i+1));
    fprintf(altogether_fid,'%s\t',band_labels{i});
end

fprintf(altogether_fid,'%s\n','');

band_format=make_format(no_bands,'f');

for i=1:filenum
    
    end_epoch=end_epochs(i);
    
    cd (char(subjects(i)))
    
    filename=char(filenames(i));
    data=load(filename);
    data=data.all_fft;
    total_power=sum(data,2);
    
    [no_epochs,fft_length]=size(data);
    
    for j=1:no_epochs
%     for j=(end_epoch-359):min(end_epoch,no_epochs)
        
        fprintf(altogether_fid,'%s\t%s\t',char(subjects{i}),char(states{i}));
        
        for k=1:no_bands
        
            BP(j,k)=sum(abs(data(j,band_indices{k})))/total_power(j);
    
        end
        
        fprintf(altogether_fid,band_format,BP(j,:));
        
    end
    
    cd (present_dir)
        
end