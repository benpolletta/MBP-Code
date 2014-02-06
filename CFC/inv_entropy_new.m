function [MI]=inv_entropy_new(M,filename,A_bands,P_bands,dirname)

% Finding inverse entropy measure for each pair of modes.

[nobins,noamps,nophases]=size(M);

for i=1:nobins
    Total_amp_a(i,:,:)=sum(M);
end

Prob=M./Total_amp_a;
Prob(find(Prob==0))=1;

H=reshape(-sum(Prob.*log(Prob)),noamps,nophases);
MI=(log(nobins)-H)/log(nobins);

params=[];

% Saving inverse entropy.

if nargin>2

    Abandslabel=['a_',num2str(length(A_bands)),'_from_',num2str(A_bands(1,1)),'_to_',num2str(A_bands(end,end))];
    Pbandslabel=['p_',num2str(length(P_bands)),'_from_',num2str(P_bands(1,1)),'_to_',num2str(P_bands(end,end))];
    bandslabel=[Abandslabel,'_v_',Pbandslabel];

    if nargin>4
        %fid=fopen([dirname,'\',filename,'_',bandslabel,'_inv_entropy.txt'],'w');
        fid=fopen([dirname,'\',filename,'_inv_entropy.txt'],'w');
    else
        %fid=fopen([filename,'_',bandslabel,'_inv_entropy.txt'],'w');
        fid=fopen([filename,'_inv_entropy.txt'],'w');
    end

    for i=1:nophases
        params=[params,'%f\t'];
    end
    params=[params,'%f\n'];
    fprintf(fid,params,[NaN P_bands(:,2)' ; A_bands(:,2) MI]');
    fclose(fid);

end