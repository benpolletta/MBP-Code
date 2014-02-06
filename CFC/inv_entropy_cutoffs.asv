function MI_stats=inv_entropy_cutoffs(MIvals,threshold)

MI_stats.pthresh_vals=quantile(MIvals,threshold);

MI_stats.zmeans=mean(MIvals);
MI_stats.zstds=std(MIvals);
MI_stats.zthresh_vals=MI_stats.zmeans+norminv(threshold,0,1)*MI_stats.zstds;

MI_stats.logmeans=mean(log(MIvals));
MI_stats.logstds=std(log(MIvals));
MI_stats.lzthresh_vals=exp(MI_stats.logmeans+norminv(threshold,0,1)*MI_stats.logstds);