function MI_only_MK801_NVP_figure % (hi_hr, cplot_norm)

hi_hr = 'drug'; cplot_norm = '';

phase_freqs = 1:.25:12; amp_freqs = 20:5:200;
no_pfs = length(phase_freqs); no_afs = length(amp_freqs);

load('channels.mat'), no_channels = length(channel_names);

load('drugs.mat')

stats={'median'}; %,'mean','std'}; 
no_stats = length(stats);
long_stats={'Median'}; % ,'Mean','St. Dev.'};

norms={''}; % , '_pct'}; 
no_norms = length(norms);
long_norms={''}; % , '% Change'};% From Baseline'};

no_pre=4; no_post=12;
[hr_labels, ~, long_hr_labels] = make_period_labels(no_pre, no_post, 'hrs');
no_hr_periods = length(hr_labels);

no_pre=4; no_post=16;
[BP_hr_labels, ~, ~] = make_period_labels(no_pre, no_post, 'hrs');
no_BP_hr_periods = length(BP_hr_labels);
short_BP_hr_labels = -4:16; short_BP_hr_labels(short_BP_hr_labels == 0) = [];

tick_spacing = floor(no_BP_hr_periods/5);

no_bands = 6;
            
bands_plotted = [2 5 6]; no_bands_plotted = length(bands_plotted);

drug_p_val_index = [1 4 2 3];

c_order = [0 0 1; 0 .5 0; 1 0 0];
    
clear titles xlabels ylabels

preinj_data = nan(no_afs, no_pfs, no_stats, no_channels, no_norms);
           
All_cplot_data = nan(no_afs, no_pfs, no_drugs, no_hr_periods, no_stats, no_channels, no_norms);

All_BP_stats = nan(no_BP_hr_periods, no_channels, no_bands, no_stats, no_drugs, no_norms);

[All_BP_ranksum, All_BP_test] = deal(nan(no_BP_hr_periods, no_channels, no_bands, no_drugs - 1, no_norms));
    
for n=1:no_norms
    
    for c=1:no_channels
        
        ch_dir = ['ALL_', channel_names{c}];
            
        %% Getting colorplot data.
        
        for d = 1:(no_drugs - 1)
            
            load([ch_dir,'/',ch_dir,'_p0.99_IEzs_MI','/',...
                ch_dir,'_p0.99_IEzs_hrMI_hr',norms{n},'_',drugs{d},'_cplot_data.mat'])
            
            All_cplot_data(:, :, d, :, :, c, n) = MI_stats(:, :, 1, :, 1);
            
        end
        
    end
    
end

if strcmp(hi_hr, 'independent')

    [~, max_hr_indices] = nanmax(nanmax(nanmax(All_cplot_data(:, :, :, 5:end, :, :, :))), [], 4);
    
    max_hr_indices = reshape(max_hr_indices, no_drugs, no_stats, no_channels, no_norms);

elseif strcmp(hi_hr, 'drug')
   
    [~, max_hr_indices] = nanmax(nanmax(nanmax(nanmax(All_cplot_data(:, :, :, 5:end, :, :, :))), [], 6), [], 4);
    
    max_hr_indices = repmat(reshape(max_hr_indices, no_drugs, no_stats, 1, no_norms), [1 1 no_channels 1]);
    
end

handle = nan(no_drugs, no_norms, no_stats);

All_cplot_for_plot = nan(no_afs, no_pfs, no_drugs + 1, no_stats, no_channels, no_norms);

% All_cplot_for_plot(:, :, 1, :, :, :) = permute(preinj_data(:, :, :, :, :), [1 2 6 3 4 5]);

for n = 1:no_norms
    
    for c = 1:no_channels
        
        for s = 1:no_stats
            
            % All_cplot_for_plot(:, :, 1, s, c, n) = preinj_data(:, :, s, c, n);
            
            for d = 1:(no_drugs - 1)
                
                All_cplot_for_plot(:, :, d, s, c, n) = All_cplot_data(:, :, d, max_hr_indices(d, s, c, n) + 4, s, c, n)...
                    - All_cplot_data(:, :, 1, max_hr_indices(d, s, c, n) + 4, s, c, n);
                
            end
            
        end
        
    end
    
end

if strcmp(cplot_norm, '_row')
    
    max_by_channel = reshape(nanmax(nanmax(nanmax(All_cplot_for_plot))), no_stats, no_channels, no_norms);
    
    min_by_channel = reshape(nanmin(nanmin(nanmin(All_cplot_for_plot))), no_stats, no_channels, no_norms);
    
elseif strcmp(cplot_norm, '_col')
    
    max_by_drug = reshape(nanmax(nanmax(nanmax(All_cplot_for_plot)), [], 5), no_drugs + 1, no_stats, no_norms);
    
    min_by_drug = reshape(nanmin(nanmin(nanmin(All_cplot_for_plot)), [], 5), no_drugs + 1, no_stats, no_norms);
    
end

for n = 1:no_norms
    
    for s = 1:no_stats
        
        handle(n, s) = figure;
        
        for c = 1:no_channels
            
            for d = 2:(no_drugs - 1)
                
                %% Plotting comodulograms.
                
                subplot(no_channels, (no_drugs - 2), (c - 1)*(no_drugs - 2) + d - 1)
                
                imagesc(phase_freqs, amp_freqs, All_cplot_for_plot(:, :, d, s, c, n))
                
                if strcmp(cplot_norm, '_row')
                    
                    caxis([min_by_channel(s, c, n) max_by_channel(s, c, n)])
                    
                    if d == no_drugs - 1
                        
                        colorbar('FontSize', 16)
                        
                    end
                    
                elseif strcmp(cplot_norm, '_col')
                    
                    caxis([min_by_drug(d, s, n) max_by_drug(d, s, n)])
                    
                    colorbar('FontSize', 16)
                    
                else
                    
                    c_lims = caxis;
                    
                    caxis([max(c_lims(1), -abs(c_lims(2))) c_lims(2)])
                    
                    colorbar('FontSize', 16)
                    
                end
                
                axis xy
                
                set(gca, 'FontSize', 16)
                
                if c == 1
                    
                    title({drugs{d}; [long_stats{s}, ' MI, ', long_norms{n}, long_hr_labels{max_hr_indices(d, s, c, n) + 4}]})
                    
                % else
                % 
                %     title(long_hr_labels{max_hr_indices(d - 1, s, c, n) + 4 - 1})
                    
                end
            
                if d == 2, ylabel(channel_names(c)), end
                
            end
            
        end
                
        save_as_pdf(gcf,['MI_only',norms{n},'_multichannel_MK801_NVP_', hi_hr, '_hi_', stats{s}, cplot_norm]) %, 'orientation', 'portrait')
        
    end
    
end

end
