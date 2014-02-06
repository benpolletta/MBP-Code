function [rhythms_p_vals,amp_rhythms]=phase_cosinor(L,N,noharmonics);

[data_length,nophases]=size(L);
[junk,noamps,junk_jr]=size(N);

figure();
for j=1:nophases
    
    current_phase=L(:,j);

    X=ones(size(current_phase));
    
    for h=1:noharmonics
        X=[X cos(h*current_phase) sin(h*current_phase)];
    end
    [Xr,Xc]=size(X);
    
    current_amps=N(:,:,j);
        
    Normal=[X'*X X'*current_amps];
    Reduced=rref(Normal);
    Mean=Reduced(1,Xc+1:end);
    Coeffs=Reduced(2:end,Xc+1:end);
    rhythms=X*Reduced(:,Xc+1:end);
    residuals=current_amps-rhythms;
    norm_residuals=residuals'*residuals;
    
    amp_rhythms(:,j)=diag((Coeffs'*Coeffs)./norm_residuals);
    
    centered_rhythms=rhythms-ones(size(rhythms))*diag(mean(rhythms));
    fparam=data_length-(2*noharmonics+1);
    rhythms_p_vals(:,j)=fpdf(diag((centered_rhythms'*centered_rhythms)./sqrt(norm_residuals/(data_length-fparam))),2*noharmonics,data_length-fparam);
    
    cutoff=.01/sum(1:noamps-1);
    good_p_vals=zeros(size(rhythms_p_vals));
    good_p_vals(rhythms_p_vals<cutoff)=1;

    for i=1:j-1
        subplot(noamps,nophases,nophases*(i-1)+j);
%         figure();
        plot(current_phase,current_amps(:,i),'.',current_phase,rhythms(:,i),'r');
        hold on;
%         plot(bincenters/pi,M(:,i,j),'k');
    end
end

figure();
colorplot(triu(amp_rhythms,1));
figure();
colorplot(triu(good_p_vals,1));