function All_MI_params_plots_by_subject_Bernat(channel_label, MI_measure, freq_measure)

close('all')

%% Loading summed MI.

name=['ALL_',channel_label];

drugs = text_read([name, '/', name, '_', MI_measure, '_drugs.txt'],'%s');
subjects = text_read([name, '/', name, '_', MI_measure, '_subjects.txt'],'%s');
% hrs=text_read([name,'/',name,'_',MI_measure,'_hr_periods.txt'],'%s');
fourhrs = text_read([name, '/', name, '_', MI_measure, '_4hr_periods.txt'],'%s');
states = text_read([name, '/', name, '_', MI_measure, '_states.txt'],'%s');

load([name, '/', name, '_', MI_measure, '_MI_params.mat'])

if strcmp(freq_measure, 'max')
    long_measure_labels = {'Max. MI', 'Pref. Phase Freq.', 'Pref. Amp. Freq.'};
    measure_labels = {'maxMI', 'pref_fp', 'pref_fa'};
    hr_params = hr_params_max;
elseif strcmp(freq_measure, 'mean')
    long_measure_labels = {'Pref. Phase Freq.', 'Pref. Amp. Freq.'};
    measure_labels = {'pref_fp', 'pref_fa'};
    hr_params = hr_params_mean;
end
    
no_measures=length(measure_labels);

%% Setting up directory to save files.

all_dirname = ['ALL_', channel_label];
mkdir (all_dirname)

%% Working with different drugs.

drug_labels={'saline','MK801','NVP','Ro25'};
no_drugs=length(drug_labels);

%% Setting up information about different states.

state_labels={'R','NR','W'};
no_states=length(state_labels);

% long_state_labels={'REM','NREM / Quiet Wake','Active Wake'};
state_markers={'.r','.g','.b'};
state_sizes=[20 10 10];

states_rearranged=[2 3 1];

%% Setting up information about periods (time since injection).

% hours_plotted=[-4 16];

% sampling_freq=1000;
seconds_per_epoch=4096/250;
% epochs_per_min=60/seconds_per_epoch;
% epochs_per_hour=60*60/seconds_per_epoch;

%% Cycling through subjects.

subject_labels={'A99','A102','A103','A104','A105','A106'};

for s = 1:6
    
    subject=subject_labels{s};
    
    subj_hr_params = hr_params(strcmp(subjects,subject),:);
    % subj_4hr_params = fourhr_params(strcmp(subjects,subject),:);
    subj_drugs = drugs(strcmp(subjects,subject));
    subj_states = states(strcmp(subjects,subject));
    % subj_hrs=hrs(strcmp(subjects,subject));
    subj_4hrs = fourhrs(strcmp(subjects,subject));
    
    hp_max=zeros(no_drugs,no_measures);
    
    inj_epoch = nan(no_drugs, 1);
    start_epoch = nan(no_drugs, 1);
    end_epoch = nan(no_drugs, 1);
    
    for d=1:no_drugs
        
        drug=drug_labels{d};
        
        drug_hr_params = subj_hr_params(strcmp(subj_drugs,drug),:);
        % drug_summed_MI_4hr=subj_summed_MI_4hr(strcmp(subj_drugs,drug),:);
        drug_states = subj_states(strcmp(subj_drugs,drug));
        % drug_hrs=subj_hrs(strcmp(subj_drugs,drug));
        drug_4hrs = subj_4hrs(strcmp(subj_drugs,drug));
        
        inj_epoch(d) = find(strcmp(drug_4hrs, 'post1to4'), 1 );
        start_epoch(d) = find(strcmp(drug_4hrs, 'pre4to1'), 1 );
        end_epoch(d) = find(strcmp(drug_4hrs, 'post13to16'), 1, 'last' );
        
        epochs = start_epoch(d):end_epoch(d);
        inj_epoch(d) = inj_epoch(d)-start_epoch(d);
        
        drug_hr_params=drug_hr_params(epochs,:);
        % drug_summed_MI_4hr=drug_summed_MI_4hr(epochs,:);
        drug_states=drug_states(epochs);
        % drug_hrs=drug_hrs(epochs);
        % drug_4hrs=drug_4hrs(epochs);
        
        total_epochs=length(epochs);
        t=((1:total_epochs)-inj_epoch(d))*seconds_per_epoch/(60*60);
        
        %% Normalizing summed MI.
        
        % drug_hr_params_mean=ones(size(drug_hr_params))*diag(nanmean(drug_hr_params));
        % drug_hr_params_std=ones(size(drug_hr_params))*diag(nanstd(drug_hr_params));
        % drug_hr_params_norm=(drug_hr_params-drug_hr_params_mean)./drug_hr_params_std;
        % drug_hr_params_norm = zscore(drug_hr_params);
        
        hp_max(d,:) = nanmax(drug_hr_params);
        
        %% PLOTTING FIGURES
        
