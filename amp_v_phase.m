function [bincenters,M]=amp_v_phase_Jan(nobins,A,P)

% function [bincenters,M,N,L]=amp_v_phase_new(nobins,A,P,outfilename,A_bands,P_bands,dirname)

% Finding amplitude vs. phase curves for each pair of modes. nobins is the 
% number of bins, A is a matrix whose columns are the amplitudes of the modes, 
% P is a matrix whose columns are the phases of the modes, figchoice is 
% either 1 (to make a figure) or 0 (to omit the figure). A_bands is a matrix of
% mins, centers and maxes for the frequency bands of the amplitude-modulated 
% components. P_bands gives the same for the phase-modulating components.

[~,nomodes_hi]=size(A);
[~,nomodes_lo]=size(P);

bincenters=1:nobins;
bincenters=(bincenters-1)*2*pi/nobins-pi*(nobins-1)/nobins;

Pmod=mod(P,2*pi)-pi;

M=zeros(nobins,nomodes_hi,nomodes_lo);
% L=zeros(nopoints,nomodes_lo);

for j=1:nomodes_lo     % Counter for modes providing phase.
%     amp_index=0;    % Index for recording all amplitudes in each phase bin.
    for i=1:nobins  % Counter for phase bins.
        clear indices
        indices=find(bincenters(i)-pi/nobins<=Pmod(:,j) & Pmod(:,j)<bincenters(i)+pi/nobins);   % Bin phases.
%         L(amp_index+1:amp_index+length(indices),j)=bincenters(i)/pi; % Vector recording the number of time points falling around phase i of mode j.
%         L(indices,j)=bincenters(i)/pi;
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


        