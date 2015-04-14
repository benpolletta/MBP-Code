function plot_cross_PAC_horiz(norm, freq_label, phase_range, amp_range)

load('drugs.mat')

no_drugs = length(drugs);

amps=20:5:200; phases=1:.25:12;

channels={'Frontal','Occipital','CA1'};

chan_pairs = [1 3; 3 1]; no_chan_pairs = size(chan_pairs, 1);

stats = {'median', 'mean'};
long_stats = {'Median', 'Mean'};

[pd_labels, pd_corder] = make_period_labels(2,8,'hrs'); no_pds = length(pd_labels);

xlabels = cell(no_chan_pairs*no_pds, 1);

for i = 1:no_chan_pairs*no_pds, xlabels{i} = 'Phase Freq. (Hz)'; end

ylabels = cell(4, 1);

%% Figures by drug.

for c = 1:no_chan_pairs
            
    channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
    
    for s = 1:length(stats)
        
        index = 1;
        
        for d = 1:4 % [4 1 2 3]
            
            ylabels{index} = {long_stats{s}; [channels{chan_pairs(c, 1)}, ' by ', channels{chan_pairs(c, 2)}, ', ', drugs{d}]; 'Amp. Freq. (Hz)'};
            
            for p=1:no_pds
                
                open([channel_name, '/', channel_name, norm, '_hrs_', drugs{d}, '_', drugs{d}, '_', pd_labels{p}, '_', stats{s}, '.fig'])
                
            end
            
            index = index+1;
            
        end
        
        if isempty(phase_range)
            
            phase_range = [min(phases) max(phases)];
        
        end
            
        if isempty(amp_range)
        
            amp_range = [min(amps) max(amps)];
            
        end
            
        figure_replotter_labels_subregion(1:4*no_pds, 4, no_pds, 'rows', 4, 7,...
            phases, amps, phase_range, amp_range, pd_labels, xlabels, ylabels)
            
        save_as_pdf(gcf, [channel_name, '/', channel_name, norm, '_MI_horiz_', stats{s}, freq_label])
        
        close('all')
        
    end
    
end

%% Figures by channel pair.

clear ylabels

for d = 1:no_drugs
    
    for s = 1:length(stats)
        
        for c = 1:no_chan_pairs
            
            ylabels{c} = {long_stats{s}; [channels{chan_pairs(c, 1)}, ' by ', channels{chan_pairs(c, 2)}, ', ', drugs{d}]; 'Amp. Freq. (Hz)'};
            
            channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
            
            for p = 1:length(pd_labels)
                
                open([channel_name, '/', channel_name, norm, '_hrs_', drugs{d}, '_', drugs{d}, '_', pd_labels{p}, '_', stats{s}, '.fig'])
                
            end
            
        end
        
        if isempty(phase_range)
            
            phase_range = [min(phases) max(phases)];
        
        end
            
        if isempty(amp_range)
        
            amp_range = [min(amps) max(amps)];
            
        end
        
        figure_replotter_labels_subregion(1:no_chan_pairs*no_pds, no_chan_pairs, no_pds, 'rows', 4, 7,...
            phases, amps, phase_range, amp_range, pd_labels, xlabels, ylabels)
        
        save_as_pdf(gcf, ['ALL_', drugs{d}, '_cross_MI_horiz_', stats{s}, freq_label])
        
        close('all')
        
    end
    
end

for c = 1:no_chan_pairs
            
    channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
    
    for s = 1:length(stats)
        
        open([channel_name, '/', channel_name, norm, '_MI_horiz_', stats{s}, freq_label, '.fig'])
        
    end
    
end

for d=1:4
    
    for s=1:length(stats)
        
        open(['ALL_', drugs{d}, '_cross_MI_horiz_', stats{s}, freq_label, '.fig'])
        
    end
    
end
