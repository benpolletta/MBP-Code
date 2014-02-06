function [M,MI]=amp_v_phase(hhtdata,nobins)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves.

[signal_length,nomodes]=size(hhtdata);

for i=1:nomodes
    H(:,i)=hilbert(hhtdata(i,:)); 
    A(:,i)=abs(H(:,i)); 
    P(:,i)=phase(H(:,i)); 
end

bincenters=[1:nobins];
bincenters=(bincenters-1)*2*pi/nobins-pi*(nobins-1)/nobins;

Pmod=mod(phases,2*pi)-pi;

% Finding amplitude vs. phase curves for each pair of modes.

for j=1:nomodes     % Counter for modes providing phase.
    for i=1:nobins  % Counter for phase bins.
        indices=[];
        indices=find(bincenters(i)-pi/nobins<=Pmod(:,j) & Pmod(:,j)<bincenters(i)+pi/nobins);   % Bin phases.
        for k=1:nomodes     % Counter for modes providing amplitude. 
            if length(indices~=0)
                M(i,j,k)=sum(A(indices,l))/length(indices); % Average amplitude of mode l at phase i of mode j.
            else
                M(i,j,k)=0;
            end
        end
    end
end

%Plotting amplitude vs. phase curves for each pair of modes.

figure();

for j=1:nomodes
    for k=1:nomodes
        subplot(nomodes,nomodes,nomodes*(k-1)+j);
        Mean=sum(M(:,j,k))/nobins;
        plot(bins/pi,Mean,'-',bins/pi,M(:,j,k));
        xlabel(['Phase of mode ',num2str(j),' (\pi)']);
        ylabel(['Amplitude of mode ',num2str(k)]);
    end
end

% Finding inverse entropy measure for each pair of modes.

for i=1:nobins
    Total_amp_a(i,:,:)=sum(M);
end

Prob=M./Total_amp_a;
Prob(find(Prob==0))=1;

H=reshape(-sum(Prob.*log(Prob)),nomodes,nomodes);
MI=(log(nobins)-H)/log(nobins);
MI=MI';

figure();

% Plotting MI.

MI_ext=ones(nomodes+1,nomodes+1);
MI_ext(1:nomodes,1:nomodes)=MI;
pcolor(MI_ext)
colorbar