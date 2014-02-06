function [M,MI]=inverse_entropy_Jan(nobins,A,P,filename,dirname)

% Computing amplitude vs. phase curves.

[bincenters,M]=amp_v_phase_Jan(nobins,A,P);

% Finding inverse entropy measure for each pair of modes.

MI=inv_entropy_no_save(M);

% Saving.

save([dirname,'/',filename,'_IE.mat'],'bincenters','M','MI')