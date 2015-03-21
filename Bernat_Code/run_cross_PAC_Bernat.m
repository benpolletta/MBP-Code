function run_cross_PAC_Bernat(no_shufs, chan1_channels, chan2_channels)

% pair_dir = sprintf('All_%s_A_by_%s_P_PAC', chan1_name, chan2_name);
% mkdir (pair_dir)

sampling_freq = 1000; nobins = 20;

bands_lo = 1:.25:12;
no_bands_lo = length(bands_lo);
bands_hi = 20:5:200;
no_bands_hi = length(bands_hi);
present_dir=pwd;

load('subjects.mat')
load('drugs.mat')

index = 0; % For when it gets stopped in the middle somwhere...

for s = 1:min(length(chan1_channels),length(chan2_channels))
    
    subject=subjects{s};
    subj_chan1=chan1_channels(s);
    subj_chan2=chan2_channels(s);
    
    channel_pair=[subj_chan1 subj_chan2];
    
    for d = 1:length(drugs)
        
        index = index + 1;
        
        if index > 0 %3*4 + 1
        
        drug=drugs{d};
        
        subject_dir=[subject,'_',drug];
        cd (subject_dir)
        
        channel_dir1=[subject_dir,'_chan',num2str(channel_pair(1)),'_epochs'];
        period_list1=[channel_dir1,'/',channel_dir1(1:end-length('_epochs')),'_hours_master.list'];
        periods1=text_read(period_list1,'%s');
        no_periods1=length(periods1);
        
        channel_dir2=[subject_dir,'_chan',num2str(channel_pair(2)),'_epochs'];
        period_list2=[channel_dir2,'/',channel_dir2(1:end-length('_epochs')),'_hours_master.list'];
        periods2=text_read(period_list2,'%s');
        no_periods2=length(periods2);
        
        %if isempty(dir([channel_dir1,'/*AP.mat']))
            
            channels_listname = [subject_dir,'_channels.list'];
%             delete(channels_listname)
            fid = fopen(channels_listname,'w');
            fprintf(fid,'%s\n',[channel_dir1,'.list']);
            fclose(fid);
            
            wavelet_mouse_eeg_HAP(sampling_freq,channels_listname);
            
        %end
        
        %if isempty(dir([channel_dir2,'/*AP.mat']))
            
            channels_listname = [subject_dir,'_channels.list'];
%             delete(channels_listname)
            fid = fopen(channels_listname,'w');
            fprintf(fid,'%s\n',[channel_dir2,'.list']);
            fclose(fid);
            
            wavelet_mouse_eeg_HAP(sampling_freq,channels_listname);
            
        %end
        
        if no_periods1==no_periods2
            
            pair_dir=sprintf('%s_ch%d_A_by_ch%d_P_PAC', subject_dir, channel_pair);
            mkdir (pair_dir)
            
            avg_MI=nan(no_periods1,no_bands_hi*no_bands_lo);
            avg_thresh_MI=nan(no_periods1,no_bands_hi*no_bands_lo);
            
            %% Calculating PLV and shuffled PLV by period.
            
            for pd = 1:no_periods1
                
                pd1_listname=periods1{pd};
                pd2_listname=periods2{pd};
                
                pd_name = pd1_listname(length(channel_dir1)-length('epochs')+1:end-5);
                pd_pairname = sprintf('%s_ch%d_A_by_ch%d_P_%s_PAC', subject_dir, channel_pair, pd_name);
                
                pd1_list=text_read([channel_dir1,'/',pd1_listname],'%s%*[^\n]');
                pd2_list=text_read([channel_dir2,'/',pd2_listname],'%s%*[^\n]');

                no_epochs=length(pd2_list);
                
                %% Calculating PLV.
                
                pd_MI = nan(no_epochs, no_bands_hi*no_bands_lo);
                
                parfor e = 1:no_epochs
                
                    epoch1_name = pd1_list{e};
                    epoch2_name = pd2_list{e};
                    
                    mat1 = load([channel_dir1,'/',epoch1_name(1:end-4),'_AP.mat']);
                    mat2 = load([channel_dir2,'/',epoch2_name(1:end-4),'_AP.mat']);
                    
                    % Computing amplitude vs. phase curves.
                    
                    [~, M] = amp_v_phase_Jan(nobins, mat1.A_hi, mat2.P_lo);
                    
                    % Finding inverse entropy measure for each pair of modes.
                    
                    MI = inv_entropy_no_save(M);

                    pd_MI(e, :) = reshape(MI, 1, no_bands_hi*no_bands_lo);
                    
                end
                
                avg_MI(pd, :) = nanmean(pd_MI);
                
                %% Shuffling.
            
                avg_shuf_MI = nan(no_shufs,no_bands_hi*no_bands_lo);
                
                [ch1_indices,ch2_indices]=random_pairs(no_shufs,no_epochs);
                no_shufs = length(ch1_indices);
                
                pd1_shuf_list = pd1_list(ch1_indices);
                pd2_shuf_list = pd2_list(ch2_indices);
                
                shuffle_indices = [ch1_indices ch2_indices];
                save([pair_dir,'/',pd_pairname,'_shuffles.mat'], 'shuffle_indices')
                
                shuf_MI = zeros(no_shufs, no_bands_hi*no_bands_lo);
                
                parfor sh = 1:no_shufs
                    
                    epoch1_name = pd1_shuf_list{sh};
                    epoch2_name = pd2_shuf_list{sh};
                    
                    mat1 = load([channel_dir1,'/',epoch1_name(1:end-4),'_AP.mat']);
                    mat2 = load([channel_dir2,'/',epoch2_name(1:end-4),'_AP.mat']);
                    
                    % Computing amplitude vs. phase curves.
                    
                    [~, M] = amp_v_phase_Jan(nobins, mat1.A_hi, mat2.P_lo);
                    
                    % Finding inverse entropy measure for each pair of modes.
                    
                    MI = inv_entropy_no_save(M);
                    
                    shuf_MI(sh,:) = reshape(MI, 1, no_bands_hi*no_bands_lo);
                    
                end
                
                avg_shuf_MI(pd,:) = nanmean(shuf_MI);
                
                thresh_MI = (pd_MI - repmat(nanmean(shuf_MI),no_epochs,1))./repmat(nanstd(shuf_MI),no_epochs,1);
                
                avg_thresh_MI(pd,:) = nanmean(thresh_MI);
                
                save([pair_dir,'/',pd_pairname,'.mat'], 'pd_MI', 'shuf_MI', 'thresh_MI')
                
            end
            
            save([pair_dir,'/',pair_dir,'.mat'], 'avg_MI', 'avg_shuf_MI', 'avg_thresh_MI')
            
            delete([channel_dir1,'/*AP.mat'])
            delete([channel_dir2,'/*AP.mat'])
            
        else
            
            fprintf('Different number of periods in %s and %s.',channel_dir1,channel_dir2)
            
        end
        
        cd (present_dir)
        
        end
    
    end
    
end