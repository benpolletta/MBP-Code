function [H,A,P,F,cycle_bounds,bands]=makeHAP(hhtdata,sampling_freq,min_cycles_no,filename,dirname)

[signal_length,nomodes]=size(hhtdata);

H=[]; A=[]; P=[]; F=[]; params=[];

H=hilbert(hhtdata);
A=abs(H);
P=inc_phase(H);
[F,cycle_bounds,bands]=emd_cycle_by_cycle_freqs(P,sampling_freq);

% Excluding modes with very low cycle numbers. 

for i=1:length(cycle_bounds)
    nocycles(i)=length(cycle_bounds{i});
end
reliable_modes=find(nocycles>=min_cycles_no);
nomodes=length(reliable_modes);
H=H(:,reliable_modes);
A=A(:,reliable_modes);
P=P(:,reliable_modes);

% Saving data.

if nargin>3
    if nargin>4
        fid1=fopen([dirname,'\',filename,'_mode_amps.txt'],'w');
        fid2=fopen([dirname,'\',filename,'_mode_phases.txt'],'w');
        fid3=fopen([dirname,'\',filename,'_mode_freqs.txt'],'w');
        fid4=fopen([dirname,'\',filename,'_mode_bands.txt'],'w');
%         fid5=fopen([dirname,'\',filename,'_mode_cycles.txt'],'w');
    else
        fid1=fopen([filename,'_mode_amps.txt'],'w');
        fid2=fopen([filename,'_mode_phases.txt'],'w');
        fid3=fopen([filename,'_mode_freqs.txt'],'w');
        fid4=fopen([dirname,'\',filename,'_mode_bands.txt'],'w');
%         fid5=fopen([dirname,'\',filename,'_mode_cycles.txt'],'w');
    end
    
    fprintf(fid4,'%f\t%f\t%f\n',bands');
    
    for i=1:nomodes-1
        fprintf(fid1,'%s\t',num2str(i));
        fprintf(fid2,'%s\t',num2str(i));
        fprintf(fid3,'%s\t',num2str(i));
        params=[params,'%f\t'];
    end
    fprintf(fid1,'%s\n',num2str(nomodes));
    fprintf(fid2,'%s\n',num2str(nomodes));
    fprintf(fid3,'%s\n',num2str(nomodes));
    params=[params,'%f\n'];

    fprintf(fid1,params,A');
    fprintf(fid2,params,P');
    fprintf(fid3,params,F');
    fclose('all');
end