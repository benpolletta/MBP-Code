function [Pref_phase,MI]=PLV_PAC(sampling_freq,P,A,bands_lo,filename,dirname)

[signal_length,nophases]=size(P);
[~,noamps]=size(A);
P_A_hi=zeros(signal_length,nophases,noamps);

for i=1:noamps

    [~,~,~,P_A]=filter_wavelet_Jan(A(:,i),'fs',sampling_freq,'bands',bands_lo);
    
    P_A_hi(:,:,i)=P_A;
    
    PLV=mean(exp(sqrt(-1)*(P_A-P)));
    Pref_phase(i,:)=angle(PLV);
    MI(i,:)=abs(PLV);

end

if nargin>4
    
%     save([dirname,'/',filename,'_Pa.mat'],'P_A_hi')
    save([dirname,'/',filename,'_PLV.mat'],'Pref_phase','MI')

end