function run_coh_Bernat(no_shufs)

sampling_freq=1000;
signal_length=4096*4;
f=(sampling_freq/2)*([1:signal_length/2+1]-1)/(signal_length);
f(f>200)=[];
no_freqs=length(f);

present_dir=pwd;

load('subjects.mat')
load('drugs.mat')
load('channels.mat')

for s=3:length(subjects)
    
    subject=subjects{s};
    subj_channels=channels{s};
    no_channels=length(subj_channels);
    
    channel_pairs=nchoosek(subj_channels,2);
    no_pairs=size(channel_pairs,1);
    
    for d=1:length(drugs)
        
        drug=drugs{d};
        
        subject_dir=[subject,'_',drug];
        cd (subject_dir)
        
        for p=1:no_pairs
            
            drug_dir=pwd;
            
            channel_pair=channel_pairs(p,:);
            
            channel_dir1=[subject_dir,'_chan',num2str(channel_pair(1)),'_epochs'];
            period_list1=[channel_dir1,'/',channel_dir1(1:end-length('_epochs')),'_hours_master.list'];
            periods1=textread(period_list1,'%s');
            no_periods1=length(periods1);
            
            channel_dir2=[subject_dir,'_chan',num2str(channel_pair(2)),'_epochs'];
            period_list2=[channel_dir2,'/',channel_dir2(1:end-length('_epochs')),'_hours_master.list'];
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
                    load([channel_dir2,'/',pd2_name(1:end-5),'_fft.mat']);
                    chan2_fft=all_fft;
                    no_epochs=size(chan2_fft,1);
                    
                    cohy(pd,:)=coherency(chan1_fft,chan2_fft);
                    
                    parfor sh=1:no_shufs
                        
                        chan1_fft_loc=chan1_fft; chan2_fft_loc=chan2_fft;
                        cohy_shuf(sh,:,pd)=coherency(chan1_fft_loc(randperm(no_epochs),:),chan2_fft_loc(randperm(no_epochs),:));
                        
                    end
                    
                end
                
                cohy_shuf_mean=reshape(nanmean(cohy_shuf),no_freqs,no_periods1)';
                cohy_shuf_stdr=reshape(nanstd(real(cohy_shuf)),no_freqs,no_periods1)';
                cohy_shuf_stdi=reshape(nanstd(imag(cohy_shuf)),no_freqs,no_periods1)';
                cohy_norm=real(cohy-cohy_shuf_mean)./cohy_shuf_stdr+sqrt(-1)*imag(cohy-cohy_shuf_mean)./cohy_shuf_stdi;
         
                pair_filename=sprintf('%s_ch%d_by_ch%d_cohy.mat',subject_dir,channel_pair);
                save(pair_filename,'cohy','cohy_norm','cohy_shuf_mean','cohy_shuf_stdr','cohy_shuf_stdi')
%                 save(pair_filename,'cohy','cohy_norm','cohy_shuf','-v7.3')
                
            else
               
                fprintf('Different number of periods in %s and %s.',channel_dir1,channel_dir2)
                
            end
            
            cd (drug_dir)
            
        end
        
        cd (present_dir)
        
    end
    
end