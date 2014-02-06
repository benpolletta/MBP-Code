function [bands]=makebands(nobands,low_lim,hi_lim,spacing)

if isfloat(spacing)
    
    factors=spacing.^[-nobands:-1];
    bandwidths=(hi_lim-low_lim)*factors;
    band_maxs=low_lim+cumsum(bandwidths);
    band_centers=band_maxs-bandwidths/2;
    band_mins=band_maxs-bandwidths;
    bands=[band_mins' band_centers' band_maxs'];

elseif strcmp(char(spacing),'linear')==1

    band_spacing=(hi_lim-low_lim)/nobands;
%     bandwidth=2*band_spacing/5;
    bandwidth=band_spacing/2;
    band_centers=low_lim+band_spacing/2:band_spacing:hi_lim-band_spacing/2;
    band_mins=band_centers-bandwidth;
    band_maxs=band_centers+bandwidth;
    bands=[band_mins' band_centers' band_maxs'];

elseif strcmp(char(spacing),'log')==1

    band_spacing=(log(hi_lim)-log(low_lim))/nobands;
%     bandwidth=2*band_spacing/5;
    bandwidth=band_spacing/2;
    log_band_centers=log(low_lim)+band_spacing/2:band_spacing:log(hi_lim)-band_spacing/2;
    log_band_mins=log_band_centers-bandwidth;
    log_band_maxs=log_band_centers+bandwidth;
    bands=[exp(log_band_mins)' exp(log_band_centers)' exp(log_band_maxs)'];

elseif strcmp(char(spacing),'sqrt')==1

    band_spacing=(sqrt(hi_lim)-sqrt(low_lim))/nobands;
%     bandwidth=2*band_spacing/5;
    bandwidth=band_spacing/2;
    sqrt_band_centers=sqrt(low_lim)+band_spacing/2:band_spacing:sqrt(hi_lim)-band_spacing/2;
    sqrt_band_mins=sqrt_band_centers-bandwidth;
    sqrt_band_maxs=sqrt_band_centers+bandwidth;
    bands=[(sqrt_band_mins.^2)' (sqrt_band_centers.^2)' (sqrt_band_maxs.^2)'];

elseif strcmp(char(spacing),'dyadic')==1
    
    factors=2.^[-nobands:-1];
    bandwidths=(hi_lim-low_lim)*factors;
    band_maxs=low_lim+cumsum(bandwidths);
    band_centers=band_maxs-bandwidths/2;
    band_mins=band_maxs-bandwidths;
    bands=[band_mins' band_centers' band_maxs'];
    
else

    display('Choose band spacing: "linear", "log", "sqrt", or "dyadic".');

end