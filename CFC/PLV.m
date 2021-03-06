function [Pref_phase,Phaselockingval]=PLV(P1,P2,filename,dirname)

[~,nophases]=size(P1);

MRV=mean(exp(sqrt(-1)*(P1-P2)));

Pref_phase=angle(MRV);
Phaselockingval=abs(MRV);

if nargin>2
    
    if nargin>3
    
        save([dirname,'/',filename,'_PLV.mat'],'Pref_phase','Phaselockingval')

    else
        
        save([filename,'_PLV.mat'],'Pref_phase','Phaselockingval')
        
    end
        
end