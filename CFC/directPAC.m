function [Pref_phase,PAC]=directPAC(P,A,plotopt,filename)

[signal_length,nomodes]=size(P);

num_mat=A'*exp(sqrt(-1)*P);
Pref_phase=angle(num_mat);

num=abs(A'*exp(sqrt(-1)*P));
denom=sqrt(diag(diag(A'*A))*signal_length);

PAC=denom\num;

if plotopt==1
    
    figure();
    
    colorplot(PAC);
    axis ij;
    title('Direct Phase-Amplitude Coupling Estimator');
    ylabel('Mode (Amplitude)');
    xlabel('Mode (Phase)');
    
    if nargin>3
        saveas(gcf,[filename,'_direct_pac.fig']);
    end

end