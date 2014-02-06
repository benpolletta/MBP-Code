function write_bouts_Bernat(subject,channels,varargin)

state_order={'R','W','NR'};

% Defaults.
periods=[];
pd_labels_given=0;
states={'R'};
drugs={'MK801','NVP','Ro25','saline'};

% Changing defaults.
for i=1:floor(length(varargin)/2)
    if strcmp(varargin(2*i-1),'periods')==1
        periods=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'states')==1
        states=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'drugs')==1
        drugs=varargin(2*i);
        drugs=drugs{1};
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

data_pts_per_epoch=4096*4;
sampling_rate=250*4;
seconds_per_epoch=data_pts_per_epoch/sampling_rate;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

no_drugs=length(drugs);
no_states=length(states);
no_channels=length(channels);
   
for d=1:no_drugs
    
    record_name=[char(subject),'_',char(drugs{d})];
    
    [~,R,~,NR]=textread([record_name,'_VS_no_header.txt'],'%s%d%d%d%*[^\n]');
    NR(R==1)=0;
    W=ones(size(R));
    W(R==1)=0;
    W(NR==1)=0;
    VS=[R W NR];
    no_epochs=length(VS);
    
    for c=1:no_channels
        
        channel=channels(c);
        channel_name=[record_name,'_chan',num2str(channel)];
        
        for s=1:no_states
            
            state=char(states(s));
            
            state_name=[channel_name,'_',state];
            
            for p=1:no_periods
                
                pd_label=char(pd_labels{p});
                
                list_name=[channel_name,'_',state,'_',pd_label,'_bouts.list'];
                list_fid=fopen(list_name,'w');
                
                start_epoch=periods(p,1);
                end_epoch=periods(p,2);
                
                pd_state_val=VS(max(start_epoch,1):min(end_epoch,no_epochs),strcmp(state_order,state));
                start_epochs=find(diff(pd_state_val)==1)+max(start_epoch,1);    
                end_epochs=find(diff(pd_state_val)==-1)+max(start_epoch,1)-1;
                end_epochs=end_epochs(end_epochs>min(start_epochs));
                start_epochs=start_epochs(start_epochs<max(end_epochs));
                
                bouts=[start_epochs end_epochs];
                bout_lengths=end_epochs-start_epochs+1;
                
                for b=1:length(bouts)
                    
                    bout_name=[list_name(1:end-6),num2str(b)];
                    bout_list_fid=fopen([bout_name,'.list'],'w');
                    bout_file_fid=fopen([bout_name,'.txt'],'w');
                    fprintf(list_fid,'%s\n',[bout_name,'.txt']);
                    
                    bout_data=zeros(bout_lengths(b)*data_pts_per_epoch,1);
                    
                    for e=1:bout_lengths(b)
                    
                        epoch_name=[channel_name,'_epoch',num2str(bouts(b,1)+e-1),'.txt'];
                                                
                        fprintf(bout_list_fid,'%s\n',epoch_name);
                        
                        epoch_data=load(['../',record_name,'/',epoch_name]);
                        bout_data(((e-1)*data_pts_per_epoch+1):e*data_pts_per_epoch)=epoch_data;
                        
                    end
                    
                    plot([1:length(bout_data)]/sampling_rate,bout_data)
                    saveas(gcf,[bout_name,'.fig'])
                    close(gcf)
                    
                    fprintf(bout_file_fid,'%f\n',bout_data);
                    
                    fclose(bout_list_fid); fclose(bout_file_fid);
                                        
                end
                                
                fclose(list_fid);
                
            end
            
        end
                
    end
    
end