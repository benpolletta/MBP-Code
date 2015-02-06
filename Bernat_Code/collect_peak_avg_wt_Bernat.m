function collect_peak_avg_wt_Bernat(peak_freqs, start_index)

peak_freq_cycles = 3; sampling_freq = 1000; freqs = 1:200;
    
no_pre = 6; no_post = 24; total_pd_no = no_pre + no_post;

load('subjects')
load('drugs')
load('channels')

% max_phase = get_peak_freqs;

if isempty(start_index), start_index = 0; end

if isempty(peak_freqs), peak_freqs = [2.25 6.5 8]; end

no_peak_freqs = length(peak_freqs);

for p = 1:no_peak_freqs
    
    peak_freq = peak_freqs(p);
    
    index = 1;
    
    segment_length=floor(peak_freq_cycles*sampling_freq/peak_freq);
    if mod(segment_length,2)==0
        segment_length = segment_length + 1;
    end
            
    All_peak_no = zeros(total_pd_no, no_drugs, no_channels);
    
    [All_wt_power, All_wt_phase] = deal(zeros(length(freqs), segment_length, total_pd_no, no_drugs, no_channels));
    
    for c = 1:no_channels
        
        for d = 1:no_drugs
            
            for s = 1:no_subjects
                
                if index > start_index
                    
                    record_dir = [subjects{s}, '_', drugs{d}]
                    
                    channel_dir = [record_dir, '_chan', num2str(location_channels{c}(s))];
                    
                    cd (['/home/bp/Bernat_NMDAR_antagonists/', record_dir])
                    
                    pd_indices = get_pd_indices(channel_dir) + no_pre + 1; 
                    
                    pd_indices(pd_indices > total_pd_no) = []; no_pds = length(pd_indices);
                    
                    master_list = [channel_dir, '_epochs/', channel_dir, '_hours_master.list'];
                    
                    peak_wt_name = [master_list(1:end-5), '_', num2str(peak_freq), '_peak_wav.mat'];
                    
                    load(peak_wt_name)
                    
                    for pd = 1:no_pds
                        
                        pd, pd_indices(pd)
                        
                        All_peak_no(pd_indices(pd), d, c) = All_peak_no(pd_indices(pd), d, c) + total_peaks(pd);
                        
                        All_wt_power(:, :, pd_indices(pd), d, c) = All_wt_power(:, :, pd_indices(pd), d, c) + mean_wt_power(:, :, pd)*total_peaks(pd);
                        
                        All_wt_phase(:, :, pd_indices(pd), d, c) = All_wt_phase(:, :, pd_indices(pd), d, c) + mean_wt_phase(:, :, pd)*total_peaks(pd);
                        
                    end
                    
                    cd '/home/bp/Bernat_NMDAR_antagonists'
                
                end
                    
                index = index + 1;
                
            end
            
        end
        
    end
                    
    save(['All_', num2str(peak_freq), '_peak_wav.mat'], 'All_peak_no', 'All_wt_power', 'All_wt_phase') 
    
end

end

function pd_indices = get_pd_indices(channel_dir)
    
    master_list = [channel_dir, '_epochs/', channel_dir, '_hours_master.list'];

    lists = text_read(master_list, '%s');
    
    no_pds = length(lists); pd_indices = zeros(no_pds, 1);
    
    for pd = 1:no_pds
       
        pd_list = lists{pd};
        
        pd_suffix = pd_list((length(channel_dir) + 2):(end - 5));
        
        if strcmp(pd_suffix(1:3), 'pre')
           
            pd_indices(pd) = (-1)*str2num(pd_suffix(4:end));
            
        else
            
            pd_indices(pd) = str2num(pd_suffix(5:end));
            
        end
        
    end
    
end