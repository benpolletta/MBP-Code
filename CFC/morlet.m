function PSI = morlet(FC,FB,FS,T)

T = [-FS*T/2:FS*T/2]/FS;

PSI = ((pi*(FS/FB))^(-0.5))*exp(2*pi*sqrt(-1)*FC*T).*exp(-((FS)*T).^2/(FS/FB));