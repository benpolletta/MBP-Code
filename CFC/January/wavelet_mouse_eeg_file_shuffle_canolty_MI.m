function wavelet_mouse_eeg_file_shuffle_canolty_MI(in_noshufs,thresholds,challenge_list)

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
%     
% stat_labels={'pt_cutoffs','z_means','z_stds','z_cutoffs','lz_means','lz_stds','lz_cutoffs','skews'};
% stat_titles={'Empirical p-Value Cutoff','Mean ','Standard Deviation ','Standard Normal Cutoff','Mean Log ','Standard Deviation Log ','Lognormal Cutoff','Skewness'};
% 
% for i=1:length(challenge_names)
%     canolty_PP_titles{i}={[challenge_descriptor,', ',challenge_names{i}];['Mean Preferred Phase from Canolty MI, ',num2str(noshufs),' File Shuffles']};
% end

bands_lo=1:.25:12;
bands_hi=20:5:200;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

for j=1:no_challenges
    
%     for k=1:length(stat_titles)
%         canolty_MI_titles{k}={[challenge_descriptor,' ',challenge_names{j}];[stat_titles{k},' of Canolty MI'];[num2str(noshufs),' File Shuffles']};
%     end

    listname=char(listnames(j));

    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    if filenum>1
        
        if isempty(in_noshufs)
            
            noshufs=filenum;
            
            amp_indices=randperm(filenum);
            phase_indices=randperm(filenum);
        
        elseif 2*nchoosek(filenum,2)<in_noshufs
            
            display(['There are not enough data files to create ',num2str(in_noshufs),' independent shuffles; there are only ',num2str(filenum),' data files, so ',num2str(2*nchoosek(filenum,2)),' shuffles will be created instead.'])
            
            noshufs=2*nchoosek(filenum,2);
            
            shuf_indices=nchoosek(1:filenum,2);
            shuf_indices=[shuf_indices; fliplr(shuf_indices)];
            
            amp_indices=shuf_indices(:,2);
            phase_indices=shuf_indices(:,1);
            
        else
            
            noshufs=in_noshufs;
            
            pairs=nchoosek(1:filenum,2);
            pairs=[pairs; fliplr(pairs)];
            choices=randperm(length(pairs));
            choices=choices(1:noshufs);
            shuf_indices=pairs(choices,:);
            
%             shuf_indices=ceil(rand(2,noshufs)*filenum);
%             shuf_indices(:,diff(shuf_indices)==0)=[];
%             
%             while length(shuf_indices)<noshufs
%                 
%                 shuf_indices(:,end+1:noshufs)=ceil(rand(2,noshufs-length(shuf_indices))*filenum);
%                 shuf_indices(:,diff(shuf_indices)==0)=[];
%         
%             end
            
            amp_indices=shuf_indices(:,2);
            phase_indices=shuf_indices(:,1);
        
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
        
    list_dir=pwd;
    
    dirname=['FILE_SHUFFLE_',listname,'_',num2str(noshufs),'_shufs'];
    mkdir (dirname)
    
    save([dirname,'/',dirname,'_indices'],'amp_indices','phase_indices')
        
    avg_canolty_PP=zeros(nophases,noamps);
    all_canolty_MI=zeros(nophases,noamps,noshufs);
        
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
            
            [can_PP,can_MI]=canolty_MI(Phase,Amp,filename,dirname);
            
            avg_canolty_PP=avg_canolty_PP+exp(sqrt(-1)*can_PP);
            all_canolty_MI(:,:,k)=can_MI;
            
        end
        
    end
       
    avg_canolty_PP=angle(avg_canolty_PP);
        
    stats_name=['STATS_',dirname];
    mkdir (stats_name)
    cd (stats_name)
    
    save([dirname,'_canPP.mat'],'noshufs','bands_lo','bands_hi','avg_canolty_PP');
    
%     MI_plotter_Jan(avg_canolty_PP/pi,[dirname,'_canPP'],bands_hi,bands_lo,canolty_PP_titles{j},'Hz');
    
    for t=1:length(thresholds)
        
        threshold=thresholds(t);
        
        canolty_stats=compute_stats(all_canolty_MI,threshold);
        
        save([stats_name,'_p',num2str(threshold),'_canMI.mat'],'noshufs','threshold','bands_lo','bands_hi','canolty_stats');
        
%         for k=1:8
%             
%             MI_plotter_Jan(canolty_stats(:,:,k),[dirname,'_',stat_labels{k},'_canolty_MI'],bands_hi,bands_lo,canolty_MI_titles{k},'Hz');
%             
%         end
        
    end
    
%     close('all')
    
    clear avg_canolty_PP all_canolty_MI canolty_stats
        
    cd (list_dir)
    
    if cd_flag==1
        cd (present_dir)
    end
    
end