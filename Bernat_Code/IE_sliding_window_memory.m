function IE_sliding_window_memory(data, sampling_freq, no_amps, band_range, P_theta, P_bands, listname, filename, amp_title, MI_stats)

window_size=1501;
step_size=round(sampling_freq/max(band_range));

MI_measure_labels={'IE','IE_zt','IE_pt','IE_zs'};
for i=1:length(MI_measure_labels)
    MI_fid_vec(i)=fopen([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_', MI_measure_labels{i}, '.txt'], 'w');
end
AVP_fid=fopen([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_AVP.txt'], 'w');
params_fid=fopen([listname(1:end-5), '_MI/', filename(1:end-4),'_theta_', amp_title, '_params.txt'], 'w');

% [A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', 1000, 'nobands', no_amps, 'bandrange', band_range, 'time_resol', 200*ones(no_amps,1));
[A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', 1000, 'nobands', no_amps, 'bandrange', band_range);

A_bands=A_bands(:,2);

no_amp_bands=length(A_bands);
nophases=length(P_bands);
nobins=20;

MI_format=make_format(no_amps*nophases, 'f');
AVP_format=make_format(no_amps*nobins, 'f');
params_format=make_format(5,'f');

no_windows=100;%floor((length(data)-window_size)/step_size);     

for k=1:no_windows

    MI_measures=zeros(no_amps,nophases,4);
    
    P_temp=P_theta([1:window_size]+k*step_size,:);
    A_temp=A([1:window_size]+k*step_size,:);
    
    [bincenters,M]=amp_v_phase_Jan(20,A_temp,P_temp);
    MI=inv_entropy_no_save(M);
    
    MI_measures(:,:,1)=MI;
    MI_measures(:,:,2)=max(0,MI-MI_stats(:,:,1));
    MI_measures(:,:,3)=max(0,MI-MI_stats(:,:,4));
    MI_measures(:,:,4)=(MI-MI_stats(:,:,2))./MI_stats(:,:,3);
    
    [max_MI,pref_fp_index]=max(max(MI_measures(:,:,4)));
    pref_fp=P_bands(pref_fp_index);
    
    [~,pref_fa_index]=max(MI_measures(:,pref_fp_index,4));
    pref_fa=A_bands(pref_fa_index);
    
    M_pref=M(:,:,pref_fp_index);
    [max_amp,pref_phase_index]=max(M(:,pref_fa_index)/mean(M(:,pref_fa_index))-1);
    pref_phase=bincenters(pref_phase_index)/pi;
    
    for m=1:length(MI_measure_labels)
        MI=reshape(MI_measures(:,:,m),1,no_amp_bands*nophases);
        fprintf(MI_fid_vec(m),MI_format,MI);
    end
    
    M_pref=reshape(M_pref,1,nobins*no_amp_bands);
    fprintf(AVP_fid,AVP_format,M_pref);
    
    fprintf(params_fid,params_format,[pref_fp pref_phase pref_fa max_MI max_amp]);

end

fclose('all');
