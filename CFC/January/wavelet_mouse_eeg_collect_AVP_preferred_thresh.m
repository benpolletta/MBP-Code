function [AVP_all]=wavelet_mouse_eeg_collect_AVP_preferred_thresh(epoch_list,condition_dirs,norm_flag)

close('all')

no_states=length(condition_dirs);

epoch_list=char(epoch_list);

[epoch_names,epoch_states]=textread(epoch_list,'%s%d%*[^\n]');
no_epochs=length(epoch_names);

bins=.05:.1:1.95;
bands_lo=4:.25:12;
bands_hi=20:5:180;

nobins=length(bins);
noamps=length(bands_hi);

present_dir=pwd;

all_dirname=['ALL_',epoch_list(1:end-5)];
mkdir (all_dirname)

if norm_flag==1

    fid_AVP=fopen([all_dirname,'/',all_dirname,'_AVP_pref_thresh_norm.txt'],'w');

else
   
    fid_AVP=fopen([all_dirname,'/',all_dirname,'_AVP_pref_thresh.txt'],'w');
    
end
    
fprintf(fid_AVP,'%s\t%s\t%s\t%s\t%s\t%s\t','epoch','state','maxMI','pref_fa','pref_fp','pref_phase');
    
for i=1:noamps
    for j=1:nobins
        band_label=[num2str(bands_hi(i)),'-amp-around-',num2str(bins(j)),'-pi'];
        fprintf(fid_AVP,'%s\t',band_label);
        band_labels{(i-1)*noamps+j}=band_label;
    end
end

fprintf(fid_AVP,'%s\n','');

format=make_format(noamps*nobins+6,'f');

AVP_all=zeros(no_epochs,noamps*nobins);

PAC_params=zeros(no_epochs,4);

for j=1:no_epochs
    
    epoch_state=epoch_states(j);
    
    if epoch_state<no_states
    
        dir_name=char(condition_dirs{epoch_state+1});
        
        epoch_name=char(epoch_names(j));
        epoch_name=epoch_name(1:end-4);
        
        IE_filename=[dir_name,'/',epoch_name,'_IE.mat'];
        
        IE_struct=load(IE_filename,'M');
        AVP=IE_struct.M;
        
        thresh_dir_name=dir([dir_name,'/THRESH*']);
        thresh_filename=[dir_name,'/',thresh_dir_name(1).name,'/',epoch_name,'_IE_thresh.mat'];
        thresh_struct=load(thresh_filename);
        MI=thresh_struct.MI_thresh;
        MI=MI(:,:,1);
        
        [~,phase_index]=max(max(MI));
        [max_MI,amp_index]=max(MI(:,phase_index));
        
        phase_freq=bands_lo(phase_index);
        amp_freq=bands_hi(amp_index);

        AVP=AVP(:,:,phase_index)';

        [~,pp_index]=max(AVP(amp_index,:));
        pref_phase=bins(pp_index);
        
        if norm_flag==1
            
            mean_avg_amp=repmat(mean(AVP,2),1,nobins);
            AVP=AVP./mean_avg_amp-1;
            
        end
        
        AVP=reshape(AVP,1,nobins*noamps);
        
        fprintf(fid_AVP,format,[j epoch_state max_MI amp_freq phase_freq pref_phase AVP]);
        
        AVP_all(j,:)=AVP;
        
        PAC_params(j,:)=[max_MI amp_freq phase_freq pref_phase];
                
    else
        
        AVP_all(j,:)=nan(1,noamps*nobins);
        
    end

end

fclose(fid_AVP)

if norm_flag==1
    
    save([all_dirname,'/',all_dirname,'_AVP_pref_thresh_norm.mat'],'AVP_all','PAC_params')

else
    
    save([all_dirname,'/',all_dirname,'_AVP_pref_thresh.mat'],'AVP_all','PAC_params')
    
end
    
cd (present_dir);