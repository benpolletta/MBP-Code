function MI_stats=compute_stats(MIvals,threshold)

[rows,cols,reps]=size(MIvals);

MI_stats=zeros(rows,cols,8);

rmpath('/home/bp/Code/eeglab11_0_4_3b/functions/sigprocfunc/')

MI_stats(:,:,1)=quantile(MIvals,threshold,3);

addpath('/home/bp/Code/eeglab11_0_4_3b/functions/sigprocfunc/')

z_means=mean(MIvals,3);
z_stds=std(MIvals,0,3);
MI_stats(:,:,2)=z_means;
MI_stats(:,:,3)=z_stds;
MI_stats(:,:,4)=norminv(threshold,z_means,z_stds);

lz_means=mean(log(MIvals),3);
lz_stds=std(log(MIvals),0,3);
MI_stats(:,:,5)=lz_means;
MI_stats(:,:,6)=lz_stds;
MI_stats(:,:,7)=exp(norminv(threshold,lz_means,lz_stds));

% Computing skewness.

try
    
    Mn=repmat(z_means,[1 1 reps]);
    
    multiplier=sqrt(reps-1)/(sqrt(reps)*(reps-2));
    MI_stats(:,:,8)=multiplier*sum((MIvals-Mn).^3,3)./(std(MIvals,1,3).^(1.5));

end
