function emd_smoothed_phase_locked_spectrogram(mode_for_phase,P,A,F,no_unwraps,f_bins,p_bins,sampling_freq,units,filename)

[datalength,nomodes]=size(A);

Pmod=mod(P(:,mode_for_phase),2*pi*no_unwraps)/pi;
freq=[min(F(:,mode_for_phase)) mean(F(:,mode_for_phase)) max(F(:,mode_for_phase))];
F=F(:,1:mode_for_phase-1);
A=A(:,1:mode_for_phase-1);

p_centers=1:p_bins;
p_width=no_unwraps/p_bins;
p_centers=(p_centers-1)*2*no_unwraps/p_bins;

f_min=min(min(F)); f_max=max(max(F));
f_width=(f_max-f_min)/f_bins;
f_centers=1:f_bins;
f_centers=f_centers*f_width-f_width/2;

S=zeros(p_bins,f_bins);

for i=1:p_bins  
    clear indices
    indices=find(p_centers(i)-p_width/2<=Pmod & Pmod<p_centers(i)+p_width/2);   
    if length(indices)~=0
        amps=A(indices,:);
        freqs=F(indices,:);
        for j=1:f_bins
            S(i,j)=sum(amps(find(freqs>=f_centers(j)-f_width/2 & freqs<f_centers(j)+f_width/2)));
        end
    else
        S(i,:)=0;
    end
end

figure()
cmap=jet;
whitebg(cmap(1,:))
[r,c]=size(S);
S_ext=zeros(size(S)+1);
S_ext(1:r,1:c)=S;
p_ext=[p_centers p_centers(end)+p_width]; f_ext=[f_centers f_centers(end)+f_width];
h=pcolor(p_ext,f_ext,S_ext');
set(h,'EdgeColor','none','FaceColor','interp')
xlabel(['Phase of Mode ',num2str(mode_for_phase),' (\pi)'])

if nargin>3    
    title(['Spectrogram Locked to Phase of Mode ',num2str(mode_for_phase),', Frequency ',num2str(freq(2)),' (',num2str(freq(1)),' to ',num2str(freq(3)),') ',char(units)])
    ylabel(['Frequency (',char(units),')'])
else
    title(['Spectrogram Locked to Phase of Mode ',num2str(mode_for_phase),', Frequency ',num2str(freq(2)),' (',num2str(freq(1)),' to ',num2str(freq(3)),')'])
    ylabel(['Frequency'])
end

if nargin>4
    saveas(gcf,[filename,'_emd_spectrogram_on_mode',num2str(mode_for_phase),'.fig'])
end
