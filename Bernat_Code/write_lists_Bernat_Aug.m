function write_lists_Bernat_11_13(subject,channels,list_label,varargin)

% Sample call:  write_lists_Bernat('A99',4,[-4 0;0 4;4
% 8],{'pre','post1to4','post5to8'}).

state_order={'R','W','NR'};

% Defaults.
periods=[];
pd_labels_given=0;
states={'R','W','NR'};
drugs={'MK801','NVP','Ro25','saline'};


% Changing defaults.
for i=1:floor(length(varargin)/2)
    if strcmp(varargin(2*i-1),'periods')==1
        periods=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'states')==1
        states=varargin(2*i);
        states=states{1};
    elseif strcmp(varargin(2*i-1),'drugs')==1
        drugs=varargin(2*i);
        drugs=drugs{1};
        if ischar(drugs)
            drugs=cellstr(drugs);
        end
    elseif strcmp(varargin(2*i-1),'pd_labels')==1
        pd_labels=varargin(2*i);
        pd_labels=pd_labels{1};
        pd_labels_given=1;
    end
end

if isempty(periods)
    periods=[1,inf];
    pd_labels={'all'};
    pd_labels_given=1;
end

[no_periods,cols]=size(periods);
if cols~=2
    if no_periods==2
        periods=periods';
        [no_periods,~]=size(periods);
    else
        display('periods must have two rows or two columns.')
        return
    end
end

if pd_labels_given==0
    for p=1:no_periods
        pd_labels{p}=['epochs',num2str(periods(p,1)),'to',num2str(periods(p,2))];
    end
end

% data_pts_per_epoch=4096;
% sampling_rate=250;
% seconds_per_epoch=data_pts_per_epoch/sampling_rate;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

no_drugs=length(drugs);
no_states=length(states);
no_channels=length(channels);

for d=1:no_drugs
    
    record_name=[char(subject),'_',char(drugs{d})];
    
    [R,NR] = text_read([record_name,'_VS_no_header.txt'],'%*s%d%*d%d');
    NR(R==1)=0;
    W=ones(size(R));
    W(R==1)=0;
    W(NR==1)=0;
    VS=[R W NR];
    no_epochs=length(VS);
    
    for c=1:no_channels
        
        channel=channels(c);
        channel_name=[record_name,'_chan',num2str(channel)];
        %         master_list_fid=fopen([channel_name,'_',list_label,'_master.list'],'w');
        epochs_fid=fopen([channel_name,'_',list_label,'_epochs.list'],'w');
        
        for p=1:no_periods
            
            start_epoch=max(periods(p,1),1);
            end_epoch=min(periods(p,2),no_epochs);
            %                 start_epoch=ceil(inj_epochs(d)+periods(1,p)*epochs_per_hour+1);
            %                 end_epoch=floor(inj_epochs(d)+periods(2,p)*epochs_per_hour);
            
            epoch_indices=[start_epoch:end_epoch];
            
            if ~isempty(epoch_indices)
                
                pd_label=char(pd_labels{p});
                
                %                     list_name=[channel_name,'_',pd_label,'.list'];
                %                     list_fid=fopen(list_name,'w');
                %                     fprintf(master_list_fid,'%s\n',list_name);
                
                for e=1:length(epoch_indices)
                    
                    epoch_name=[channel_name,'_epoch',num2str(round(epoch_indices(e))),'.txt'];
                    epoch_state=char(state_order{VS(e,:)==1});
                    
                    %                         fprintf(list_fid,'%s\n',epoch_name);
                    fprintf(epochs_fid,'%d\t%s\t%s\t%s\n',epoch_indices(e),pd_label,epoch_state,epoch_name);
                    
                end
                
%                 fclose(list_fid);
                
            end
            
        end
        
    end
    
end