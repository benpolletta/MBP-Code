function [N,M,dphase,mag,dir]=n_m_phaselocking(P,Pmod,filename)

[signal_length,nomodes]=size(P);

for i=1:nomodes
    peaks=[]; extrema=[];
    peaks=[find(Pmod(:,i)>1.99); signal_length];
    extrema=peaks(find(diff(peaks)>1));
    if length(extrema)>1
        cycle_length(i)=round(mean(diff(extrema)));
    else
        cycle_length(i)=signal_length;
    end
end

for j=1:nomodes % Index for low frequency mode.
    for k=1:nomodes % Index for high frequency mode.
        [n,m]=rat(cycle_length(j)/cycle_length(k));
        dphase(j,k)=mean(m*P(:,j)-n*P(:,k));
        coherence=exp(sqrt(-1)*P(:,j)')*exp(sqrt(-1)*P(:,k))/signal_length;
        mag(j,k)=abs(coherence);
        dir(j,k)=angle(coherence);
        N(j,k)=n;
        M(j,k)=m;
    end
end

figure();


subplot(1,3,1)
colorplot(dphase);
axis ij;
title('\Delta Phase for n:m Phase Locking');
ylabel('Mode Number');
xlabel('Mode Number');

subplot(1,3,2)
colorplot(mag);
axis ij;
title('n:m Phase Coherence (Magnitude)');
ylabel('Mode Number');
xlabel('Mode Number');

subplot(1,3,3)
colorplot(dir);
axis ij;
title('n:m Phase Coherence (Angle)');
ylabel('Mode Number');
xlabel('Mode Number');

if nargin>2
    saveas(gcf,[filename,'_n_m_coherence.fig']);
end