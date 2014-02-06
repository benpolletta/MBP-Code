function wavelet_mouse_eeg_file_shuffle_PLV(noshufs,thresholds,sampling_freq,challenge_list,challenge_descriptor,challenge_labels,subplot_dims)

in_noshufs=noshufs;

close('all')

challenge_descriptor=char(challenge_descriptor);

thresholds(thresholds<.5)=1-thresholds(thresholds<.5);

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);

if no_challenges==length(challenge_labels)
    
    challenge_names=challenge_labels;
    
else
    
    for i=1:no_challenges
    
        col_index=mod(i,subplot_dims(2));
        if col_index==0
            col_index=subplot_dims(2);
        end
        row_index=ceil(i/subplot_dims(2));
        
        challenge_names{i}=[challenge_labels{subplot_dims(2)+row_index},', ',challenge_labels{col_index}];
    
    end

end
    
stat_labels={'pt_cutoffs','z_means','z_stds','z_cutoffs','lz_means','lz_stds','lz_cutoffs','skews'};
stat_titles={'Empirical p-Value Cutoff','Mean ','Standard Deviation ','Standard Normal Cutoff','Mean Log ','Standard Deviation Log ','Lognormal Cutoff','Skewness'};

for i=1:length(challenge_names)
    PLV_PP_titles{i}={[challenge_descriptor,', ',challenge_names{i}];['Mean Preferred Phase from PLV, ',num2str(noshufs),' File Shuffles']};
end

bands_lo=1:.25:12;
bands_hi=20:5:200;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

for j=1:no_challenges
    
    for k=1:length(stat_titles)
        PLV_titles{k}={[challenge_descriptor,' ',challenge_names{j}];[stat_titles{k},' of PLV'];[num2str(noshufs),' File Shuffles']};
    end

    listname=char(listnames(j));

    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    if filenum>0
        
        if isempty(in_noshufs)
            
            noshufs=filenum;
            amp_indices=randperm(filenum);
            phase_indices=randperm(filenum);
        
        else
            
            shuf_indices=ceil(rand(2,noshufs)*filenum);
            shuf_indices(:,diff(shuf_indices)==0)=[];
            
            while length(shuf_indices)<noshufs
                
                shuf_indices(:,end+1:noshufs)=ceil(rand(2,noshufs-length(shuf_indices))*filenum);
                shuf_indices(:,diff(shuf_indices)==0)=[];
        
            end
            
            amp_indices=shuf_indices(1,:);
            phase_indices=shuf_indices(2,:);
        
        end
        
    else
        
        amp_indices=[]; phase_indices=[];
        
    end
    
    listname=listname(1:end-5);
    if isdir(listname)
        cd (listname)
        cd_flag=1;
    else
        cd_flag=0;
    end
    
    PLV_dirname=['FILE_SHUFFLE_',listname,'_PLV_',num2str(noshufs),'_shufs_p_',num2str(threshold)];
    mkdir (PLV_dirname)
    
    avg_PLV_PP=zeros(nophases,noamps);
    all_PLV=zeros(nophases,noamps,noshufs);
    
    if ~isempty(amp_indices) && ~isempty(phase_indices)
        
        ampnames=filenames(amp_indices);
        phasenames=filenames(phase_indices);
        
        parfor k=1:noshufs
            
            ampname=char(ampnames(k));
            ampname=ampname(1:end-4);
            ampname=[ampname,'_AP.mat'];
            
            Amp=load(ampname);
            Amp=Amp.A_hi;
            
            phasename=char(phasenames(k));
            phasename=phasename(1:end-4);
            phasename=[phasename,'_AP.mat'];
            
            Phase=load(phasename);
            Phase=Phase.P_lo;
            
            filename=[ampname(1:end-5),'_',phasename(1:end-6),'P_shuf',num2str(k)];
            
            [PLV_PP,PLV_MI]=PLV(sampling_freq,Phase,Amp,bands_lo,filename,PLV_dirname);
            
            avg_PLV_PP=avg_PLV_PP+exp(sqrt(-1)*PLV_PP);
            all_PLV(:,:,k)=PLV_MI;
            
        end
        
    end
    
    avg_PLV_PP=angle(avg_PLV_PP);
        
    stats_name=['STATS_',PLV_dirname];
    mkdir (stats_name)
    cd (stats_name)
          
    MI_plotter_Jan(avg_PLV_PP/pi,[PLV_dirname,'_pp'],bands_hi,bands_lo,PLV_PP_titles{j},'Hz');
    
    for t=1:length(thresholds)
        
        threshold=thresholds(t);
        
        PLV_stats=compute_stats(all_PLV,threshold);
    
        save([stats_name,'_p',num2str(threshold),'.mat'],'noshufs','threshold','bands_lo','bands_hi','avg_M','avg_canolty_PP','avg_PLV_PP','MI_stats','canolty_stats','PLV_stats');
    
        for k=1:8
            
            MI_plotter_Jan(PLV_stats(:,:,k),[PLV_dirname,'_',stat_labels{k},'_PLV'],bands_hi,bands_lo,PLV_titles{k},'Hz');
            
        end
        
    end
    
    close('all')
    
    clear avg_PLV_PP all_PLV PLV_stats
        
    if cd_flag==1
        cd (present_dir)
    end
    
end