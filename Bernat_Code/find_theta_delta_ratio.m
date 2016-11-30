function find_theta_delta_ratio(drug)

load('subjects.mat'), load('channels.mat')

ch_selected = [1 3];

present_dir = pwd;

for s = 1:length(subjects)
    
    subject = subjects{s};
    
    record_dir = [subjects{s}, '_', drug];
    
    cd (record_dir)
    
    for ch = 1:2
        
        ch_i = ch_selected(ch);
        
        ch_no = location_channels{s}(ch_i);
        
        epoch_list = sprintf('%s_chan%d_epochs.list', record_dir, ch_no);
        
        epoch_names{ch} = text_read(epoch_list, '%s');
        
        epoch_no(ch) = length(epoch_names);
        
    end
    
    if diff(epoch_no) ~= 0
        
        display(sprintf('For %s, the number of epochs for channel %d and channel %d are different (%d vs. %d).',...
            subjects{s}, location_channels{s}(ch_selected), epoch_no))
       
        return
        
    end
    
    [power, max] = deal(nan(epoch_no(1), 2));
    
    parfor e = 1:epoch_no(1)
        
        for ch = 1:2
        
            data(:, ch) = load(epoch_names{ch}{e});
            
        end
        
        [whm(e), shm_sum(e), max_freqs(e), max_vals(e), entropy(e)] = width_half_max(data, 1000, [0.25 4.75], .075, 0);
        
    end
    
    cd (present_dir)
    
    save([record_dir, '_chan1_whm.mat'], 'whm', 'shm_sum', 'max_freqs', 'max_vals', 'entropy')
    
    whm_mat = [whm shm_sum entropy]; no_criteria = size(whm_mat, 2);
    
    crit_labels = {'whm', 'shm_sum', 'entropy'};
    
    figure
    
    for c = 1:no_criteria
        
        subplot(2, no_criteria, c)
        
        [n, centers] = hist(whm_mat(:, c), 25);
        
        plot(centers, n)
        
        axis tight
        
        title(crit_labels{c})
        
        subplot(2, no_criteria, no_criteria + c)
        
        plot(whm_mat(:, c), '*')
        
        axis tight
        
    end
    
    save_as_pdf(gcf, [record_dir, '_chan1_whm'])
    
end