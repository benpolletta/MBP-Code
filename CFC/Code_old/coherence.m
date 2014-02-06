function [SI,PrefPhase]=coherence(nomodes,A,P,figchoice)

norm=sqrt(sum(A.^2));
A_norm=A*diag(1./norm);
PAC=A_norm'*exp(sqrt(-1)*P);

SI=abs(PAC);
for i=1:nomodes 
    PrefPhase(:,i)=(mod(phase(PAC(:,i)),2*pi)-pi)./pi; 
end

if figchoice==1

figure();

SI_ext=ones(nomodes+1,nomodes+1);
SI_ext(1:nomodes,1:nomodes)=SI;
pcolor(SI_ext)
colorbar

figure();

PrefPhase_ext=ones(nomodes+1,nomodes+1);
PrefPhase_ext(1:nomodes,1:nomodes)=PrefPhase;
pcolor(PrefPhase_ext)
colorbar

end