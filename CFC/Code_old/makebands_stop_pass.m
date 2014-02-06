function [bands]=makebands_stop_pass(nobands,low_lim,hi_lim,pass_pct,spacing)
    
if strcmp(spacing,'linear')==1

    band_spacing=(hi_lim-low_lim)/nobands;
    bandwidth=pass_pct*band_spacing/2;
%     bandwidth=band_spacing/2;
    band_centers=low_lim+band_spacing/2:band_spacing:hi_lim-band_spacing/2;
    stop_low=band_centers-band_spacing+bandwidth;
    pass_low=band_centers-bandwidth;
    pass_high=band_centers+bandwidth;
    stop_high=band_centers+band_spacing-bandwidth;
    bands=[stop_low' pass_low' band_centers' pass_high' stop_high'];

elseif strcmp(spacing,'log')==1

    if low_lim==0
        low_lim=eps;
    end
    band_spacing=(log(hi_lim)-log(low_lim))/nobands;
    bandwidth=pass_pct*band_spacing/2;
    %     bandwidth=band_spacing/2;
    log_band_centers=log(low_lim)+band_spacing/2:band_spacing:log(hi_lim)-band_spacing/2;
    log_stop_low=log_band_centers-band_spacing+bandwidth;
    log_pass_low=log_band_centers-bandwidth;
    log_pass_high=log_band_centers+bandwidth;
    log_stop_high=log_band_centers+band_spacing-bandwidth;
    bands=[exp(log_stop_low)' exp(log_pass_low)' exp(log_band_centers)' exp(log_pass_high)' exp(log_stop_high)'];

elseif strcmp(spacing,'sqrt')==1

    band_spacing=(sqrt(hi_lim)-sqrt(low_lim))/nobands;
    bandwidth=(1-overlap)*band_spacing/2;
%     bandwidth=band_spacing/2;
    sqrt_band_centers=sqrt(low_lim)+band_spacing/2:band_spacing:sqrt(hi_lim)-band_spacing/2;
    sqrt_stop_low=sqrt_band_centers-band_spacing+bandwidth;
    sqrt_pass_low=sqrt_band_centers-bandwidth;
    sqrt_pass_high=sqrt_band_centers+bandwidth;
    sqrt_stop_high=sqrt_band_centers+band_spacing-bandwidth;
    bands=[(sqrt_stop_low.^2)' (sqrt_pass_low.^2)' (sqrt_band_centers.^2)' (sqrt_pass_high.^2)' (sqrt_stop_hi.^2)'];

else

    display('Choose band spacing: "linear", "log", or "sqrt".');

end