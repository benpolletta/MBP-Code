function [hr_params,fourhr_params,spec_params,spec_zs_params,spec_pct_params] = Freqs_Bernat(channel_name,measure,bands)

load('f_bins.mat')

[r,c] = size(bands);

if ~(r==2 || c==2)
    
    display('Input variable "bands" must be n by 2.')
    
    return
    
elseif r==2
    
    bands = bands';
    
end

no_bands = size(bands,1);

name=sprintf('ALL_%s',channel_name);

ALL_hr_MI = load([name,'/',name,'_',measure,'_hr_MI.txt']);
ALL_4hr_MI = load([name,'/',name,'_',measure,'_4hr_MI.txt']);

hr_params = calc_PAC_params(ALL_hr_MI);

fourhr_params = calc_PAC_params(ALL_4hr_MI);

ALL_spec = load([name,'/',name,'_spec.txt']);
ALL_spec_zs = load([name,'/',name,'_spec_zs.txt']);
ALL_spec_pct = load([name,'/',name,'_spec_pct.txt']);

spec_params = nan(size(ALL_spec,1),no_bands*2);
spec_zs_params = nan(size(ALL_spec,1),no_bands*2);
spec_pct_params = nan(size(ALL_spec,1),no_bands*2);

for b = 1:size(bands,2)

    band_indices = bands(b,1) <= f_bins & f_bins <= bands(b,2);
    
    spec_params(:,2*b-1:2*b) = calc_spec_params(ALL_spec(:,band_indices),f_bins(band_indices));
    
    spec_zs_params(:,2*b-1:2*b) = calc_spec_params(ALL_spec_zs(:,band_indices),f_bins(band_indices));
    
    spec_pct_params(:,2*b-1:2*b) = calc_spec_params(ALL_spec_pct(:,band_indices),f_bins(band_indices));
    
end

save([name,'/',name,'_',measure,'_freqs.mat'],'hr_params','fourhr_params','spec_params','spec_zs_params','spec_pct_params','bands')

end

function PAC_params = calc_PAC_params(PAC_mat)

load('AP_freqs.mat')
no_phases = length(phase_freqs);
no_amps = length(amp_freqs);

[max_MI, max_MI_indices] = max(PAC_mat,[],2);

phase_indices = ceil(max_MI_indices/no_amps);
pref_fp = phase_freqs(phase_indices);

amp_indices = mod(max_MI_indices,no_amps);
amp_indices(amp_indices==0) = no_amps;
pref_fa = amp_freqs(amp_indices);

PAC_params = [max_MI pref_fp' pref_fa'];

end

function spec_params = calc_spec_params(spec_mat,f)

[max_pow, max_pow_indices] = max(spec_mat,[],2);

peak_freqs = f(max_pow_indices);

spec_params = [max_pow peak_freqs'];

end