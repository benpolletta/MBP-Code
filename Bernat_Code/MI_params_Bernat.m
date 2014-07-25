function [hr_params_max, fourhr_params_max, hr_params_mean, fourhr_params_mean] = MI_params_Bernat(channel_name,measure)%,bands)

% [r,c] = size(bands);
% 
% if ~(r==2 || c==2)
%     
%     display('Input variable "bands" must be n by 2.')
%     
%     return
%     
% elseif r==2
%     
%     bands = bands';
%     
% end
% 
% no_bands = size(bands,1);

name=sprintf('ALL_%s',channel_name);

ALL_hr_MI = load([name,'/',name,'_',measure,'_hr_MI.txt']);
ALL_4hr_MI = load([name,'/',name,'_',measure,'_4hr_MI.txt']);

hr_params_max = calc_PAC_params_max(ALL_hr_MI);

fourhr_params_max = calc_PAC_params_max(ALL_4hr_MI);

hr_params_mean = calc_PAC_params_mean(ALL_hr_MI);

fourhr_params_mean = calc_PAC_params_mean(ALL_4hr_MI);

save([name,'/',name,'_',measure,'_MI_params.mat'],'hr_params_max','fourhr_params_max','hr_params_mean','fourhr_params_mean')

end

function PAC_params = calc_PAC_params_max(PAC_mat)

tic;

load('AP_freqs.mat')
no_amps = length(amp_freqs);

[max_MI, max_MI_indices] = max(PAC_mat,[],2);

phase_indices = ceil(max_MI_indices/no_amps);
pref_fp = phase_freqs(phase_indices);

amp_indices = mod(max_MI_indices,no_amps);
amp_indices(amp_indices==0) = no_amps;
pref_fa = amp_freqs(amp_indices);

PAC_params = [max_MI pref_fp' pref_fa'];

toc;

end

function PAC_params = calc_PAC_params_mean(PAC_mat)

tic;

load('AP_freqs.mat')
no_phases = length(phase_freqs);
no_amps = length(amp_freqs);

PAC_nonneg = max(PAC_mat, 0);

p_rows = 1:(no_amps*no_phases);
p_columns = reshape(cumsum(ones(no_amps, no_phases), 2), no_amps*no_phases, 1);
p_entries = ones(no_amps*no_phases, 1);
p_mat = sparse(p_rows, p_columns, p_entries, max(p_rows), max(p_columns))/no_amps;

a_mat = repmat(diag(ones(no_amps, 1)), no_phases, 1)/no_phases;

phase_marginal = normr(PAC_nonneg*p_mat);

amp_marginal = normr(PAC_nonneg*a_mat);

pref_fp = phase_marginal*phase_freqs';

pref_fa = amp_marginal*amp_freqs';

PAC_params = [pref_fp pref_fa];

toc;

end

function M_norm = normr(M)

no_rows = size(M, 1);

M_sum = sum(M, 2);

M_norm_factor = sparse(1:no_rows, 1:no_rows, 1./M_sum, no_rows, no_rows);

M_norm = (M'*M_norm_factor)';

end