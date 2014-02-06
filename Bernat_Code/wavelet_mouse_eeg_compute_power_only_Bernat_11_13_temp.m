function wavelet_mouse_eeg_compute_power_only_Bernat_11_13(subject,channel)

close('all')

% Setting up information about periods (time since injection).

period_hrs=[-4 0;0 4;4 8;8 12;12 16];

sampling_freq=1000;
seconds_per_epoch=4096/250;
signal_length=sampling_freq*seconds_per_epoch;
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

% Parameters for FFT & band power.

f=sampling_freq*[0:signal_length/2]/(signal_length);
% no_freqs=length(f);

f_bins=sampling_freq*(1:2^10)/(2^11);
f_bins=f_bins(f_bins<=200);
no_f_bins=length(f_bins);

% f_bins=sampling_freq*logspace(log10(1/signal_length),log10(sampling_freq/2),21)/(signal_length);
% f_bin_centers=f_bins(1:end-1)+diff(f_bins);
% no_f_bins=length(f_bin_centers);
% for i=1:no_f_bins     
%     f_bin_indices{i}=find(f>=f_bins(i) & f<=f_bins(i+1));
% end

spec_format=make_format(no_f_bins+1,'f');

% band_limits=[.1 4; 4 8; 10 13; 15 30; 30 59; 61 110; 125 175];
% band_labels={'delta','theta','alpha','beta','low-gamma','high-gamma','HFOs'};
% band_labels_long={'Delta','Theta','Alpha','Beta','Low Gamma','High Gamma','HFO'};

% band_limits=[20 50; 50 90; 90 120];
% band_labels={'low-gamma','middle-gamma','high-gamma'};
% band_labels_long={'Low Gamma','Middle Gamma','High Gamma'};

band_limits=[.1 4; 4 8; 10 13; 13 20; 20 50; 50 90; 90 120; 125 175];
band_labels={'delta','theta','alpha','low-beta','beta-low-gamma','mid-gamma','high-gamma','HFOs'};

[no_bands,~]=size(band_limits);

band_indices=cell(no_bands,1);
band_freq_labels=cell(no_bands,1);
for i=1:no_bands
    band_indices{i}=find(f>=band_limits(i,1) & f<=band_limits(i,2));
    band_freq_labels{i}=[band_labels{i},num2str(band_limits(i,1)),'-',num2str(band_limits(i,2))];
end
    
BP_format=make_format(no_bands+1,'f');

% Parameters for blocking out line noise.

line_noise_limits=[59 61; 118 122];

[no_stops,~]=size(line_noise_limits);

stop_indices=cell(no_stops,1);
for i=1:no_stops
    stop_indices{i}=find(f>=line_noise_limits(i,1) & f<=line_noise_limits(i,2));
end

% Setting up directory to save files.

all_dirname=['ALL_',subject,'_chan',num2str(channel)];
mkdir (all_dirname)

% Working with different drugs.

drugs={'saline','MK801','NVP','Ro25'};
no_drugs=length(drugs);

for d=4:no_drugs
    
    record_dir=[subject,'_',drugs{d}];
    
    channel_name=[subject,'_',drugs{d},'_chan',num2str(channel)];
    channel_dir=[channel_name,'_epochs'];
        
    epoch_list=[channel_name,'_4hrs_by_state_epochs.list'];
    hrs_list=[channel_name,'_hours_epochs.list'];

    [fourhrs,states,epoch_names]=textread([record_dir,'/',channel_dir,'/',epoch_list],'%*d%s%s%s%*[^\n]');
    hrs=textread([record_dir,'/',channel_dir,'/',hrs_list],'%*d%s%*[^\n]');
%     no_epochs=length(epoch_names);

    start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
    start_epochs=max(start_epochs,1);
    
    end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
    end_epochs=min(end_epochs,number_epochs(d));
    
    drug_states=states(start_epochs(1):end_epochs(end));
    drug_fourhrs=fourhrs(start_epochs(1):end_epochs(end));
    drug_hrs=hrs(start_epochs(1):end_epochs(end));
    drug_epoch_names=epoch_names(start_epochs(1):end_epochs(end));

    total_epochs=end_epochs(end)-start_epochs(1)+1;
    
    % Opening files to save collected data.
    
    all_filename=['ALL_',epoch_list(1:end-length('_4hrs_by_state_epochs.list'))];
    
    measures={'spec_pow','band_pow'};
    no_measures=length(measures);
    
    fid_states_pds=fopen([all_dirname,'/',all_filename,'_states_pds.txt'],'w');
  
    fid_vec=zeros(no_measures,1);
    for i=1:no_measures
        fid_vec(i)=fopen([all_dirname,'/',all_filename,'_',measures{i},'.txt'],'w');
%         fprintf(fid_vec(i),'%s\t%s\t','epoch','state');
    end

%     fid_BP=fopen([all_dirname,'/',all_filename,'_band_pow.txt'],'w');
    
%     fprintf(fid_vec(1),make_format(no_f_bins,'f'),f);
    
    for i=1:no_bands
        fprintf(fid_vec(2),'%s\t',band_freq_labels{i});
    end
    fprintf(fid_vec(2),'%s\n','');
    
    spec_all=zeros(total_epochs,no_f_bins);
    BP_all=zeros(total_epochs,no_bands);
    
    for j=1:total_epochs
        
        fprintf(fid_states_pds,'%s\t%s\t%s\n',char(drug_states(j)),char(drug_hrs(j)),char(drug_fourhrs(j)));
        
    end

    %% COMPUTING POWER & BAND POWER BY EPOCH.
    
    parfor j=1:total_epochs
        
%         data_spec=zeros(1,no_f_bins);
       
        BP=zeros(1,no_bands);
                
%         local_f_bin_indices=f_bin_indices;
        
        local_band_indices=band_indices;
        
        local_stop_indices=stop_indices;
        
        epoch_name=char(drug_epoch_names(j));
        
        data=load([record_dir,'/',epoch_name]);
        data=detrend(data);
        
        data_hat=pmtm(data,[],signal_length);

        for i=1:no_stops
            
            data_hat(local_stop_indices{i})=nan;
            
        end

        data_spec=nanmean(reshape(data_hat(2:end),8,(length(data_hat)-1)/8));
        
        spec_all(j,:)=data_spec(1:no_f_bins);
        
        for i=1:no_bands
            
            BP(i)=nansum(data_hat(local_band_indices{i}));
            
        end
                
        BP_all(j,:)=BP;
        
    end

    %% SAVING POWER & BAND POWER.
    
    fprintf(fid_vec(1),spec_format,[(start_epochs(1):end_epochs(end))' spec_all]');
    fprintf(fid_vec(2),BP_format,[(start_epochs(1):end_epochs(end))' BP_all]');
    
    fclose('all');
    
    save([all_dirname,'/',all_filename,'_spec.mat'],'spec_all')
    save([all_dirname,'/',all_filename,'_BP.mat'],'band_limits','band_labels','BP_all')
    
end