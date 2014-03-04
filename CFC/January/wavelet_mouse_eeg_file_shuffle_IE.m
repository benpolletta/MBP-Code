function wavelet_mouse_eeg_file_shuffle_IE(in_noshufs,thresholds,challenge_list)

close('all')

% challenge_descriptor=char(challenge_descriptor);

thresholds(thresholds<.5)=1-thresholds(thresholds<.5);

listnames=textread(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);

% if no_challenges==length(challenge_labels)
%     
%     challenge_names=challenge_labels;
%     
% else
%     
%     for i=1:no_challenges
%     
%         col_index=mod(i,subplot_dims(2));
%         if col_index==0
%             col_index=subplot_dims(2);
%         end
%         row_index=ceil(i/subplot_dims(2));
%         
%         challenge_names{i}=[challenge_labels{subplot_dims(2)+row_index},', ',challenge_labels{col_index}];
%     
%     end
% 
% end
    
% stat_labels={'pt_cutoffs','z_means','z_stds','z_cutoffs','lz_means','lz_stds','lz_cutoffs','skews'};
% stat_titles={'Empirical p-Value Cutoff','Mean ','Standard Deviation ','Standard Normal Cutoff','Mean Log ','Standard Deviation Log ','Lognormal Cutoff','Skewness'};

bands_lo=1:.25:12;
bands_hi=20:5:200;
bincenters=-.95:.1:.95;

noamps=length(bands_hi);
nophases=length(bands_lo);
nobins=length(bincenters);

present_dir=pwd;

for j=1:no_challenges
    
%     for k=1:length(stat_titles)
%         MI_titles{k}={[challenge_descriptor,' ',challenge_names{j}];[stat_titles{k},' of MI'];[num2str(noshufs),' File Shuffles']};
%     end

    listname=char(listnames(j));
   
    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    if filenum>1
        
        [amp_indices,phase_indices]=random_pairs(in_noshufs,filenum);
        noshufs=length(amp_indices);
        
    else
        
        amp_indices=[]; phase_indices=[];
        noshufs=length(amp_indices);
        
    end
    
    listname=listname(1:end-5);
    if isdir(listname)
        cd (listname)
        cd_flag=1;
    else
        cd_flag=0;
    end
    
    listdir=pwd;
    
    dirname=['FILE_SHUFFLE_',listname,'_',num2str(noshufs),'_shufs'];
    mkdir (dirname)
    
    save([dirname,'/',dirname,'_indices'],'amp_indices','phase_indices')
     
    avg_M=zeros(nobins,noamps,nophases);
    all_MI=zeros(noamps,nophases,noshufs);
    
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
            
            filename=['Shuf',num2str(k),'_',ampname(1:end-5),'_',phasename(1:end-6),'P'];
            
            [M,MI]=inverse_entropy_Jan(nobins,Amp,Phase,filename,dirname);
            
            avg_M=avg_M+M;
            all_MI(:,:,k)=MI;
            
        end
        
    end
   
    avg_M=avg_M/filenum;
  
    stats_name=['STATS_',dirname];
    mkdir (stats_name)
    cd (stats_name)
    
    save([dirname,'_mean_AVP.mat'],'noshufs','bands_lo','bands_hi','avg_M');
    
%     avp_curve_plotter_Jan(bincenters,avg_M,[dirname,'_mean_AVP'],bands_hi,bands_lo,'Hz');
        
    for t=1:length(thresholds)
    
        threshold=thresholds(t);
        
        MI_stats=compute_stats(all_MI,threshold);
        
        save([stats_name,'_p',num2str(threshold),'_IE.mat'],'noshufs','threshold','bands_lo','bands_hi','MI_stats');
        
%         for k=1:8
%             
%             MI_plotter_Jan(MI_stats(:,:,k),[dirname,'_p',num2str(threshold),'_',stat_labels{k}],bands_hi,bands_lo,MI_titles{k},'Hz');
%             
%         end
    
    end
    
    cd (listdir)
    
    clear avg_M all_MI MI_stats
     
    close('all')
   
    if cd_flag==1
        cd (present_dir)
    end
    
end