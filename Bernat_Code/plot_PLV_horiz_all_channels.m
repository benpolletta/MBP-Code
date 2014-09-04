function plot_PLV_horiz_all_channels

load('drugs.mat') % Drugs.
no_drugs = length(drugs);

freqs=[1:.25:12 20:5:200]; % Frequencies.
no_freqs = length(freqs);
freq_indices{1} = find(freqs < 15); freq_indices{2} = find(freqs > 15);

no_pre=4; no_post=12; % 6 minute periods.
[pd_labels,pd_corder]=make_period_labels(no_pre,no_post,'6mins');
no_pds = length(pd_labels);

pd_vec = nan(no_pds, 1);
for pd = 1:no_pds, pd_vec(pd) = str2double(pd_labels{pd}); end

stats={'median','mean','std'};
long_stats={'Median','Mean','St. Dev.'};
no_stats = length(stats);

channels={'Frontal','Occipital','CA1'};
channel_pairs = nchoosek(1:3,2);
no_chan_pairs = size(channel_pairs,1);

chanpair_label = cell(no_chan_pairs, 1);

for cp = 1:no_chan_pairs
    
    cp_label{cp} = [channels{channel_pairs(cp, 1)}, '_by_', channels{channel_pairs(cp, 2)}];
    
    chanpair_label{cp} = [channels{channel_pairs(cp, 1)}, ' by ', channels{channel_pairs(cp, 2)}];
    
end

norms={'','_pct','_zs'};
long_norms={'','Pct. of Baseline','z-Scored'};
no_norms = length(norms);

mkdir ALL_PLV

for n = 1:no_norms
    
    ALL_PLV_stats = nan(no_freqs, no_drugs, no_pds, no_stats, no_chan_pairs);
    
    for cp = 1:no_chan_pairs
        
        load(['ALL_', cp_label{cp}, '_PLV/ALL_', cp_label{cp}, '_PLV', norms{n}, '_6mins_spec_stats_for_cplot.mat'])
        
        All_PLV_stats(:, :, :, :, cp) = spec_stats;
        
    end
    
    save(['ALL_PLV/ALL_PLV_', norms{n}, '_stats_for_cplot.mat'],'ALL_PLV_stats')
    
    for s = 1:no_stats
        
        for d = 1:no_drugs
            
            figure
            
            for cp = 1:no_chan_pairs
                
                for f = 1:length(freq_indices)
                    
                    subplot(no_chan_pairs, 2, 2*cp - (2 - f))
                    
                    plot_data = reshape(All_PLV_stats(freq_indices{f}, d, :, s, cp), length(freq_indices{f}), no_pds);
                    
                    imagesc(pd_vec, freqs(freq_indices{f}), plot_data)
                    
                    axis xy
                    
                    colorbar
                    
                    if f == 1
                    
                        ylabel({chanpair_label{cp}; 'Frequency (Hz.)'})
                    
                    end
                    
                    if cp == no_chan_pairs
                       
                        xlabel('Time Rel. Injection (min.)')
                        
                    end
                    
                    title({[long_stats{s}, ' ', drugs{d}, ' PLV, ', long_norms{n}]; [num2str(min(freqs(freq_indices{f}))), ' to ',...
                        num2str(max(freqs(freq_indices{f}))), ' Hz']})
                        
                end
                
            end
            
            save_as_pdf(gcf, ['ALL_PLV/ALL_PLV_', norms{n}, '_', drugs{d}, '_', stats{s}, '_cplot'])
            
        end
        
    end
    
end
