function [mag,dir]=phase_amp_coherence(P,A,filename)

[signal_length,nomodes]=size(A);

A_signal=hilbert(A);

for i=1:nomodes
    A_phase(:,i)=phase(A_signal(:,i));
end

coherence=exp(sqrt(-1)*A_phase')*exp(sqrt(-1)*(-P))/signal_length;
mag=abs(coherence);
dir=angle(coherence);

figure();

subplot(1,2,1)
colorplot(mag);
axis ij;
title('Signal-Amplitude Phase Coherence (Magnitude)');
ylabel('Mode (Amplitude)');
xlabel('Mode (Phase)');

subplot(1,2,2)
colorplot(dir);
axis ij;
title('Signal-Amplitude Phase Coherence (Angle)');
ylabel('Mode (Amplitude)');
xlabel('Mode (Phase)');

if nargin>2
    saveas(gcf,[filename,'_coherence.fig']);
end