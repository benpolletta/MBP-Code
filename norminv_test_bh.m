

function [sig_cells,pvals,pcrit] = norminv_test_bh(z,zstd,alpha,bad_cells)
    
    if ~exist('bad_cells','var'); bad_cells = []; end

    t_statistic = abs(z) ./ zstd;                    % According to Mikio, the t statistic is equal to mu-hat/sig-hat and this follows the t-distribution for 2N degrees of freedom (N=2*tapers*trials)
    
    areas = normcdf(t_statistic,0,1) - normcdf(-t_statistic,0,1);
    pvals = 1 - areas;

    [sig_cells,pcrit] = bh_step(pvals,alpha,bad_cells);    % My code
    %sig_cells2 = fdr_bh(pvals,alpha);  % Mathworks code - they seem to give the same result

end
