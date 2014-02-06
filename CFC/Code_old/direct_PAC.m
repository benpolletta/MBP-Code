function PAC=direct_PAC(P,A)

[signal_length,nomodes]=size(P);

num=abs(A'*exp(sqrt(-1)*P);
denom=sqrt((A'*A)/signal_length);

PAC=num./denom;

figure();

subplot(1,2,1)
colorplot(PAC);
title('Direct Phase-Amplitude Coupling Estimator');
ylabel('Mode (Amplitude)');
xlabel('Mode (Phase)');