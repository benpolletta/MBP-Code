function Bout_wavelet_list_part2_clusters


[listname,listpath]=uigetfile('*.list','Choose a bout list to make clusters.');
% filenames=textread([listpath, listname],'%s%*[^\n]');

load([listpath, listname(1:end-5),'_POW',  '/', listname(1:end-5), '_All'], 'all_max_amp_theta', 'all_max_amp_low_gamma', 'all_max_amp_medium_gamma', 'all_max_amp_high_gamma', 'all_freq_theta', 'all_freq_low_gamma', 'all_freq_medium_gamma', 'all_freq_high_gamma', 'all_max_amp_HFO', 'all_freq_HFO');

no_timepoints=length(all_max_amp_theta);

x=[all_max_amp_theta' all_max_amp_low_gamma' all_max_amp_medium_gamma' all_max_amp_high_gamma' all_max_amp_HFO' all_freq_theta' all_freq_low_gamma' all_freq_medium_gamma' all_freq_high_gamma' all_freq_HFO'];

amp_label={'ta', 'lga','mga','hga', 'HFOa', 'tf', 'lgf', 'mgf', 'hgf', 'HFOf'};

no_bands=[61 101 121 81 141];
band_ranges=[4 10; 35 60; 60 90; 90 110; 110 180];

for i=1:5
    
    bins{i}=linspace(min(x(:,i)),max(x(:,i)),100);
    
    bins{5+i}=linspace(band_ranges(i,1),band_ranges(i,2),no_bands(i));
    
end

pairs=nchoosek(1:10,2);

for p=1:length(pairs)
    
    x_bins=bins{pairs(p,1)};
    y_bins=bins{pairs(p,2)};
    
    H=hist3([x(:,pairs(p,2)) x(:,pairs(p,1))],{y_bins, x_bins});
    H=H/no_timepoints;
    
    imagesc(H)
    axis xy
    colorbar
    
    x_tick_indices=1:floor(length(x_bins)/10):length(x_bins);
    y_tick_indices=1:floor(length(y_bins)/10):length(y_bins);
    
    set(gca,'XTick',x_tick_indices,'XTickLabel',x_bins(x_tick_indices),'YTick',y_tick_indices,'YTickLabel',y_bins(y_tick_indices))
    
    xlabel(amp_label{pairs(p,1)});
    ylabel(amp_label{pairs(p,2)});
    saveas(gcf, [listname(1:end-5),'_',amp_label{pairs(p,1)}, '_', amp_label{pairs(p,2)},'_hist.fig'])
    
end




