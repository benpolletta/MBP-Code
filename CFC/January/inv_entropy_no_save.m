function [MI]=inv_entropy_no_save(M)

% Finding inverse entropy measure for each pair of modes.

[nobins,noamps,nophases]=size(M);

for i=1:nobins
    Total_amp_avg(i,:,:)=sum(M);
end

Prob=M./Total_amp_avg;
Prob(find(Prob==0))=1;

H=reshape(-sum(Prob.*log(Prob)),noamps,nophases);
MI=(log(nobins)-H)/log(nobins);