function run_fft_Bernat

present_dir=pwd;

load('subjects.mat')
load('drugs.mat')
load('channels.mat')

for s=1:length(subjects)
    
    subject=subjects{s};
    subj_channels=channels{s};
    no_channels=length(subj_channels);
    
    for d=1:length(drugs)
        
        drug=drugs{d};
        
        subject_dir=[subject,'_',drug];
        cd (subject_dir)
        
        for c=1:no_channels
            
            drug_dir=pwd;
            
            channel=subj_channels(c);
            channel_dir=[subject_dir,'_chan',num2str(channel),'_epochs'];
            cd (channel_dir)
            
%             list_suffixes={'hours','4hrs_by_state'};
%             no_master_lists=length(list_suffixes);
%             
%             for l=1:no_master_lists
%                 
%                 challenge_list=[channel_dir(1:end-length('_epochs')),'_',list_suffixes{l},'_master.list'];
%                 lists=textread(challenge_list,'%s');
%                 no_lists=length(lists);
                
            challenge_list=[channel_dir(1:end-length('_epochs')),'_hours_master.list'];

            avg_fft_save(challenge_list,1000,4096*4);

            close('all')
                
%             end
            
            cd (drug_dir)
            
        end
        
        cd (present_dir)
        
    end
    
end