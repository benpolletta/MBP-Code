function [bincenters,M,L]=amp_v_phase_save(nobins,A,P,outfilename,A_bands,P_bands,dirname)

% function [bincenters,M,N,L]=amp_v_phase_new(nobins,A,P,outfilename,A_bands,P_bands,dirname)

% Finding amplitude vs. phase curves for each pair of modes. nobins is the 
% number of bins, A is a matrix whose columns are the amplitudes of the modes, 
% P is a matrix whose columns are the phases of the modes, figchoice is 
% either 1 (to make a figure) or 0 (to omit the figure). A_bands is a matrix of
% mins, centers and maxes for the frequency bands of the amplitude-modulated 
% components. P_bands gives the same for the phase-modulating components.

[~,nomodes_hi]=size(A);
[nopoints,nomodes_lo]=size(P);

bincenters=1:nobins;
bincenters=(bincenters-1)*2*pi/nobins-pi*(nobins-1)/nobins;

Pmod=mod(P,2*pi)-pi;

M=zeros(nobins,nomodes_hi,nomodes_lo);
L=zeros(nopoints,nomodes_lo);

for j=1:nomodes_lo     % Counter for modes providing phase.
%     amp_index=0;    % Index for recording all amplitudes in each phase bin.
    for i=1:nobins  % Counter for phase bins.
        clear indices
        indices=find(bincenters(i)-pi/nobins<=Pmod(:,j) & Pmod(:,j)<bincenters(i)+pi/nobins);   % Bin phases.
%         L(amp_index+1:amp_index+length(indices),j)=bincenters(i)/pi; % Vector recording the number of time points falling around phase i of mode j.
        L(indices,j)=bincenters(i)/pi;
        for k=1:nomodes_hi     % Counter for modes providing amplitude. 
            if ~isempty(indices)
                M(i,k,j)=sum(A(indices,k))/length(indices); % Average amplitude of mode k around phase i of mode j.
%                 N(amp_index+1:amp_index+length(indices),k,j)=A(indices,k);  % Amplitudes of mode k around phase i of mode j.
            else
                M(i,k,j)=0;
            end
        end
%         amp_index=amp_index+length(indices);    % Index at which vector of amplitudes ends.
    end
end

% Saving amplitude vs. phase curves, binned data.

A_band_range_label=['a_',num2str(nomodes_hi),'_from_',num2str(min(A_bands(:,1))),'_to_',num2str(max(A_bands(:,3)))];
P_band_range_label=['p_',num2str(nomodes_hi),'_from_',num2str(min(P_bands(:,1))),'_to_',num2str(max(P_bands(:,3)))];
band_range_label=[A_band_range_label,'_',P_band_range_label];

if nargin>6 && ~isempty(dirname)
    dirname=[dirname,'/',outfilename,'_',band_range_label];    
else
    dirname=[outfilename,'_',band_range_label];
end
mkdir (dirname);

token=[];
for i=1:nomodes_hi
    token=[token,'%f\t'];
end
token=[token,'%f\n'];

present_dir=pwd;
cd (dirname);

fid=fopen('avp.list','w');
fid1=fopen('bin_info.txt','w');
% fid=fopen([dirname,'/',outfilename,'_',band_range_label,'_avp.list'],'w');
% fid1=fopen([dirname,'/',outfilename,'_',band_range_label,'_binned_data.list'],'w');
fid2=fopen('P_bands.txt','w');
fid3=fopen('A_bands.txt','w');
% fid2=fopen([dirname,'/',outfilename,'_',P_band_range_label,'_bands.txt'],'w');
% fid3=fopen([dirname,'/',outfilename,'_',A_band_range_label,'_bands.txt'],'w');
fprintf(fid1,token,L');
fprintf(fid2,'%f\t%f\t%f\n',P_bands');
fprintf(fid3,'%f\t%f\t%f\n',A_bands');
fclose(fid1);
fclose(fid2);
fclose(fid3);

for j=1:nomodes_lo
%     phase_label=['p_',num2str(P_bands(j,1)),'_to_',num2str(P_bands(j,3))];
    if length(['p_',num2str(P_bands(j,1)),'_to_',num2str(P_bands(j,3))])<=namelengthmax-8
        phase_label=['p_',num2str(P_bands(j,1)),'_to_',num2str(P_bands(j,3))];
    elseif length(['p_',num2str(P_bands(j,2))])<=namelengthmax-8
        phase_label=['p_',num2str(P_bands(j,2))];
    else
        phase_label=['p_',num2str(j)];
    end
    avpphasefilename=['avp_',phase_label,'.txt'];
    %     binneddataphasefilename=['bin_data_',phase_label,'.txt'];
    fprintf(fid,'%s\n',avpphasefilename);
    %     fprintf(fid1,'%s\n',binneddataphasefilename);
    fid4=fopen(avpphasefilename,'w');
    %     fid5=fopen(binneddataphasefilename,'w');
    if fid4==-1
        display(['Could not open ',avpphasefilename])
        fid4=fopen(['avp_p_',num2str(j),'.txt'],'w');
        fprintf(fid4,token,[P_bands(j,2) bincenters; A_bands(:,2) M(:,:,j)']);
    else
        fprintf(fid4,token,[P_bands(j,2) bincenters; A_bands(:,2) M(:,:,j)']);
    end
    %     fprintf(fid5,token,[L(:,j) N(:,:,j)]');
    fclose(fid4);
end

fclose('all');
cd (present_dir);