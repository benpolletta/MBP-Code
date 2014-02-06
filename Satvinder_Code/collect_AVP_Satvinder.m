function collect_AVP_Satvinder

present_dir=pwd;

[listname,listpath]=uigetfile('*list','Choose a list of files to collect amplitude vs. phase plots.');

[subjects,epoch_files,AVP_files]=textread([listpath,listname],'%s%s%s');
subj_num=length(subjects);

subjects_fid=fopen([listpath,listname(1:end-5),'_subjects.txt'],'w');
states_fid=fopen([listpath,listname(1:end-5),'_states.txt'],'w');
AVP_fid=fopen([listpath,listname(1:end-5),'_AVP.txt'],'w');

AVP_format=make_format(33*20,'f');

% fprintf(subjects_fid,'%s\n','subject');
% fprintf(states_fid,'%s\n','state');
% fprintf(AVP_fid,AVP_format,f');

for i=1:subj_num
    
    subject=char(subjects{i});
    
    cd (subject)
    
    states=textread(char(epoch_files(i)),'%*s%d');
    data=load(char(AVP_files(i)));
    data=data.AVP_all;
        
    [no_epochs,~]=size(data);
    
    for j=1:no_epochs
%     for j=(end_epoch-359):min(end_epoch,no_epochs)

        fprintf(subjects_fid,'%s\n',subject);
    
        fprintf(states_fid,'%d\n',states(j));
               
        fprintf(AVP_fid,AVP_format,data(j,:));
        
    end
    
    cd (present_dir)
            
end

fclose('all');