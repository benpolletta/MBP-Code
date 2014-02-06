function collect_MI_Satvinder

present_dir=pwd;

[listname,listpath]=uigetfile('*list','Choose a list of files to collect modulation index.');

[subjects,epoch_files,MI_files]=textread([listpath,listname],'%s%s%s');
subj_num=length(subjects);

subjects_fid=fopen([listpath,listname(1:end-5),'_subjects.txt'],'w');
states_fid=fopen([listpath,listname(1:end-5),'_states.txt'],'w');
MI_fid=fopen([listpath,listname(1:end-5),'_MI.txt'],'w');

MI_format=make_format(33*33,'f');

% fprintf(subjects_fid,'%s\n','subject');
% fprintf(states_fid,'%s\n','state');
% fprintf(MI_fid,MI_format,f');

for i=1:subj_num
    
    subject=char(subjects{i});
    
    cd (subject)
    
    states=textread(char(epoch_files(i)),'%*s%d');
    data=load(char(MI_files(i)));
    if isfield(data,'MI_all')
        data=data.MI_all;
    elseif isfield(data,'canolty_all')
        data=data.canolty_all;
    elseif isfield(data,'PLV_all')
        data=data.PLV_all;
    end
        
    [no_epochs,~]=size(data);
    
    for j=1:no_epochs
%     for j=(end_epoch-359):min(end_epoch,no_epochs)

        fprintf(subjects_fid,'%s\n',subject);
    
        fprintf(states_fid,'%d\n',states(j));
               
        fprintf(MI_fid,MI_format,data(j,:));
        
    end
    
    cd (present_dir)
            
end

fclose('all');