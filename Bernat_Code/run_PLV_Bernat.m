function run_PLV_Bernat(no_shufs,chan1_channels,chan2_channels)

% pair_dir=sprintf('All_%s_by_%s_cohy',chan1_name,chan2_name);
% mkdir (pair_dir)

bands_lo=1:.25:12;
bands_hi=20:5:200;

present_dir=pwd;

load('subjects.mat')
load('drugs.mat')

for s=1:min(length(chan1_channels),length(chan2_channels))
    
    subject=subjects{s};
    subj_chan1=chan1_channels(s);
    subj_chan2=chan2_channels(s);
    
    channel_pair=[subj_chan1 subj_chan2];
    
    for d=1:length(drugs)
        
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
        
        if no_periods1==no_periods2
            
            pair_filename=sprintf('%s_ch%d_by_ch%d_cohy.mat',subject_dir,channel_pair);
            
            avg_PLV=nan(no_periods1,no_bands_hi+no_bands_lo);
            avg_PP=nan(no_periods1,no_bands_hi+no_bands_lo);
            
            for pd=1:no_periods1
                
                pd1_listname=periods1{pd};
                pd2_listname=periods2{pd};
                
                pd1_list=textread([channel_dir1,'/',pd1_listname],'%s%*[^\n]');
                pd2_list=textread([channel_dir2,'/',pd2_listname],'%s%*[^\n]');

                no_epochs=length(pd2_list);
                
                pd_PP=zeros(1,no_bands_hi+no_bands_lo);
                pd_PLV=zeros(1,no_bands_hi+no_bands_lo);
                
                parfor e=1:no_epochs
                
                    epoch1_name = pd1_list{e};
                    epoch2_name = pd2_list{e};
                    
                    epoch_pairname = [epoch1_name(1:end-4),epoch2_name(length(channel_dir2+1):end-4)];
                    
                    mat1 = load([channel_dir1,'/',pd1_listname,'/',epoch1_name(1:end-4),'_AP.mat']);
                    mat2 = load([channel_dir1,'/',pd2_listname,'/',epoch2_name(1:end-4),'_AP.mat']);
                    
                    [PP,plv]=PLV([mat1.Plo mat1.Phi],[mat2.Plo mat2.Phi],epoch1_name(1:end-4),epoch_pairname,pair_filename);
                    
                    pd_PP=pd_PP+exp(sqrt(-1)*PP)/no_epochs;
                    pd_PLV=pd_PLV+plv;
                    
                end
                   
                avg_PP(pd,:)=pd_PP;
                avg_PLV(pd,:)=pd_PLV/no_epochs;
                
                parfor sh=1:no_shufs
                    
                    
                end
                
            end
            
            cohy_shuf_mean=reshape(nanmean(PLV_shuf),no_freqs,no_periods1)';
            cohy_shuf_stdr=reshape(nanstd(real(PLV_shuf)),no_freqs,no_periods1)';
            cohy_shuf_stdi=reshape(nanstd(imag(PLV_shuf)),no_freqs,no_periods1)';
            cohy_norm=real(PLV_mat-cohy_shuf_mean)./cohy_shuf_stdr+sqrt(-1)*imag(PLV_mat-cohy_shuf_mean)./cohy_shuf_stdi;
            

            save(pair_filename,'cohy','cohy_norm','cohy_shuf_mean','cohy_shuf_stdr','cohy_shuf_stdi')
            %                 save(pair_filename,'cohy','cohy_norm','cohy_shuf','-v7.3')
            
        else
            
            fprintf('Different number of periods in %s and %s.',channel_dir1,channel_dir2)
            
        end
        
    end
    
    cd (present_dir)
    
end

end