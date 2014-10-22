function run_GC_Bernat

f_length = 2^14 + 1;

load('channels.mat')
load('subjects.mat')
load('drugs.mat')

channel_mat = nan(no_subjects, no_channels);

for c = 1:no_channels

    channel_mat(:, c) = location_channels{c}';

end
    
index = 0; % For when it gets stopped in the middle somwhere...

for s = 1:no_subjects
    
    subject=subjects{s};
    
    for d=1:length(drugs)
        
        index = index + 1;
        
        if index > 0
        
        drug=drugs{d};
        
        subject_dir=[subject,'_',drug];
        cd (subject_dir)
        
        [channel_dir, period_list, periods] = deal(cell(no_channels, 1));
        no_periods = nan(no_channels, 1);
        
        for c = 1:no_channels
            
            channel_dir{c} = [subject_dir,'_chan',num2str(channel_mat(s, c)),'_epochs'];
            period_list{c} = [channel_dir{c},'/',channel_dir{c}(1:end-length('_epochs')),'_hours_master.list'];
            periods{c} = text_read(period_list{c},'%s');
            no_periods(c) = length(periods{c});
            
        end
        
        if range(no_periods) == 0
            
            no_periods = mean(no_periods);
            
            triplet_dir = sprintf('%s_ch%d_ch%d_ch%d_GC', subject_dir, channel_mat(s, :));
            mkdir (triplet_dir)
            
            avg_GC = nan(no_periods, 8);
            avg_GC_spec = nan(no_periods, f_length, 2);
            
            %% Calculating GC by period.
            
            for pd = 1:no_periods
                
                [pd_listname, pd_list] = deal(cell(no_channels, 1));
                
                for c = 1:no_channels
                    
                    pd_listname{c} = periods{c}{pd};
                    pd_list{c} = text_read([channel_dir{c}, '/', pd_listname{c}], '%s%*[^\n]');
                    
                end
                
                pd_name = pd_listname{1}((length(channel_dir{1}) - length('epochs') + 1):(end - 5));
                pd_tripletname = sprintf('%s_ch%d_ch%d_ch%d_%s_GC', subject_dir, channel_mat(s, :), pd_name);

                no_epochs=length(pd_list{2});
                
                %% Calculating GC.
                
                pd_GC = nan(no_epochs, 8);
                pd_GC_spec = nan(no_epochs, f_length, 2);
                
                for e=1:no_epochs
                
                    data_name = [pd_tripletname(1:(end - 2)), 'epoch', num2str(e)];
                    
                    data = nan(f_length - 1, no_channels);
                    
                    for c = 1:no_channels
                        
                        epoch_name = pd_list{c}{e};
                        
                        chan_data = load(epoch_name); %[channel_dir{c}, '/', epoch_name]);
                        
                        data(:, c) = chan_data;
                        
                    end
                    
                    tic; [moAIC, info, F, pval, sig, f] = mvgc_analysis(data, 100, data_name, 2); toc;
                    
                    F = reshape(F, 9, 1); F([1 5 9]) = [];
                    
                    pval = reshape(pval, 9, 1); pval([1 5 9]) = [];
                    
                    sig = reshape(sig, 9, 1); sig([1 5 9]) = [];
                    
                    f = reshape(f, [1 9 f_length]); f(:, [1 5 9], :) = [];
                    
                    pd_GC(e, :) = [moAIC info.error F pval sig];
                    
                    pd_GC_spec(e, :, :) = permute(f, [1 3 2]);
                    
                end
                
                avg_GC(pd, :) = nanmean(pd_GC);
                avg_GC_spec(pd, :, :) = nanmean(pd_GC_spec);
                
                % %% Shuffling.
                % 
                % [ch1_indices,ch2_indices]=random_pairs(no_shufs,no_epochs);
                % no_shufs = length(ch1_indices);
                % 
                % pd1_shuf_list = pd1_list(ch1_indices);
                % pd2_shuf_list = pd2_list(ch2_indices);
                % 
                % shuffle_indices = [ch1_indices ch2_indices];
                % save([triplet_dir,'/',pd_tripletname,'_shuffles.mat'],'shuffle_indices')
                % 
                % shuf_PP=zeros(no_shufs,no_bands_hi+no_bands_lo);
                % shuf_PLV=zeros(no_shufs,no_bands_hi+no_bands_lo);
                % 
                % parfor sh=1:no_shufs
                % 
                %     epoch1_name = pd1_shuf_list{sh};
                %     epoch2_name = pd2_shuf_list{sh};
                % 
                %     mat1 = load([channel_dir1,'/',epoch1_name(1:end-4),'_AP.mat']);
                %     mat2 = load([channel_dir2,'/',epoch2_name(1:end-4),'_AP.mat']);
                % 
                %     [PP,plv]=PLV([mat1.P_lo mat1.P_hi],[mat2.P_lo mat2.P_hi]);
                % 
                %     shuf_PP(sh,:)=PP;
                %     shuf_PLV(sh,:)=plv;
                % 
                % end
                % 
                % avg_shuf_PP(pd,:) = nanmean(exp(sqrt(-1)*shuf_PP));
                % avg_shuf_PLV(pd,:) = nanmean(shuf_PLV);
                % 
                % thresh_PLV = (pd_GC_spec - repmat(nanmean(shuf_PLV),no_epochs,1))./repmat(nanstd(shuf_PLV),no_epochs,1);
                % 
                % avg_thresh_PLV(pd,:) = nanmean(thresh_PLV);
                
                save([triplet_dir, '/', pd_tripletname, '.mat'], 'pd_GC', 'pd_GC_spec')
                
            end
            
            save([triplet_dir, '/', triplet_dir, '.mat'], 'avg_GC','avg_GC_spec')
            
        else
            
            fprintf('Different number of periods in %s, %s, and %s.', channel_dir{1}, channel_dir{2}, channel_dir{3})
            
        end
        
        cd (present_dir)
        
        end
    
    end
    
end