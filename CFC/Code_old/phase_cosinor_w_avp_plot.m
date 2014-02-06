function [amp_rhythms]=phase_cosinor(bincenters,M,N,L);

[data_length,nophases]=size(L);
[junk,noamps,junk_jr]=size(N);

figure();
for j=1:nophases
    
    current_phase=L(:,j);

    O=ones(size(current_phase));
    C1=cos(current_phase);
    S1=sin(current_phase);
    C2=cos(2*current_phase);
    S2=sin(2*current_phase);

    X=[O C1 S1 C2 S2];
    
    current_amps=N(:,:,j);
        
    Normal=[X'*X X'*current_amps];
    Reduced=rref(Normal);
    Mean=Reduced(1,6:end);
    Coeffs=Reduced(2:end,6:end);
    rhythms=X*Reduced(:,6:end);

    amp_rhythms(:,j)=diag((Coeffs'*Coeffs)./(current_amps'*current_amps));

    for i=1:j-1
        subplot(noamps,nophases,nophases*(i-1)+j);
%         figure();
        plot(current_phase,current_amps(:,i),'.',current_phase,rhythms(:,i),'r');
        hold on;
        plot(bincenters/pi,M(:,i,j),'k');
    end
end

figure();
colorplot(triu(amp_rhythms,1));