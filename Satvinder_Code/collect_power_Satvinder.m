function collect_power_Satvinder(sampling_freq,signal_length)

present_dir=pwd;

[listname,listpath]=uigetfile('*list','Choose a list of files to collect spectral power.');

[subjects,states,filenames,end_epochs]=textread([listpath,listname],'%s%s%s%d');
filenum=length(filenames);

subjects_fid=fopen([listpath,listname(1:end-5),'_subjects.txt'],'w');
states_fid=fopen([listpath,listname(1:end-5),'_states.txt'],'w');
pow_fid=fopen([listpath,listname(1:end-5),'_pow.txt'],'w');

f=sampling_freq*[0:signal_length/2]/(signal_length);
no_freqs=length(f);

% Pow=zeros(filenum*48*60*6,no_freqs);

pow_format=make_format(no_freqs,'f');

fprintf(subjects_fid,'%s\n','subject');
fprintf(states_fid,'%s\n','state');
fprintf(pow_fid,pow_format,f');

for i=1:filenum
    
%     end_epoch=end_epochs(i);
    
    cd (char(subjects(i)))
    
    filename=char(filenames(i));
    data=load(filename);
    data=data.all_fft;
    total_power=sum(data,2);
    
    [no_epochs,~]=size(data);
    
    for j=1:no_epochs
%     for j=(end_epoch-359):min(end_epoch,no_epochs)

        fprintf(subjects_fid,'%s\n',char(subjects{i}));
    
        fprintf(states_fid,'%s\n',char(states{i}));
               
        fprintf(pow_fid,pow_format,data(j,:)/total_power(j));
        
    end
    
    cd (present_dir)
        
end

fclose('all');