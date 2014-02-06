function collect_MI_Bernat

present_dir=pwd;

[listname,listpath]=uigetfile('*list','Choose a list of files to collect modulation index.');

[subjects,epoch_files,MI_files]=textread([listpath,listname],'%s%s%s');
subj_num=length(subjects);

subjects_fid=fopen([listpath,listname(1:end-5),'_subjects.txt'],'w');
periods_fid=fopen([listpath,listname(1:end-5),'_periods.txt'],'w');
MI_fid=fopen([listpath,listname(1:end-5),'_MI.txt'],'w');

MI_format=make_format(length(1:.25:12)*length(20:5:200),'f');

% fprintf(subjects_fid,'%s\n','subject');
% fprintf(states_fid,'%s\n','state');
% fprintf(MI_fid,MI_format,f');

for i=1:subj_num
    
    subject=char(subjects{i});
    
    periods=textread(char(epoch_files(i)),'%*d%s%*[^\n]');
    data=load(char(MI_files(i)));
        
    [no_epochs,~]=size(data);
    
    for j=1:no_epochs
%     for j=(end_epoch-359):min(end_epoch,no_epochs)

        fprintf(subjects_fid,'%s\n',subject);
    
        fprintf(periods_fid,'%s\n',char(periods{j}));
               
        fprintf(MI_fid,MI_format,data(j,:));
        
    end
    
    cd (present_dir)
            
end

fclose('all');