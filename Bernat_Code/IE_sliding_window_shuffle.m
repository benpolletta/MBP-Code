function [MI_stats]=IE_sliding_window_shuffle(noshufs, threshold, data, sampling_freq, no_amps, band_range, P_theta, P_bands, listname, filename, amp_title)

window_size=1501;
step_size=round(sampling_freq/max(band_range));
steps_per_window=floor(window_size/step_size);
% steps_per_half_window=ceil(steps_per_window/2);
no_windows=floor((length(data)-window_size)/step_size);

amp_indices=randi(no_windows,[1,noshufs]);
phase_indices=randi(no_windows-2*steps_per_window,[1,noshufs]);
phase_indices(phase_indices>=amp_indices-steps_per_window)=phase_indices(phase_indices>=amp_indices-steps_per_window)+2*steps_per_window;
        
shufsname=[filename(1:end-4),'_theta_', amp_title, '_',num2str(noshufs),'shufs'];
% MI_fid=fopen([listname(1:end-5), '_MI/', shufsname,'_MI.txt'], 'w');
% params_fid=fopen([listname(1:end-5), '_MI/', shufsname,'_params.txt'], 'w');

% [A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', 1000, 'nobands', no_amps, 'bandrange', band_range, 'time_resol', 200*ones(no_amps,1));
[A_bands, ~, A, ~]=filter_wavelet_Jan(data, 'fs', 1000, 'nobands', no_amps, 'bandrange', band_range);

A_bands=A_bands(:,2);

no_amp_bands=length(A_bands);
nophases=length(P_bands);
nobins=20;

MI_format=make_format(no_amps*nophases, 'f');
params_format=make_format(5,'f');

M_avg=zeros(nobins,no_amps,nophases);
MI_all=zeros(no_amps,nophases,noshufs);
params_all=zeros(noshufs,5);

for k=1:noshufs

    P_temp=P_theta([1:window_size]+phase_indices(k)*step_size,:);
    A_temp=A([1:window_size]+amp_indices(k)*step_size,:);
    
    [bincenters,M]=amp_v_phase_Jan(20,A_temp,P_temp);
    MI=inv_entropy_no_save(M);
    
    [max_MI,pref_fp_index]=max(max(MI));
    pref_fp=P_bands(pref_fp_index);
    
    [~,pref_fa_index]=max(MI(:,pref_fp_index));
    pref_fa=A_bands(pref_fa_index);
    
    M_pref=M(:,:,pref_fp_index);
    [max_amp,pref_phase_index]=max(M(:,pref_fa_index)/mean(M(:,pref_fa_index))-1);
    pref_phase=bincenters(pref_phase_index);
    
%     MI=reshape(MI,1,no_amp_bands*nophases);
    MI_all(:,:,k)=MI;
    params_all(k,:)=[pref_fp pref_phase pref_fa max_MI max_amp];

    M_avg=M_avg+M;
    
end

M_avg=M_avg/noshufs;

% fprintf(MI_fid,MI_format,MI_all');
% fprintf(params_fid,params_format,params_all');
% 
% fclose(MI_fid); fclose(params_fid);

MI_stats=compute_stats(MI_all,threshold);

save([listname(1:end-5), '_MI/', shufsname, '_stats.mat'],'noshufs','threshold','P_bands','A_bands','M_avg','params_all','MI_all','MI_stats');

