function [MI_all]=wavelet_mouse_eeg_collect_Bernat_multisummed(subject,channel,amp_limits,phase_limits)

% UNFINISHED.
% amp_limits and phase_limits are n by two matrices containing limits on
% amplitude and phase frequencies, respectively.

close('all')

bands_lo=4:.25:12;
bands_hi=20:5:180;

noamps=length(bands_lo);
nophases=length(bands_hi);

[no_limits,~]=size(amp_limits);
[rows,~]=size(phase_limits);

if no_limits~=rows
    display('amp_limits and phase_limits are n by two matrices containing limits on amplitude and phase frequencies, respectively.')
    return
end

for i=1:no_limits
    band_labels{i}=[num2str(amp_limits(i,1)),'to',num2str(amp_limits(i,2)),'by',num2str(phase_limits(i,1)),'to',num2str(phase_limits(i,2))];
end

present_dir=pwd;

% Setting up information about periods (time since injection).

period_hrs=[-4 0;0 4;4 8];
[no_periods,~]=size(period_hrs);

period_labels={'pre','post1to4','post5to8'};

data_pts_per_epoch=4096;
sampling_rate=250;
seconds_per_epoch=data_pts_per_epoch/sampling_rate;
epochs_per_min=60/seconds_per_epoch;
epochs_per_hour=60*60/seconds_per_epoch;

inj_epochs=floor([5*60+7 2*60+35 5*60+7 3*60]*epochs_per_min);
% total_epochs=[5236 4881 7354 4938];

% Setting up information about different states.

states={'R','NR','AW'};
no_states=length(states);

for i=1:no_states
    state_dirs{i}=[char(subject),'_chan',num2str(channel),'_',char(states(i))];
end

% Working with different drugs.

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

for d=1:no_drugs
    
    data_dir=[subject,'_',drugs{d},'_chan',num2str(channel)];
        
    epoch_list=[data_dir,'_epochs.list'];

    [epoch_names,epoch_states]=textread([data_dir,'/',epoch_list],'%s%d%*[^\n]');
    no_epochs=length(epoch_names);

    start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
    end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
    
    % Setting up files & dirs for different measures of PAC.
    
    measures={'IE','canMI','PLV'};
    no_measures=length(measures);
    
    all_dirname=['ALL_',epoch_list(1:end-5)];
    mkdir (all_dirname)
    
    for i=1:no_measures
        fid_vec(i)=fopen([all_dirname,'/',all_dirname,'_',measures{i},'_',band_labels,'.txt'],'w');
        fprintf(fid_vec(i),'%s\t%s\t%s\n','epoch','state',band_labels);
    end
        
    MI_all=zeros(no_epochs,no_sums);
    canolty_all=zeros(no_epochs,no_sums);
    PLV_all=zeros(no_epochs,no_sums);

    % Retrieving PAC measures epoch by epoch.
    
    for p=1:no_periods

        for j=max(start_epochs(p),1):end_epochs(p)
            
            epoch_state=epoch_states(j);
            
%             if epoch_state<no_states
            
            state_dir=state_dirs{epoch_state};
            
            period_dir=[state_dir,'_',char(drugs{d}),'_',period_labels{p}];
            
            MI_struct=struct('name','MI_struct');
            
            %         dir_name=char(condition_dirs{epoch_state+1});
            state_dir=char(state_dirs{epoch_state});
            
            epoch_name=char(epoch_names(j));
            epoch_name=epoch_name(1:end-4);
            
            filenames{1}=[state_dir,'/',period_dir,'/',epoch_name,'_IE.mat'];
            filenames{2}=[state_dir,'/',period_dir,'/',period_dir,'_canolty/',epoch_name,'_canolty_MI.mat'];
            filenames{3}=[state_dir,'/',period_dir,'/',period_dir,'_PLV/',epoch_name,'_PLV.mat'];
            
            for i=1:no_measures
                
                MI=load(char(filenames{i}),'MI');
                MI=MI.MI;
                MI=reshape(MI,1,noamps*nophases);
                
                MI_struct=setfield(MI_struct,char(measures{i}),MI);
                
                fprintf(fid_vec(i),format,[j epoch_state MI]);
                
            end
            
            MI_all(j,:)=MI_struct.IE;
            canolty_all(j,:)=MI_struct.canMI;
            PLV_all(j,:)=MI_struct.PLV;
                
%             else
%                 
%                 MI_all(j,:)=nan(1,noamps*nophases);
%                 canolty_all(j,:)=nan(1,noamps*nophases);
%                 PLV_all(j,:)=nan(1,noamps*nophases);
%                 
%             end
        
        end
            
    end
    
    fclose('all');
    
    save([all_dirname,'/',all_dirname,'_IE.mat'],'MI_all')
    save([all_dirname,'/',all_dirname,'_canMI.mat'],'canolty_all')
    save([all_dirname,'/',all_dirname,'_PLV.mat'],'PLV_all')
    
    cd (present_dir);

end