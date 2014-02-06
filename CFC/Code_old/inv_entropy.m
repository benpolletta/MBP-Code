function [MI]=inv_entropy(nobins,M,filename,A_bands,P_bands,units)

% Finding inverse entropy measure for each pair of modes.

[nobins,noamps,nophases]=size(M);

for i=1:nobins
    Total_amp_a(i,:,:)=sum(M);
end

Prob=M./Total_amp_a;
Prob(find(Prob==0))=1;

H=reshape(-sum(Prob.*log(Prob)),noamps,nophases);
MI=(log(nobins)-H)/log(nobins);

figure();
colorplot(MI');
title('Inverse Entropy for Phase-Amplitude Curve')

if nargin>5
    xlabel(['Phase-Modulating (',char(units),')']);
    ylabel(['Amplitude-Modulated (',char(units),')']);
else
    axes ij;
    xlabel('Phase-Modulating');
    ylabel('Amplitude-Modulated');
end

if nargin>3
    for i=1:noamps
        A_labels{i}=num2str(A_bands(i,2));
    end
    for i=1:nophases
        P_labels{i}=num2str(P_bands(i,2));
    end
    set(gca,'XTick',[1.5:(nophases+1.5)],'YTick',[1.5:(noamps+1.5)],'XTickLabel',P_labels,'YTickLabel',A_labels);
end

params=[];

if nargin>2
    saveas(gcf,[filename,'_inv_entropy.fig']);
    fid=fopen([filename,'_inv_entropy.txt'],'w');
    for i=1:sum(nophases)-1
        params=[params,'%f\t'];
    end
    params=[params,'%f\n'];
    fprintf(fid,params,MI');
    fclose(fid);
end