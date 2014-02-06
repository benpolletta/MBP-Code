function artifacts(eeg_channel,emg_channel,sampling_freq,signal_length,max_eeg_val,min_eeg_val,state_labels)

% Getting list of epochs to search for artifacts.

[epoch_listname,epoch_listpath]=uigetfile('*list','Choose a list of epochs to search for artifacts.')

[epoch_list,state]=textread([epoch_listpath,epoch_listname],'%s%d');
epoch_num=length(epoch_list);

epoch_listname=epoch_listname(1:end-12);

% Setting up lists to record good, bad epochs, commands to move bad epochs,
% and EEG-EMG correlation.

bad_epochs_list=fopen([epoch_listpath,epoch_listname,'_artifacts.list'],'w');
% fprintf(bad_epochs_fid,'%s\t%s\t%s\n','Epoch','EEG-EMG Correlation','Amp. Saturation');

good_epochs_list=fopen([epoch_listpath,epoch_listname,'_epochs_clean.list'],'w');

bad_epochs_commands=fopen([epoch_listpath,epoch_listname,'_artifacts.sh'],'w');
fprintf(bad_epochs_commands,'%s\n','mkdir Artifactual_Epochs');

corr_fid=fopen([epoch_listpath,epoch_listname,'_eeg-emg_corr.txt'],'w');

% Setting up lists to record clean epochs by vigilance state.

fid_cond_list=fopen([epoch_listname,'_clean_condition_lists.list'],'w');

for i=1:length(state_labels)
    
    cond_names{i}=[epoch_listname,'_',state_labels{i},'_clean.list'];
    fid_vec(i)=fopen(char(cond_names{i}),'w');
    fprintf(fid_cond_list,'%s\n',char(cond_names{i}));
    
end

fclose(fid_cond_list);

% % Vectors to store outputs.
% 
% eeg_emg_correlated=zeros(epoch_num,1);
% amp_saturation=zeros(epoch_num,1);

% Cutoffs for correlations.

corr_cutoff_hi=norminv(.95,0,1/(signal_length-1));
corr_cutoff_lo=norminv(.05,0,1/(signal_length-1));

for j=1:epoch_num
    
    eeg_emg_correlated=0;
    amp_saturation=0;

    epoch_name=char(epoch_list(i));
    data=load(epoch_name);

    eeg=data(:,eeg_channel);
    emg=data(:,emg_channel);

    eeg_emg_correlation=corr(eeg,emg);
    fprintf(corr_fid,'%s\t%f\n',epoch_name,eeg_emg_correlation);
    
    if eeg_emg_correlation > corr_cutoff_hi | eeg_emg_correlation < corr_cutoff_lo
        
        eeg_emg_correlated=1;
        
    end
    
    sat_indices=find(eeg==max_eeg_val | eeg==min_eeg_val);

    if ~isempty(find(diff(sat_indices)==1))

        amp_saturation=1;

    end
    
    if eeg_emg_correlated==1 | amp_saturation==1

        fig_name=[epoch_name(1:end-4),'.fig'];
        
        figure()
        plot(eeg)
        hold on
        plot(emg,':k')
        saveas(gcf,fig_name)
        close(gcf)

        fprintf(bad_epochs_list,'%s\t%d\t%d\n',epoch_name,eeg_emg_correlated,amp_saturation);
        fprintf(bad_epochs_commands,'%s\n',['mv ',epoch_name,' Artifactual_Epochs']);
        fprintf(bad_epochs_commands,'%s\n',['mv ',fig_name,' Artifactual_Epochs']);
        
    else
        
        epoch_name=[epoch_name(1:end-8),'.txt'];
        
        fid=fopen(epoch_name,'w');
        fprintf(fid,'%f\n',eeg);
        fclose(fid);
        
        state=state(j);
        
        fprintf(good_epochs_list,'%s\t%d\t',epoch_name,state);
        
        fprintf(fid_vec(state+1),'%s\n',epoch_name);
        
    end
    
end

fprintf(bad_epochs_commands,'%s\n',['mv ',epoch_listname,'_artifacts.list Artifactual_Epochs']);

fclose('all')