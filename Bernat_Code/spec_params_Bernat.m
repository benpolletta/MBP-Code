function [spec_params,spec_zs_params,spec_pct_params] = spec_params_Bernat(channel_name,bands)

load('f_bins.mat')

[r,c] = size(bands);

if ~(r==2 || c==2)
    
    display('Input variable "bands" must be n by 2.')
    
    return
    
elseif r==2 && c~=2
    
    bands = bands';
    
end

no_bands = size(bands,1);

name=sprintf('ALL_%s',channel_name);

ALL_spec = load([name,'/',name,'_spec.txt']);
ALL_spec_zs = load([name,'/',name,'_spec_zs.txt']);
ALL_spec_pct = load([name,'/',name,'_spec_pct.txt']);

spec_params = nan(size(ALL_spec,1),no_bands*2);
spec_zs_params = nan(size(ALL_spec,1),no_bands*2);
spec_pct_params = nan(size(ALL_spec,1),no_bands*2);

bands_name = '';

for b = 1:size(bands,1)

    band_indices = bands(b,1) <= f_bins & f_bins <= bands(b,2);
    
    bands_name = [bands_name,sprintf('%g-%g_',bands(b,1),bands(b,2))];
    
    spec_params(:,2*b-1:2*b) = calc_spec_params(ALL_spec(:,band_indices),f_bins(band_indices));
    
    spec_zs_params(:,2*b-1:2*b) = calc_spec_params(ALL_spec_zs(:,band_indices),f_bins(band_indices));
    
    spec_pct_params(:,2*b-1:2*b) = calc_spec_params(ALL_spec_pct(:,band_indices),f_bins(band_indices));
    
end

save([name,'/',name,'_',bands_name,'spec_params.mat'],'spec_params','spec_zs_params','spec_pct_params','bands')

end

function spec_params = calc_spec_params(spec_mat,f)

[max_pow, max_pow_indices] = max(spec_mat,[],2);

peak_freqs = f(max_pow_indices);

spec_params = [max_pow peak_freqs'];

end