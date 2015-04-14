function plot_cross_PAC_horiz_by_state(norm, freq_label, phase_range, amp_range)

load('drugs.mat')

amps=20:5:200; phases=1:.25:12;

channels = {'Frontal','Occipital','CA1'};

chan_pairs = [1 3; 3 1]; no_chan_pairs = size(chan_pairs, 1);

stats={'median','mean'}; no_stats = length(stats);
long_stats={'Median','Mean'};

states={'W','NR','R'}; no_states = length(states);
long_states={'Active Wake','NREM/Quiet Wake','REM'};

[pd_labels, pd_corder] = make_period_labels(4, 16, '4hrs'); no_pds = length(pd_labels);

xlabels = cell(no_chan_pairs*no_pds, 1);

for i = 1:no_chan_pairs*no_pds, xlabels{i} = 'Phase Freq. (Hz)'; end

ylabels = cell(no_stats, 1);

for c = 1:no_chan_pairs
            
    channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
                
    chan_pair_label = [channels{chan_pairs(c, 1)}, ' by ', channels{chan_pairs(c, 2)}, ' MI'];
    
    for s = 1:no_stats
        
        for st = 1:no_states
            
            index = 1;
            
            for d = 1:4; % [4 1 2 3]
                
                ylabels{index}={[long_states{st}, ', ', long_stats{s}]; [chan_pair_label, ', ', drugs{d}]; 'Amp. Freq. (Hz)'};
                
                for p=1:length(pd_labels)
                    
                    open([channel_name, '/', channel_name, norm, '_4hrs_by_state_',...
                        drugs{d}, '_', drugs{d}, '_', states{st}, '_', pd_labels{p}, '_', stats{s}, '.fig'])
                    
                end
                
                index=index+1;
                
            end
            
            if isempty(phase_range)
                
                phase_range = [min(phases) max(phases)];
                
            end
            
            if isempty(amp_range)
                
                amp_range = [min(amps) max(amps)];
                
            end
            
            figure_replotter_labels_subregion(1:4*length(pd_labels), 4, length(pd_labels), 'rows', 4, 7,...
                phases, amps, phase_range, amp_range, pd_labels, xlabels, ylabels)
            
            save_as_pdf(gcf, [channel_name, '/', channel_name, '_cross_MI_horiz_', states{st}, '_', stats{s}, freq_label])
            
            close('all')
            
        end
        
    end
    
end

clear ylabels

for d = 1:4
    
    for s = 1:no_stats
        
        for st = 1:no_states
            
            for c = 1:no_chan_pairs
            
                channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
                
                chan_pair_label = sprintf('%s by %s MI', channels{chan_pairs(c, :)});
                
                ylabels{c}={[long_states{st}, ', ', long_stats{s}]; [chan_pair_label, ', ', drugs{d}]; 'Amp. Freq. (Hz)'};
                
                for p=1:length(pd_labels)
                    
                    open([channel_name, '/', channel_name, norm, '_4hrs_by_state_',...
                        drugs{d}, '_', drugs{d}, '_', states{st}, '_', pd_labels{p}, '_', stats{s}, '.fig'])
                    
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
            
            save_as_pdf(gcf, ['ALL_', drugs{d}, '_cross_MI_horiz_', states{st}, '_', stats{s}, freq_label])
            
            close('all')
            
        end
        
    end
    
end

for c=1:no_chan_pairs
            
    channel_name = sprintf('ALL_%s_A_by_%s_P_PAC', channels{chan_pairs(c, :)});
    
    for s=1:no_stats
        
        for st=1:no_states
            
            open([channel_name, '/', channel_name, '_cross_MI_horiz_', states{st}, '_', stats{s}, '.fig'])
            
        end
        
    end
    
end

for d=1:4
    
    for s=1:no_stats
       
        for st=1:no_states
            
            open(['ALL_', drugs{d}, '_cross_MI_horiz_', states{st}, '_', stats{s}, freq_label, '.fig'])
            
        end
        
    end
    
end
