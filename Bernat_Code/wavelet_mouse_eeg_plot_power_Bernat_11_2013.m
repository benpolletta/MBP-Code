function wavelet_mouse_eeg_plot_power_Bernat_11_2013(subject,channel)

close('all')

present_dir=pwd;

% Setting up information about periods (time since injection).

period_hrs=[-4 0;0 4;4 8;8 12;12 16];

sampling_freq=1000;
seconds_per_epoch=4096/250;
signal_length=sampling_freq*seconds_per_epoch;
epochs_per_min=60/seconds_per_epoch;
epochs_per_hour=60*60/seconds_per_epoch;

if strcmp(subject,'A99') | strcmp(subject,'A102')
    inj_epochs=floor([3*60 5*60+7 2*60+35 5*60+7]*epochs_per_min);
    number_epochs=[7354 4938 5236 4881];
elseif strcmp(subject,'A103') | strcmp(subject,'A104')
    inj_epochs=[813 733 1293 1125];
    number_epochs=[5449 4782 5703 5107];
elseif strcmp(subject,'A105') | strcmp(subject,'A106')
    inj_epochs=floor([5*60+7 4*60+42 2*60+53 5*60+7]*epochs_per_min);
    number_epochs=[4313 5006 4541 5736];
end

% Setting up information about different states.

states={'R','NR','W'};
no_states=length(states);

state_labels={'Active Wake','NREM / Quiet Wake','REM','Injection'};
state_markers={'.r','.g','.b'};
state_sizes=[20 10 10];

states_rearranged=[2 3 1];

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
band_labels_long={'Delta','Theta','Alpha','Low Beta','Beta/Low Gamma','Middle Gamma','High Gamma','HFO'};

[no_bands,~]=size(band_limits);

for i=1:no_bands
    band_freq_labels{i}=[band_labels{i},num2str(band_limits(i,1)),'-',num2str(band_limits(i,2))];
    band_freq_labels_long{i}=[band_labels_long{i},' (',num2str(band_limits(i,1)),' to ',num2str(band_limits(i,2)),' Hz)'];
end
    
BP_format=make_format(no_bands+1,'f');
% BP_max=zeros(1,no_bands);

% Parameters for blocking out line noise.

line_noise_limits=[59 61; 118 122];

[no_stops,~]=size(line_noise_limits);

for i=1:no_stops
    stop_indices{i}=find(f>=line_noise_limits(i,1) & f<=line_noise_limits(i,2));
end

% Setting up directory to save files.

all_dirname=['ALL_',subject,'_chan',num2str(channel)];
mkdir (all_dirname)

% Working with different drugs.

drugs={'saline','MK801','NVP','Ro25'};
no_drugs=length(drugs);

BP_max=zeros(no_drugs,no_bands);

for d=1:no_drugs
    
    record_dir=[subject,'_',drugs{d}];
    
    channel_name=[subject,'_',drugs{d},'_chan',num2str(channel)];
    channel_dir=[channel_name,'_epochs'];
        
    epoch_list=[channel_name,'_4hrs_by_state_epochs.list'];

    epoch_states=textread([record_dir,'/',channel_dir,'/',epoch_list],'%*d%*s%s%*[^\n]');
%     no_epochs=length(epoch_names);

    start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
    start_epochs=max(start_epochs,1);
    
    end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
    end_epochs=min(end_epochs,number_epochs(d));
    
%     drug_epoch_names=epoch_names(start_epochs(1):end_epochs(end));
    drug_epoch_states=epoch_states(start_epochs(1):end_epochs(end));
%     
% %     epochs_per_period=end_epochs-start_epochs+1;
%     
    total_epochs=end_epochs(end)-start_epochs(1)+1;
    
    t=(1:total_epochs)*seconds_per_epoch/(60*60);
    
    % Opening files to save collected data.
    
    all_filename=['ALL_',epoch_list(1:end-length('_4hrs_by_state_epochs.list'))];

    %% LOADING POWER & BAND POWER; REMOVING LINE NOISE.
    
    load([all_dirname,'/',all_filename,'_spec.mat'],'spec_all');
    load([all_dirname,'/',all_filename,'_BP.mat'],'band_limits','band_freq_labels_long','BP_all');
    
%     save([all_dirname,'/',all_filename,'_BP.mat'],'spec_all','BP_all')
               
    spec_all_mean=ones(size(spec_all))*diag(nanmean(spec_all));
    spec_all_std_inv=ones(size(spec_all))*diag(nanstd(spec_all));
    spec_all_norm=(spec_all-spec_all_mean)./spec_all_std_inv;

%     spec_all_norm=spec_all;

    BP_all_mean=ones(size(BP_all))*diag(nanmean(BP_all));
    BP_all_std=ones(size(BP_all))*diag(nanstd(BP_all));
    BP_all_norm=(BP_all-BP_all_mean)./BP_all_std;

%     BP_all_norm=BP_all_pct;
    
    for i=1:no_stops
        
        spec_all_norm(stop_indices{i})=nan;
    
    end
    
%     [~,est_inj_epoch]=max(BP_all(start_epochs(2)-start_epochs(1)+1-50:start_epochs(2)-start_epochs(1)+1+50,1));
    [~,est_inj_epoch]=max(BP_all(:,1));

    spec_all_norm(est_inj_epoch-10:est_inj_epoch+10,:)=nan;
    BP_all(est_inj_epoch-10:est_inj_epoch+10,:)=nan;
    
