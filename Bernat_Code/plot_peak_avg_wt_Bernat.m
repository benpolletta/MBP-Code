function plot_peak_avg_wt_Bernat(peak_freqs)

peak_freq_cycles = 3; sampling_freq = 1000; freqs = 1:200;
    
no_pre = 6; no_post = 24; total_pd_no = no_pre + no_post;

no_plot_pre = 2; no_plot_post = 8; 

plot_indices = [-no_plot_pre:-1:-1 1:no_plot_post] + no_pre + 1; no_plot_pds = length(plot_indices);

load('subjects')
load('drugs')
load('channels')

% max_phase = get_peak_freqs;

if isempty(peak_freqs), peak_freqs = [2.25 6.5 8]; end

no_peak_freqs = length(peak_freqs);

for p = 1:no_peak_freqs
    
    peak_freq = peak_freqs(p);
    
    segment_length=floor(peak_freq_cycles*sampling_freq/peak_freq);
    if mod(segment_length,2)==0
        segment_length = segment_length + 1;
    end
    
    t = ((1:segment_length) - (segment_length/2))/sampling_freq;
    
    load(['All_', num2str(peak_freq), '_peak_wav.mat'])
    
    for c = 1:no_channels
        
        figure
        
        for d = 1:no_drugs
            
            for pd = 1:no_plot_pds
                
                wt_power = All_wt_power(:, :, plot_indices(pd), d, c)/All_peak_no(plot_indices(pd), d, c);
                
                subplot(no_drugs, no_plot_pds, (d - 1)*no_plot_pds + pd)
                        
                imagesc(t, freqs, zscore(wt_power')')
                
                %% How do I fix the color limits?
                
                axis xy
                
            end
            
        end
                    
        save_as_pdf(gcf, ['All_', drugs{d}, '_', channel_names{c}, '_', num2str(peak_freq), '_peak_wav'])
        
    end
    
end

end