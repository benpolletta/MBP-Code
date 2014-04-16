function run_PLV_Bernat(no_shufs,chan1_channels,chan2_channels)

% pair_dir=sprintf('All_%s_by_%s_cohy',chan1_name,chan2_name);
% mkdir (pair_dir)

sampling_freq = 1000;

bands_lo = 1:.25:12;
no_bands_lo = length(bands_lo);
bands_hi = 20:5:200;
no_bands_hi = length(bands_hi);
present_dir=pwd;

load('subjects.mat')
load('drugs.mat')

for s=2:min(length(chan1_channels),length(chan2_channels))
    
    subject=subjects{s};
    subj_chan1=chan1_channels(s);
    subj_chan2=chan2_channels(s);
    
    channel_pair=[subj_chan1 subj_chan2];
    
    for d=1:1%:length(drugs)
        
        drug=drugs{d};
        
        subject_dir=[subject,'_',drug];
        cd (subject_dir)
        
        channel_dir1=[subject_dir,'_chan',num2str(channel_pair(1)),'_epochs'];
        period_list1=[channel_dir1,'/',channel_dir1(1:end-length('_epochs')),'_hours_master.list'];
        periods1=textread(period_list1,'%s');
        no_periods1=length(periods1);
        
        channel_dir2=[subject_dir,'_chan',num2str(channel_pair(2)),'_epochs'];
        period_list2=[channel_dir2,'/',channel_dir2(1:end-length('_epochs')),'_hours_master.list'];
        periods2=textread(period_list2,'%s');
        no_periods2=length(periods2);
        
        if isempty(dir([channel_dir1,'/*AP.mat'])) || isempty(dir([channel_dir2,'/*AP.mat']))
            
            channels_listname = [subject_dir,'_channels.list'];
%             delete(channels_listname)
            fid = fopen(channels_listname,'w');
            fprintf(fid,'%s\n%s\n',[channel_dir1,'.list'],[channel_dir2,'.list']);
            fclose(fid);
            
            wavelet_mouse_eeg_HAP(sampling_freq,channels_listname);
            
        end
        
        if no_periods1==no_periods2
            
            pair_dir=sprintf('%s_ch%d_by_ch%d_PLV',subject_dir,channel_pair);
            mkdir (pair_dir)
            
            avg_PLV=nan(no_periods1,no_bands_hi+no_bands_lo);
            avg_PP=nan(no_periods1,no_bands_hi+no_bands_lo);
            avg_shuf_PLV=nan(no_periods1,no_bands_hi+no_bands_lo);
            avg_shuf_PP=nan(no_periods1,no_bands_hi+no_bands_lo);
            avg_thresh_PLV=nan(no_periods1,no_bands_hi+no_bands_lo);
            
            %% Calculating PLV and shuffled PLV by period.
            
            for pd=1:no_periods1
                
                pd1_listname=periods1{pd};
                pd2_listname=periods2{pd};
                
                pd_name = pd1_listname(length(channel_dir1)-length('epochs')+1:end-5);
                pd_pairname = sprintf('%s_ch%d_by_ch%d_%s_PLV',subject_dir,channel_pair,pd_name);
                
                pd1_list=textread([channel_dir1,'/',pd1_listname],'%s%*[^\n]');
                pd2_list=textread([channel_dir2,'/',pd2_listname],'%s%*[^\n]');

                no_epochs=length(pd2_list);
                
                %% Calculating PLV.
                
                pd_PP=nan(no_epochs,no_bands_hi+no_bands_lo);
                pd_PLV=nan(no_epochs,no_bands_hi+no_bands_lo);
                
                parfor e=1:no_epochs
                
                    epoch1_name = pd1_list{e};
                    epoch2_name = pd2_list{e};
                    
                    mat1 = load([channel_dir1,'/',epoch1_name(1:end-4),'_AP.mat']);
                    mat2 = load([channel_dir2,'/',epoch2_name(1:end-4),'_AP.mat']);
                    
                    [PP,plv]=PLV([mat1.P_lo mat1.P_hi],[mat2.P_lo mat2.P_hi]);
                    
                    pd_PP(e,:)=PP;
                    pd_PLV(e,:)=plv;
                    
                end
                
                avg_PP(pd,:)=nanmean(exp(sqrt(-1)*pd_PP));
                avg_PLV(pd,:)=nanmean(pd_PLV);
                
                %% Shuffling.
                
                [ch1_indices,ch2_indices]=random_pairs(no_shufs,no_epochs);
                no_shufs = length(ch1_indices);
                
                pd1_shuf_list = pd1_list(ch1_indices);
                pd2_shuf_list = pd2_list(ch2_indices);
                
                shuffle_indices = [ch1_indices ch2_indices];
                save([pair_dir,'/',pd_pairname,'_shuffles.mat'],'shuffle_indices')
                
                shuf_PP=zeros(no_shufs,no_bands_hi+no_bands_lo);
                shuf_PLV=zeros(no_shufs,no_bands_hi+no_bands_lo);
                
                parfor sh=1:no_shufs
                    
                    epoch1_name = pd1_shuf_list{sh};
                    epoch2_name = pd2_shuf_list{sh};
                    
                    mat1 = load([channel_dir1,'/',epoch1_name(1:end-4),'_AP.mat']);
                    mat2 = load([channel_dir2,'/',epoch2_name(1:end-4),'_AP.mat']);
                    
                    [PP,plv]=PLV([mat1.P_lo mat1.P_hi],[mat2.P_lo mat2.P_hi]);
                    
                    shuf_PP(sh,:)=PP;
                    shuf_PLV(sh,:)=plv;
                    
                end
                
                avg_shuf_PP(pd,:) = nanmean(exp(sqrt(-1)*shuf_PP));
                avg_shuf_PLV(pd,:) = nanmean(shuf_PLV);
                
                thresh_PLV = (pd_PLV - repmat(nanmean(shuf_PLV),no_epochs,1))./repmat(nanstd(shuf_PLV),no_epochs,1);
                
                avg_thresh_PLV(pd,:) = nanmean(thresh_PLV);
                
                save([pair_dir,'/',pd_pairname,'.mat'],'pd_PP','pd_PLV','shuf_PP','shuf_PLV','thresh_PLV')
                
            end
            
            save([pair_dir,'/',pair_dir,'.mat'],'avg_PP','avg_PLV','avg_shuf_PP','avg_shuf_PLV','avg_thresh_PLV')
            
            delete([channel_dir1,'/*AP.mat'])
            delete([channel_dir2,'/*AP.mat'])
            
        else
            
            fprintf('Different number of periods in %s and %s.',channel_dir1,channel_dir2)
            
        end
        
        cd (present_dir)
        
    end
    
end