%     BP_max=max([BP_max; nanmax(BP_all)]);
    BP_max(d,:)=nanmax(BP_all);

    %% PLOTTING FIGURES
    
    figure(1)
    
    subplot(4,1,d)
    
    imagesc(spec_all_norm')
    axis xy
    colorbar
    x_ticks=1:floor(total_epochs/5):total_epochs;
    set(gca,'XTick',x_ticks,'XTickLabel',t(x_ticks))
    y_ticks=1:floor(no_f_bins/10):no_f_bins;
    set(gca,'YTick',y_ticks,'YTickLabel',f_bins(y_ticks))
    
    if d==1
        
        title({[subject,', Channel ',num2str(channel)];'Normalized Spectral Power'})
        
    end
    
    xlabel('Time (h)')
    ylabel({drugs{d};'Frequency (Hz)'})
    
    figure(1+d)
    
    imagesc(spec_all_norm')
    axis xy
    colorbar
    x_ticks=1:floor(total_epochs/5):total_epochs;
    set(gca,'XTick',x_ticks,'XTickLabel',t(x_ticks))
    y_ticks=1:floor(no_f_bins/10):no_f_bins;
    set(gca,'YTick',y_ticks,'YTickLabel',f_bins(y_ticks))
    
    title({[subject,', Channel ',num2str(channel),', ',drugs{d}];'Normalized Spectral Power'})
    
    xlabel('Time (h)')
    ylabel('Frequency (Hz)')
    
    saveas(gcf,[all_dirname,'/',all_filename,'_',drugs{d},'_power.fig'])
    
    figure(no_drugs+1)
    
    subplot(4,1,d)
    
    imagesc(BP_all_norm')
    axis xy
    colorbar
    x_ticks=1:floor(total_epochs/5):total_epochs;
    set(gca,'XTick',x_ticks,'XTickLabel',t(x_ticks))
    y_ticks=1:no_bands;
    set(gca,'YTick',y_ticks,'YTickLabel',band_freq_labels_long)
    
    if d==1
        
        title({[subject,', Channel ',num2str(channel)];'Normalized Band Power'})
        
    end
    
    xlabel('Time (h)')
    ylabel({drugs{d};'Frequency (Hz)'})
    
    figure(no_drugs+1+d)
    
    imagesc(BP_all_norm')
    axis xy
    colorbar
    x_ticks=1:floor(total_epochs/5):total_epochs;
    set(gca,'XTick',x_ticks,'XTickLabel',t(x_ticks))
    y_ticks=1:no_bands;
    set(gca,'YTick',y_ticks,'YTickLabel',band_freq_labels_long)
    
    title({[subject,', Channel ',num2str(channel),', ',drugs{d}];'Normalized Band Power'})
    
    xlabel('Time (h)')
    ylabel('Frequency (Hz)')
    
    saveas(gcf,[all_dirname,'/',all_filename,'_',drugs{d},'_bands.fig'])
    
    for b=1:no_bands
                      
        figure(2*no_drugs+1+b)
        
        subplot(4,1,d)
        
%         for s=no_states:-1:1
        for s_r=1:no_states
            
            s=states_rearranged(s_r);
            
            state_indices=find(strcmp(drug_epoch_states,states{s}));
            
            plot(t(state_indices),BP_all(state_indices,b),state_markers{s},'MarkerSize',state_sizes(s))
           
            hold on
            
        end

%         plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
                     
        if d==1
            
            legend(state_labels)
            title({[subject,', Channel ',num2str(channel)];[band_freq_labels_long{b},' Power']})
            
        end
        
        if d==no_drugs
            
        xlabel('Time (h)')
        
        end        

        ylabel(drugs{d})
        
        figure(2*no_drugs+1+d*no_bands+b)
        
%         for s=no_states:-1:1
        for s_r=1:no_states
            
            s=states_rearranged(s_r);
            
            state_indices=find(strcmp(drug_epoch_states,states{s}));
            
            plot(t(state_indices),BP_all(state_indices,b),state_markers{s},'MarkerSize',state_sizes(s))
            
            hold on
            
        end
        
        plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
        
        legend(state_labels)
        title({[subject,', Channel ',num2str(channel),', ',drugs{d}];[band_freq_labels_long{b},' Power']})
        xlabel('Time (h)')
        ylabel([band_freq_labels{b},' Power'])
        
        saveas(gcf,[all_dirname,'/',all_filename,'_',drugs{d},'_',band_freq_labels{b},'.fig'])
        
    end
    
    cd (present_dir);

end

%% ADDING VERTICAL BAR AT INJECTION EPOCH.

for b=1:no_bands
            
    figure(2*no_drugs+1+b)
    
%     subplot(4,1,1)
%     
%     legend off
    
    for d=1:no_drugs
        
        start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
        start_epochs=max(start_epochs,1);
        
        end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
        
        total_epochs=end_epochs(end)-start_epochs(1)+1;
        
        t=(1:total_epochs)*seconds_per_epoch/(60*60);
        
        subplot(4,1,d)
        
        ylim([0 BP_max(d,b)])
        
        plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)

    end
    
    saveas(gcf,[all_dirname,'/',subject,'_chan',num2str(channel),'_',band_freq_labels{b},'.pdf'])

    subplot(4,1,1)
    
    legend(state_labels)
    
    saveas(gcf,[all_dirname,'/',subject,'_chan',num2str(channel),'_',band_freq_labels{b},'.fig'])
    
end