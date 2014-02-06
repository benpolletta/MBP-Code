function collect_PAC_params_Satvinder

present_dir=pwd;

[listname,listpath]=uigetfile('*PAC_params.list','Choose a list of files to collect amplitude vs. phase plots.');

[subjects,epoch_files,AVP_files]=textread([listpath,listname],'%s%s%s');
subj_num=length(subjects);

subjects_fid=fopen([listpath,listname(1:end-5),'_subjects.txt'],'w');
states_fid=fopen([listpath,listname(1:end-5),'_states.txt'],'w');
PAC_params_fid=fopen([listpath,listname(1:end-5),'_PAC_params.txt'],'w');

PAC_params_format=make_format(4,'f');

% fprintf(subjects_fid,'%s\n','subject');
% fprintf(states_fid,'%s\n','state');
% fprintf(AVP_fid,AVP_format,f');

for i=1:subj_num
    
    subject=char(subjects{i});
    
    cd (subject)
    
    states=textread(char(epoch_files(i)),'%*s%d');
%     fid_subj_AVP=fopen(char(AVP_files(i)),'r');
%     PAC_params=textscan(fid_subj_AVP,'%*f%*f%f%f%f%f');
    [maxMI,pref_fa,pref_fp,pref_phase]=textread(char(AVP_files(i)),'%*f%*f%f%f%f%f%*[^\n]','headerlines',1,'bufsize',2^20);
    PAC_params=[pref_fp pref_phase pref_fa maxMI];
%     data=data.AVP_all;
        
    [no_epochs,~]=size(PAC_params);
    
    for j=1:no_epochs
%     for j=(end_epoch-359):min(end_epoch,no_epochs)

        fprintf(subjects_fid,'%s\n',subject);
 
    end
    
    fprintf(states_fid,'%d\n',states);
    
    fprintf(PAC_params_fid,PAC_params_format,PAC_params');
    
    cd (present_dir)
    
%     fclose(fid_subj_AVP)
    
end

fclose('all');