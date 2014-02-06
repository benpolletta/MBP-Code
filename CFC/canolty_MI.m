function [Pref_phase,MI]=canolty_MI(P,A,filename,dirname)

[signal_length,nomodes]=size(P);

num_mat=A'*exp(sqrt(-1)*P);
Pref_phase=angle(num_mat);

num=abs(A'*exp(sqrt(-1)*P));
sq_abs_A=sqrt(abs(A));
denom=diag(diag(sq_abs_A'*sq_abs_A));

MI=denom\num;

if nargin>2
    
    save([dirname,'/',filename,'_canolty_MI.mat'],'Pref_phase','MI')

end