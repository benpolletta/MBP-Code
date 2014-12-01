function M_zs = nanzscore(M)

mean_M = nanmean(M);

mean_M_mat = ones(size(M))*diag(mean_M);

std_M = nanstd(M);

std_M_mat = ones(size(M))*diag(std_M);

M_zs = (M - mean_M_mat)./std_M_mat;