function wavelet_mouse_eeg_collect_power_Bernat(subject,channel)

% UNFINISHED

close('all')

present_dir=pwd;

% Setting up information about periods (time since injection).

period_hrs=[-4 0;0 4;4 8];

sampling_freq=1000;
seconds_per_epoch=4096/250;
signal_length=sampling_freq*seconds_per_epoch;
epochs_per_min=60/seconds_per_epoch;
epochs_per_hour=60*60/seconds_per_epoch;

inj_epochs=floor([5*60+7 2*60+35 5*60+7 3*60]*epochs_per_min);

% Setting up information about different states.

states={'R','NR','AW'};
no_states=length(states);

state_labels={'Active Wake','NREM / Quiet Wake','REM','Injection'};
state_markers={'.r','.g','.b'};
state_sizes=[20 10 10];

% Parameters for FFT & band power.

f=sampling_freq*[0:signal_length/2]/(signal_length);
no_freqs=length(f);

spec_format=make_format(no_freqs+2,'f');

band_limits=[.1 4; 4 8; 10 13; 15 30; 30 59; 61 110; 125 175];
band_labels={'delta','theta','alpha','beta','low-gamma','high-gamma','HFOs'};
band_labels_long={'Delta (.1 to 4 Hz)','Theta (4 to 8 Hz)','Alpha (10 to 13 Hz)','Beta (15 to 30 Hz)','Low Gamma (30 to 59 Hz)','High Gamma (61 to 110 Hz)','HFO (125 to 175 Hz)'};

[no_bands,~]=size(band_limits);

for i=1:no_bands
    band_indices{i}=find(f>=band_limits(i,1) & f<=band_limits(i,2));
end
    
BP_format=make_format(no_bands+2,'f');

% Working with different drugs.

drugs={'MK801','NVP','Ro25','saline'};
no_drugs=length(drugs);

for d=1:no_drugs
    
    data_dir=[subject,'_',drugs{d},'_chan',num2str(channel)];
        
    epoch_list=[data_dir,'_epochs.list'];

    [epoch_names,epoch_states]=textread([data_dir,'/',epoch_list],'%s%d%*[^\n]');
    no_epochs=length(epoch_names);

    start_epochs=ceil(inj_epochs(d)+period_hrs(:,1)*epochs_per_hour+1);
    start_epochs=max(start_epochs,1);
    
    end_epochs=floor(inj_epochs(d)+period_hrs(:,2)*epochs_per_hour);
    
    drug_epoch_names=epoch_names(start_epochs(1):end_epochs(end));
    drug_epoch_states=epoch_states(start_epochs(1):end_epochs(end));
%     
% %     epochs_per_period=end_epochs-start_epochs+1;
%     
%     total_epochs=end_epochs(end)-max(start_epochs(1),1)+1;
    
    t=(1:no_epochs)*seconds_per_epoch/(60*60);
    
    % Opening files to save collected data.
    
    all_dirname=['ALL_',epoch_list(1:end-5)];
    mkdir (all_dirname)
    
    measures={'spec_pow','band_pow'};
    no_measures=length(measures);
    
    for i=1:no_measures
        fid_vec(i)=fopen([all_dirname,'/',all_dirname,'_',measures{i},'.txt'],'w');
        fprintf(fid_vec(i),'%s\t%s\t','epoch','state');
    end
    
    fprintf(fid_vec(1),make_format(no_freqs,'f'),f);
    
    for i=1:no_bands
        fprintf(fid_vec(2),'%s\t',band_labels{i});
    end
    fprintf(fid_vec(2),'%s\n','');
    
    spec_all=zeros(no_epochs,no_freqs);
    BP_all=zeros(no_epochs,no_bands);
    
    % Computing spectral measures epoch by epoch.
    
        for p=1:no_periods
            
            state_dir=state_dirs{epoch_state};
            
            period_mat=[state_dir,'_',char(drugs{d}),'_',period_labels{p},'_avg_ff.mat'];
            
            fft_data=load([state_dir,'/',period_mat]);
            
            for i=1:no_bands
                
                BP(:,i)=sum(abs(fft_data(:,band_indices{i})).^2,2);
                
            end
            
            
        
        for j=(start_epochs(p)-start_epochs(1)+1):(end_epochs(p)-start_epochs(1)+1)
            
            epoch_state=drug_epoch_states(j);
            
