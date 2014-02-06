function [MI]=inv_entropy_no_save(M)

% Finding inverse entropy measure for each pair of modes. M is a 3D array of
% amplitude by phase distributions, where the first dimension indexes phase
% bins, the second dimension indexes amplitude frequencies, and the third
% dimension indexes phase frequencies. MI is a 2D array of dependencies of
% amplitude on phase, where the first dimension indexes amplitude
% frequencies, and the second dimension indexes phase frequencies.

[nobins,noamps,nophases]=size(M);
Total_amp_avg=zeros(nobins,noamps,nophases);

% Creating array of amplitude sums (constant across first dimension).
if nophases~=1
    for i=1:nobins
        Total_amp_avg(i,:,:)=sum(M);
    end
else
    for i=1:nobins
        Total_amp_avg(i,:)=sum(M);
    end
end

% Normalizing amplitude vs. phase distributions.
Prob=M./Total_amp_avg;
Prob(Prob==0)=1;

% Calculating entropy.
H=reshape(-sum(Prob.*log(Prob)),noamps,nophases);
% Normalizing to get inverse entropy.
MI=(log(nobins)-H)/log(nobins);