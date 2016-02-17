function run_multivar_PAC_subject_drug(subject, hour, drug, low_freq, hi_freqs, plot_opt)

if isempty(hi_freqs), hi_freqs = [65 95 140]; end

no_freqs = length(hi_freqs) + 1;

sampling_freq = 1000;

present_dir = '/projectnb/crc-nak/brpp/Bernat_NMDAR_antagonists';

cd (present_dir)

load('subjects.mat'), load('drugs.mat'), load('channels.mat'),

subj_index = strcmp(subjects, subject);

for c = 1:no_channels, subj_channel_indices(c) = location_channels{c}(subj_index); end

hour_dir = [subject, '_', drug, '_post', num2str(hour), '_epochs'];

cd (hour_dir)

epoch_numbers = load([hour_dir, '_numbers.mat']); epoch_numbers = epoch_numbers.epoch_numbers;

no_epochs = length(epoch_numbers);

hour_kappa = nan(no_epochs, (no_freqs*no_channels)^2);

%% Computing multivariate PAC.

if isempty(dir([subject, '_', drug, '_post', num2str(hour), '_', num2str(low_freq), 'Hz_multivar_PAC.mat']))
    
    parfor e = 1:no_epochs
        
        epoch_data = get_data(subject, drug, subj_channel_indices, epoch_numbers(e)*ones(1, 3));
        
        epoch_kappa = multivar_PAC(epoch_data, sampling_freq, low_freq, hi_freqs, 0);
        
        hour_kappa(e, :) = reshape(epoch_kappa, 1, numel(epoch_kappa));
        
    end
    
    save([subject, '_', drug, '_post', num2str(hour), '_', num2str(low_freq), 'Hz_multivar_PAC.mat'], 'hour_kappa', 'low_freq', 'hi_freqs')
    
else

    load([subject, '_', drug, '_post', num2str(hour), '_', num2str(low_freq), 'Hz_multivar_PAC.mat'])
    
end

%% Shuffling.

if ~exist('hour_kappa_shuffled', 'var')
    
    no_shufs = 1000;
    
    hour_kappa_shuffled = nan(no_shufs, (no_freqs*no_channels)^2);
    
    tuples = random_tuples(no_shufs, no_epochs, 3);
    
    shuf_indices = epoch_numbers(tuples);
    
    parfor s = 1:no_shufs
        
        shuf_data = get_data(subject, drug, subj_channel_indices, shuf_indices(s, :));
        
        shuffle_kappa = multivar_PAC(shuf_data, sampling_freq, low_freq, hi_freqs, 0);
        
        hour_kappa_shuffled(s, :) = reshape(shuffle_kappa, 1, numel(shuffle_kappa));
        
    end
    
    save([subject, '_', drug, '_post', num2str(hour), '_', num2str(low_freq), 'Hz_multivar_PAC.mat'], '-append', 'hour_kappa_shuffled', 'shuf_indices')
    
end

%% z-Scoring.

if ~exist('hour_kappa_zscored', 'var')
   
    hour_kappa_shuf_mean = ones(size(hour_kappa))*diag(nanmean(abs(hour_kappa_shuffled)));
    
    hour_kappa_shuf_std = ones(size(hour_kappa))*diag(nanstd(abs(hour_kappa_shuffled)));
    
    hour_kappa_zscored = (abs(hour_kappa) - hour_kappa_shuf_mean)./hour_kappa_shuf_std;
    
    save([subject, '_', drug, '_post', num2str(hour), '_', num2str(low_freq), 'Hz_multivar_PAC.mat'], '-append', 'hour_kappa_zscored')
    
end

figure

if plot_opt
    
    tick_labels = cell(no_freqs*no_channels, 1);
    
    for c = 1:no_channels
        
        tick_labels{(c - 1)*no_freqs + 1} = [display_channel_names{c}, ', ', num2str(low_freq), ' Hz'];
        
        for f = 1:(no_freqs - 1)
            
            tick_labels{(c - 1)*no_freqs + f + 1} = [display_channel_names{c}, ', ', num2str(hi_freqs(f)), ' Hz'];
            
        end
        
    end
    
    imagesc(reshape(nanmean(hour_kappa_zscored), no_freqs*no_channels, no_freqs*no_channels))
    
    axis xy
    
    set(gca, 'XTick', 1:(no_freqs*no_channels), 'XTickLabel', tick_labels, 'YTick', 1:(no_freqs*no_channels), 'YTickLabel', tick_labels)
    
    colorbar
   
    save_as_pdf(gcf, [subject, '_', drug, '_post', num2str(hour), '_', num2str(low_freq), 'Hz_multivar_PAC'])
    
end

cd (present_dir)

end

function data = get_data(subject, drug, channels, epochs)

        for c = 1:length(channels)
            
            data(:, c) = load([subject, '_', drug, '_chan',...
                num2str(channels(c)), '_epoch', num2str(epochs(c)), '.txt']);
            
        end

end