%             if epoch_state<no_states
            

        
                    state_dir=state_dirs{epoch_state};
        
                    period_mat=[state_dir,'_',char(drugs{d}),'_',period_labels{p},'_avg_fft.mat'];
        
        %         dir_name=char(condition_dirs{epoch_state+1});
        %             state_dir=char(state_dirs{epoch_state});
        
        epoch_name=char(drug_epoch_names(j));
        
        data=load([data_dir,'/',epoch_name]);
        
        data_hat=pmtm(data,[],signal_length);
        
        for i=1:no_bands
            
            BP=sum(abs(data_hat(band_indices{i})).^2);
            
        end
        
        fprintf(fid_vec(1),spec_format,j,epoch_state,data_hat);
        fprintf(fid_vec(2),BP_format,j,epoch_state,BP);
        
        spec_all(j,:)=data_hat;
        BP_all(j,:)=BP;
        
    end
             
    fclose('all');
    
    save([all_dirname,'/',all_dirname,'_BP.mat'],'spec_all','BP_all')
               
    spec_all_mean=ones(size(spec_all))*diag(mean(spec_all));
    spec_all_std_inv=diag(1./std(spec_all));
    spec_all_norm=(spec_all-spec_all_mean)*spec_all_std_inv;
    
    figure(1)
    
    suplot(4,1,d)
    
    imagesc(spec_all_norm')
    axis xy
    colorbar
    x_ticks=1:floor(no_epochs/5):no_epochs;
    set(gcf,'XTick',x_ticks,'XTickLabels',t(x_ticks))
    y_ticks=1:floor(no_freqs/10):no_freqs;
    set(gcf,'XTick',y_ticks,'XTickLabels',f(y_ticks))
    
    if d==1
        
        title({[subject,', Channel ',num2str(channel)];'Normalized Spectral Power'})
        
    end
    
    xlabel('Time (h)')
    ylabel({drugs{d};'Frequency (Hz)'})
    
    figure(1+d)
    
    imagesc(spec_all_norm')
    axis xy
    colorbar
    x_ticks=1:floor(no_epochs/5):no_epochs;
    set(gcf,'XTick',x_ticks,'XTickLabels',t(x_ticks))
    y_ticks=1:floor(no_freqs/10):no_freqs;
    set(gcf,'XTick',y_ticks,'XTickLabels',f(y_ticks))
    
    title({[subject,', Channel ',num2str(channel),', ',drugs{d}];'Normalized Spectral Power'})
    
    xlabel('Time (h)')
    ylabel('Frequency (Hz)')
    
    saveas(gcf,[all_dirname,'/',all_dirname,'_',drugs{d},'_power.fig'])
    
    for b=1:no_bands
                      
        figure(1+no_drugs+b)
        
        subplot(4,1,d)
        
        for s=no_states:-1:1
            
            state_indices=find(drug_epoch_states==s);
            
            plot(t(state_indices),BP_all(state_indices,b),state_markers{s},'MarkerSize',state_sizes(s))
           
            hold on
            
        end

        plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
                     
        if d==1
            
            legend(state_labels)
            title({[subject,', Channel ',num2str(channel),', ',drugs{d}];[band_labels_long{b},' Power']})
            
        end
        
        xlabel('Time (h)')
        ylabel(drugs{d})
        
        figure(1+no_drugs+d*no_bands+b)
        
        for s=no_states:-1:1
            
            state_indices=find(drug_epoch_states==s);
            
            plot(t(state_indices),MI_all(state_indices,b),state_markers{s},'MarkerSize',state_sizes(s))
            
            hold on
            
        end
        
        plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
        
        legend(state_labels)
        title({[subject,', Channel ',num2str(channel),', ',drugs{d}];[band_labels_long{b},' Power']})
        xlabel('Time (h)')
        ylabel([band_labels{b},' Power'])
        
        saveas(gcf,[all_dirname,'/',all_dirname,'_',drugs{d},'_',band_labels{b},'.fig'])
        
    end
    
    cd (present_dir);

end

for b=1:no_measures

    saveas(figure(b),[subject,'_chan',num2str(channel),'_',band_labels{b},'.fig'])
    saveas(figure(b),[subject,'_chan',num2str(channel),'_',band_labels{b},'.pdf'])
    
end