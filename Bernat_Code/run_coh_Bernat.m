function run_coh_Bernat(no_shufs,chan1_channels,chan2_channels)

% pair_dir=sprintf('All_%s_by_%s_cohy',chan1_name,chan2_name);
% mkdir (pair_dir)

sampling_freq=1000;
signal_length=4096*4;
f=(sampling_freq/2)*([1:signal_length/2+1]-1)/(signal_length/2);
f(f>200)=[];
no_freqs=length(f);

present_dir=pwd;

load('subjects.mat')
load('drugs.mat')

list_suffixes={'hours','4hrs_by_state'};
no_master_lists=length(list_suffixes);

for l=1:no_master_lists
    
    for s=3:min(length(chan1_channels),length(chan2_channels))
        
        subject=subjects{s};
        subj_chan1=chan1_channels(s);
        subj_chan2=chan2_channels(s);
        
        channel_pair=[subj_chan1 subj_chan2];
        
        for d=1:length(drugs)
            
            drug=drugs{d};
            
            subject_dir=[subject,'_',drug];
            cd (subject_dir)
            
            channel_dir1=[subject_dir,'_chan',num2str(channel_pair(1)),'_epochs'];
            period_list1=[channel_dir1,'/',channel_dir1(1:end-length('_epochs')),'_',list_suffixes{l},'_master.list'];
            periods1=textread(period_list1,'%s');
            no_periods1=length(periods1);
            
            channel_dir2=[subject_dir,'_chan',num2str(channel_pair(2)),'_epochs'];
            period_list2=[channel_dir2,'/',channel_dir2(1:end-length('_epochs')),'_',list_suffixes{l},'_master.list'];
            periods2=textread(period_list2,'%s');
            no_periods2=length(periods2);
            
            if no_periods1==no_periods2
                
                cohy=nan(no_periods1,no_freqs);
                cohy_shuf=nan(no_shufs,no_freqs,no_periods1);
                
                for pd=1:no_periods1
                    
                    pd1_name=periods1{pd};
                    pd2_name=periods2{pd};
                    
                    load([channel_dir1,'/',pd1_name(1:end-5),'_fft.mat']);
                    chan1_fft=all_fft;
                    chan1_fft=chan1_fft(:,1:no_freqs);
                    load([channel_dir2,'/',pd2_name(1:end-5),'_fft.mat']);
                    chan2_fft=all_fft;
                    chan2_fft=chan2_fft(:,1:no_freqs);
                    no_epochs=size(chan2_fft,1);
                    
                    cohy(pd,:)=coherency(chan1_fft,chan2_fft);
                    
                    for sh=1:no_shufs
                        
                        chan1_fft_loc=chan1_fft; chan2_fft_loc=chan2_fft;
                        cohy_shuf(sh,:,pd)=coherency(chan1_fft_loc(randperm(no_epochs),:),chan2_fft_loc(randperm(no_epochs),:));
                        
                    end
                    
                end
                
                cohy_shuf_mean=reshape(nanmean(cohy_shuf),no_freqs,no_periods1)';
                cohy_shuf_stdr=reshape(nanstd(real(cohy_shuf)),no_freqs,no_periods1)';
                cohy_shuf_stdi=reshape(nanstd(imag(cohy_shuf)),no_freqs,no_periods1)';
                cohy_norm=real(cohy-cohy_shuf_mean)./cohy_shuf_stdr+sqrt(-1)*imag(cohy-cohy_shuf_mean)./cohy_shuf_stdi;
                
                coh_shuf_mean=reshape(nanmean(abs(cohy_shuf)),no_freqs,no_periods1)';
                coh_shuf_std=reshape(nanstd(abs(cohy_shuf)),no_freqs,no_periods1)';
                coh_norm=real(abs(cohy)-coh_shuf_mean)./coh_shuf_std;
                
                pair_filename=sprintf('%s_ch%d_by_ch%d_%s_cohy.mat',subject_dir,channel_pair,list_suffixes{l});
                save(pair_filename,'cohy','cohy_norm','cohy_shuf_mean','cohy_shuf_stdr','cohy_shuf_stdi','coh_norm','coh_shuf_mean','coh_shuf_std')
                %                 save(pair_filename,'cohy','cohy_norm','cohy_shuf','-v7.3')
                
            else
                
                fprintf('Different number of periods in %s and %s.',channel_dir1,channel_dir2)
                
            end
            
            cd (present_dir)
            
        end
        
    end
    
end