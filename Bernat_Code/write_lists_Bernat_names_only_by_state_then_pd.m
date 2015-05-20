function write_lists_Bernat_names_only_by_state_then_pd(subject,channel,periods_hrs,pd_labels)

% Sample call:  write_lists_Bernat('A99',4,[-4 0;0 4;4
% 8],{'pre','post1to4','post5to8'}).

[rows,no_periods]=size(periods_hrs);
if rows~=2
    if no_periods==2
        periods_hrs=periods_hrs';
        [~,no_periods]=size(periods_hrs);
    else 
        display('period_hrs must have two rows.')
        return
    end
end

data_pts_per_epoch=4096;
sampling_rate=250;
seconds_per_epoch=data_pts_per_epoch/sampling_rate;
epochs_per_min=60/seconds_per_epoch;
epochs_per_hour=60*60/seconds_per_epoch;

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);
inj_epochs=floor([5*60+7 2*60+35 5*60+7 3*60]*epochs_per_min);
total_epochs=[5236 4881 7354 4938];

states={'R','AW','NR'};
no_states=length(states);

for i=1:no_states
    
    state_dirs{i}=[char(subject),'_chan',num2str(channel),'_',char(states(i))];
    fid_state_vec(i)=fopen([char(state_dirs{i}),'/',char(state_dirs{i}),'_periods.list'],'w');
    
end
    
for d=1:no_drugs
    
    subj_name=[char(subject),'_',char(drugs{d})];
    
    [R,NR]=textread([record_name,'_VS_no_header.txt'],'%*s%d%*d%d');
    NR(R==1)=0;
    W=ones(size(R));
    W(R==1)=0;
    W(NR==1)=0;
    VS=[R W NR];
    no_epochs=length(VS);
    
    % OLD BAD way of getting vigilance states.
    % [~,R,W,NR]=textread([subj_name,'_VS_no_header.txt'],'%s%d%d%d%*[^\n]');
    % VS=[R W NR];
    % no_epochs=length(VS);
    
    for s=1:no_states
             
        state_dir=char(state_dirs{s});
        present_dir=pwd;
        cd (state_dir)
        
        fid_epochs_list=fopen([char(state_dirs{s}),'_epochs.list'],'w');
        
        for p=1:no_periods
            
            period_name=[state_dir,'_',char(drugs{d}),'_',char(pd_labels{p}),'.list'];
            
            fprintf(fid_state_vec(s),'%s\n',period_name);
            fid_period_list=fopen(period_name,'w');
                        
            start_epoch=ceil(inj_epochs(d)+periods_hrs(1,p)*epochs_per_hour+1);
            end_epoch=floor(inj_epochs(d)+periods_hrs(2,p)*epochs_per_hour);

            epoch_indices=find(VS(max(start_epoch,1):end_epoch,s)==1)+max(start_epoch,1)-1;
            
            for e=1:length(epoch_indices)
                
                epoch_name=[subj_name,'_chan',num2str(channel),'_epoch',num2str(round(epoch_indices(e))),'_',char(states{s}),'.txt'];
                
                fprintf(fid_period_list,'%s\n',epoch_name);
                
                fprintf(fid_epochs_list,'%s\n',epoch_name);
                
            end
            
        end
        
        fclose(fid_period_list); fclose(fid_epochs_list);
        
        cd (present_dir)
        
    end
    
end