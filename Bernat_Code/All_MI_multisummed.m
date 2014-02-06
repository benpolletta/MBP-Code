function All_MI_multisummed(channel_label,measure_suffix,amp_limits,phase_limits)

phase_freqs=1:.25:12; amp_freqs=20:5:200;
no_phases=length(phase_freqs); no_amps=length(amp_freqs);

[no_als,al_rows]=size(amp_limits);
[no_pls,pl_rows]=size(phase_limits);

if al_rows~=2 || pl_rows~=2
    display('amp_limits and phase_limits are n by two matrices containing limits on amplitude and phase frequencies, respectively.')
    return
end

no_rectangles=no_als*no_pls;

%% Loading Data.

name=['ALL_',channel_label];
MI=load([name,'/',name,'_',measure_suffix,'_hr_MI.txt']);
MI_4hr=load([name,'/',name,'_',measure_suffix,'_4hr_MI.txt']);

%% Summing MI over amplitude and frequency rectangles, saving.

summed_MI=nan(size(MI,1),no_rectangles);
summed_MI_4hr=nan(size(MI_4hr,1),no_rectangles);

band_labels=cell(no_rectangles,1);

r=1;

for al=1:no_als
    
    for pl=1:no_pls
        
        band_labels{r}=[num2str(amp_limits(al,1)),'to',num2str(amp_limits(al,2)),'by',num2str(phase_limits(pl,1)),'to',num2str(phase_limits(pl,2))];
        
        phase_indices=find(phase_freqs>=phase_limits(pl,1) & phase_freqs<=phase_limits(pl,2));
        amp_indices=find(amp_freqs>=amp_limits(al,1) & amp_freqs<=amp_limits(al,2));
        rectangle_indices=kron(phase_indices-1,no_amps*ones(size(amp_indices)))+kron(ones(size(phase_indices)),amp_indices);
        
        summed_MI(:,r)=sum(MI(:,rectangle_indices),2);
        summed_MI_4hr(:,r)=sum(MI_4hr(:,rectangle_indices),2);
        
        r=r+1;
        
    end
    
end

save([name,'/',name,'_',measure_suffix,'_summed.mat'],'band_labels','summed_MI','summed_MI_4hr')
        