function simulateCFC_missing_reps(simlength,sampling_freq,f_lo,f_hi,strength,noise_level,percent,noreps)
% Produces noreps realizations of a signal with simlength data points,
% containing a low-frequency signal at freq. f_lo, and a high-frequency
% signal at frequency f_hi, w/ sampling freq. sampling_freq.

t=1:simlength;
t=t/sampling_freq;

% Low-freq. signal.
low_mode=sin(2*pi*f_lo*t);

% Amp. envelope of high-freq. signal.
amp_hi=.5*(strength*low_mode+2-strength);

% High-freq. signal.
hi_mode=amp_hi.*sin(2*pi*f_hi*t);

s=low_mode+hi_mode;

fid=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'.txt'],'w');
fprintf(fid,'%f\n',s);

fclose(fid);

for i=1:noreps
    noise=randn(1,simlength)*noise_level;
    s_noise=low_mode+hi_mode+noise;
    
    segs_length=floor(simlength/20);
    no_segs=floor(simlength/segs_length);
    no_missing=floor(percent*no_segs);
    [junk,indices]=sort(rand(1,no_segs));
    missing_indices=indices(end-no_missing:end);
    for j=1:no_missing
        s_noise((missing_indices(j)-1)*segs_length+1:missing_indices(j)*segs_length)=0;
    end
    
    fid1=fopen(['simCFC_a_',num2str(f_hi),'_p_',num2str(f_lo),'_strength_',num2str(strength),'_noise_',num2str(noise_level),'_p_missing_',num2str(percent),'_rep',num2str(i),'.txt'],'w');
    fprintf(fid1,'%f\n',s_noise);
    fclose(fid1);
end