%         %% All bands, all drugs.
%         
%         figure((s-1)*(no_measures+1)+1)
%         
%         subplot(4,1,d)
%         
%         imagesc(drug_hr_params_norm')
%         axis xy
%         colorbar
%         x_ticks=1:floor(total_epochs/5):total_epochs;
%         set(gca,'XTick', x_ticks, 'XTickLabel', round(t(x_ticks)))
%         y_ticks=1:no_measures;
%         set(gca,'YTick', y_ticks, 'YTickLabel', measure_labels)
%         
%         if d==1
% 
%             try
%                 
%                 title({[subject,', ',char(channel_label)];'Normalized Summed MI'})
%             
%             catch error
%                 
%                 display(error.msg)
%                 
%             end
%             
%         end
%         
%         xlabel('Time (h)')
%         ylabel({drug;'Frequency (Hz)'})
        
%         %% All bands, each drug.
%         
%         figure(1+d)
%         
%         imagesc(drug_hr_params_norm')
%         axis xy
%         colorbar
%         x_ticks=1:floor(total_epochs/5):total_epochs;
%         set(gca,'XTick',x_ticks,'XTickLabel',t(x_ticks))
%         y_ticks=1:no_bands;
%         set(gca,'YTick',y_ticks,'YTickLabel',band_freq_labels_long)
%         
%         title({[subject,', Channel ',num2str(channel),', ',drug];'Normalized Band Power'})
%         
%         xlabel('Time (h)')
%         ylabel('Frequency (Hz)')
%         
%         saveas(gcf,[all_dirname,'/',all_filename,'_',drug,'_bands.fig'])
        
        %% Each band, all drugs, by epoch.
        
        for b=1:no_measures
            
%             figure(2*no_drugs+1+b)
            figure((s-1)*(no_measures+1)+1+b)
            
            subplot(4,1,d)
            
            for s_r=1:no_states
                
                state_index=states_rearranged(s_r);
                
                state_indices=find(strcmp(drug_states,state_labels{state_index}));
                
                plot(t(state_indices),drug_hr_params(state_indices,b),state_markers{state_index},'MarkerSize',state_sizes(state_index))
                
                hold on
                
            end
            
            if d==1
                
                legend(state_labels{states_rearranged})
                
                try
                
                    title({[subject,', ',char(channel_label)]; long_measure_labels{b}})
                    
                catch error
                    
                    display(error.msg)
                
                end
                    
            end
            
            if d==no_drugs
                
                xlabel('Time (h)')
                
            end
            
            ylabel(drug)
            
%             %% Each band, each drug, by epoch.
%             
%             figure(no_drugs+1+d*no_bands+b)
%             
%             for s_r=1:no_states
%                 
%                 s=states_rearranged(s_r);
%                 
%                 state_indices=find(strcmp(drug_epoch_states,states{s}));
%                 
%                 plot(t(state_indices),drug_hr_params(state_indices,b),state_markers{s},'MarkerSize',state_sizes(s))
%                 
%                 hold on
%                 
%             end
%             
%             plot([t(start_epochs(2)-start_epochs(1)+1) t(start_epochs(2)-start_epochs(1)+1)],ylim,'k','LineWidth',2)
%             
%             legend(state_labels)
%             title({[subject,', Channel ',num2str(channel),', ',drug];long_measure_labels{b}})
%             xlabel('Time (h)')
%             ylabel([band_freq_labels{b},' Power'])
%             
%             saveas(gcf,[all_dirname,'/',all_filename,'_',drug,'_',band_freq_labels{b},'.fig'])
            
        end
        
    end
    
    %% ADDING VERTICAL BAR AT INJECTION EPOCH.
    
    for b=1:no_measures
        
%         figure(2*no_drugs+1+b)
        figure((s-1)*(no_measures+1)+1+b)
        
        for d=1:no_drugs
            
            subplot(4,1,d)
            
            ylim([0 hp_max(d,b)])
            
            plot([0 0],ylim,'k','LineWidth',2)
            
            xlim([-4 16])
            
            hold off
            
        end
        
        saveas(gcf,[all_dirname,'/',subject,'_',channel_label,'_',measure_labels{b},'_',freq_measure,'.pdf'])
        
        subplot(4,1,1)
        
        legend(state_labels{states_rearranged})
        
        saveas(gcf,[all_dirname,'/',subject,'_',channel_label,'_',measure_labels{b},'_',freq_measure,'.fig'])
        
    end
    
end