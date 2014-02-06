function IE_sliding_window(data, sampling_freq, no_amps, amp_band_range, P_theta, P_bands, listname, filename, amp_title, MI_stats)

window_size=1501;
step_size=round(sampling_freq/max(amp_band_range));

% [A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', 1000, 'nobands', no_amps, 'bandrange', band_range, 'time_resol', 200*ones(no_amps,1));
[A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', sampling_freq, 'nobands', no_amps, 'bandrange', amp_band_range);

A_bands=A_bands(:,2);

nophases=length(P_bands);
nobins=20;

% no_windows=floor((length(data)-window_size)/step_size);     
no_windows=100;

MI_all=zeros(no_amps,nophases,4,no_windows);
AVP_pref_all=zeros(nobins,no_amps,no_windows);
params_all=zeros(no_windows,5);

for k=1:no_windows

    P_temp=P_theta([1:window_size]+k*step_size,:);
    A_temp=A([1:window_size]+k*step_size,:);
    
    [bincenters,M]=amp_v_phase_Jan(20,A_temp,P_temp);
    MI=inv_entropy_no_save(M);
    
    MI_all(:,:,1,k)=MI;
    MI_all(:,:,2,k)=max(0,MI-MI_stats(:,:,1));
    MI_all(:,:,3,k)=max(0,MI-MI_stats(:,:,4));
    MI_all(:,:,4,k)=(MI-MI_stats(:,:,2))./MI_stats(:,:,3);
    
    [max_MI,pref_fp_index]=max(max(MI_all(:,:,4,k)));
    pref_fp=P_bands(pref_fp_index);
    
    [~,pref_fa_index]=max(MI_all(:,pref_fp_index,4,k));
    pref_fa=A_bands(pref_fa_index);
    
    M_pref=M(:,:,pref_fp_index);
    [max_amp,pref_phase_index]=max(M_pref(:,pref_fa_index)/mean(M_pref(:,pref_fa_index))-1);
    pref_phase=bincenters(pref_phase_index)/pi;
    
    AVP_pref_all(:,:,k)=M_pref;
    
    params_all(k,:)=[pref_fp pref_phase pref_fa max_MI max_amp];

end

save([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_MI.mat'],'MI_all','AVP_pref_all','params_all')

t=step_size*(1:no_windows)/sampling_freq;

param_labels={'Phase Freq.';'Pref. Phase';'Amp. Freq.';'Max. MI';'Max. Amp.'};

figure()
for i=1:5
    subplot(5,1,i)
    plot(t,params_all(:,i))
    title([param_labels{i},' for ',filename])
    ylabel(param_labels{i})
end
xlabel('Time (s)')

saveas(gcf,[listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_params.fig'])