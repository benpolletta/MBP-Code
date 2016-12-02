function wavelet_mouse_eeg_write_power_lists_only(subject,channel)

% Taken from wavelet_mouse_eeg_computer_power_only_Bernat_11_13.

close('all')

%% Setting up information about periods (time since injection).

period_hrs=[-4 0;0 4;4 8;8 12;12 16];

sampling_freq=1000;
seconds_per_epoch=4096/250;
epochs_per_min=60/seconds_per_epoch;
epochs_per_hour=60*60/seconds_per_epoch;

if strcmp(subject,'A99') || strcmp(subject,'A102')
    inj_epochs=floor([3*60 5*60+7 2*60+35 5*60+7]*epochs_per_min);
    number_epochs=[4938 5236 4881 7354];
elseif strcmp(subject,'A103') || strcmp(subject,'A104')
    inj_epochs=[813 733 1293 1125];
    number_epochs=[5449 4782 5703 5107];
elseif strcmp(subject,'A105') || strcmp(subject,'A106')
    inj_epochs=floor([5*60+7 4*60+42 2*60+53 5*60+7]*epochs_per_min);
    number_epochs=[4313 5006 4541 5736];
end

%% Setting up directory to save files.

all_dirname=['ALL_',subject,'_chan',num2str(channel)];
mkdir (all_dirname)

% Looping over drugs.

drugs={'saline','MK801','NVP','Ro25'};
no_drugs=length(drugs);

for d=1:no_drugs
    
    record_dir=[subject,'_',drugs{d}];
    
    channel_name=[subject,'_',drugs{d},'_chan',num2str(channel)];
    channel_dir=[channel_name,'_epochs'];
        
    epoch_list=[channel_name,'_4hrs_by_state_epochs.list'];
    hrs_list=[channel_name,'_hours_epochs.list'];
    sixmins_list=[channel_name,'_6mins_epochs.list'];
    
    [fourhrs,states,epoch_names]=text_read([record_dir,'/',channel_dir,'/',epoch_list],'%*d%s%s%s%*[^\n]');
    hrs=text_read([record_dir,'/',channel_dir,'/',hrs_list],'%*d%s%*[^\n]');
    sixmins=text_read([record_dir,'/',channel_dir,'/',sixmins_list],'%*d%s%*[^\n]');

    start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
    start_epochs=max(start_epochs,1);
    
    end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
    end_epochs=min(end_epochs,number_epochs(d));
    
    drug_states=states(start_epochs(1):end_epochs(end));
    drug_fourhrs=fourhrs(start_epochs(1):end_epochs(end));
    drug_hrs=hrs(start_epochs(1):end_epochs(end));
    drug_sixmins=sixmins(start_epochs(1):end_epochs(end));

    total_epochs=end_epochs(end)-start_epochs(1)+1;
    
    %% Opening files to save lists.
    
    all_filename=['ALL_',epoch_list(1:end-length('_4hrs_by_state_epochs.list'))];
    
    fid_states_pds=fopen([all_dirname,'/',all_filename,'_states_pds.txt'],'w');
    
    for j=1:total_epochs
        
        fprintf(fid_states_pds,'%s\t%s\t%s\t%s\n',char(drug_states(j)),char(drug_hrs(j)),char(drug_fourhrs(j)),char(drug_sixmins(j)));
        
    end
    
end