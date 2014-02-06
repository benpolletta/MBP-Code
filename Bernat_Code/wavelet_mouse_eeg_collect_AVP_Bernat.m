function wavelet_mouse_eeg_collect_AVP_Bernat(subject,drug,channel,phase_freqs,norm_flag)

close('all')

present_dir=pwd;

record_name=[char(subject),'_',char(drug)];

cd (record_name);

channel_name=[record_name,'_chan',num2str(channel)];

cd ([channel_name,'_epochs']);

epoch_list=[channel_name,'_hours_epochs.list'];

[epoch_numbers,epoch_periods,epoch_names]=textread(epoch_list,'%d%s%s%*[^\n]');
no_epochs=length(epoch_numbers);

all_dirname=['ALL_',channel_name,'_hours'];
mkdir (all_dirname);

bands_lo=1:.25:12;
bands_hi=20:5:200;
phase_bins=-.95:.1:.95;

noamps=length(bands_hi);
nophases=length(bands_lo);
nobins=length(phase_bins);

nofreqs=length(phase_freqs);

for f=1:nofreqs
    
    [phase_indices(f),~]=min(abs(bands_lo-phase_freqs(f)));
    
    if norm_flag==1
   
        AVP_fid_vec(f)=fopen([all_dirname,'/',all_dirname,'_AVP_p',num2str(phase_freqs(f)),'_norm.txt'],'w');
        
    elseif norm_flag==0
    
        AVP_fid_vec(f)=fopen([all_dirname,'/',all_dirname,'_AVP_p',num2str(phase_freqs(f)),'.txt'],'w');
    
    else
        
        display('norm_flag must be zero or one.')
        
        return
        
    end
        
end

format=make_format(noamps*nobins,'f');

for e=1:no_epochs
    
    epoch_period=char(epoch_periods(e));
    
    epoch_name=char(epoch_names(e));
    epoch_name=epoch_name(1:end-4);
    
    filename=[epoch_name,'_IE.mat'];
        
    AVP=load(filename,'M');
    AVP=AVP.M;
    
    if norm_flag==1
        
        mean_avg_amp=repmat(mean(AVP),nobins,1);
        AVP=AVP./mean_avg_amp-1;
        
    end
    
    for f=1:min(nofreqs,size(AVP,3))

        AVP_vec=reshape(AVP(:,:,f),1,noamps*nobins);
        
        fprintf(AVP_fid_vec(f),format,AVP_vec);
       
    end
    
end

fclose('all');

cd (present_dir);