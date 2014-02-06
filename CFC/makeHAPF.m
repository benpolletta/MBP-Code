function [H,A,P,F,cycle_bounds,bands,cycle_freqs]=makeHAPF(hhtdata,sampling_freq,min_cycles_no,filename,dirname)

[~,nomodes]=size(hhtdata);

H=[]; A=[]; P=[]; F=[]; params=[];

H=hilbert(hhtdata);
A=abs(H);
P=inc_phase(H);
[F,cycle_bounds_0,bands,cycle_freqs_0]=cycle_by_cycle_freqs(P,sampling_freq);

% Excluding modes with very low cycle numbers. 

for i=1:length(cycle_bounds_0)
    nocycles(i)=length(cycle_bounds_0{i});
end
reliable_modes=find(nocycles>=min_cycles_no);
nomodes=length(reliable_modes);
H=H(:,reliable_modes);
A=A(:,reliable_modes);
P=P(:,reliable_modes);
F=F(:,reliable_modes);
for i=1:nomodes
    cycle_bounds{i}=cycle_bounds_0{reliable_modes(i)};
    cycle_freqs{i}=cycle_freqs_0{reliable_modes(i)};
end
bands=bands(reliable_modes,:);

% Saving data.

if nargin>3
    if nargin>4 && ~isempty(dirname)
        fid1=fopen([dirname,'/',filename,'_amps.txt'],'w');
        fid2=fopen([dirname,'/',filename,'_phases.txt'],'w');
        fid3=fopen([dirname,'/',filename,'_freqs.txt'],'w');
        fid4=fopen([dirname,'/',filename,'_bands.txt'],'w');
        cb_dir=[dirname,'/',filename,'_cycle_bounds'];
        mkdir (cb_dir);
    else
        fid1=fopen([filename,'_amps.txt'],'w');
        fid2=fopen([filename,'_phases.txt'],'w');
        fid3=fopen([filename,'_freqs.txt'],'w');
        fid4=fopen([filename,'_bands.txt'],'w');
        cb_dir=[filename,'_cycle_bounds'];
        mkdir (cb_dir);
    end
    
    fprintf(fid4,'%f\t%f\t%f\n',bands');
    
    for i=1:nomodes-1
        fprintf(fid1,'%s\t',num2str(i));
        fprintf(fid2,'%s\t',num2str(i));
        fprintf(fid3,'%s\t',num2str(i));
        params=[params,'%f\t'];
        
        fid=fopen([cb_dir,'/Mode_',num2str(i)],'w');
        fprintf(fid,'%d\t%d\n',cycle_bounds{i});
        fclose(fid);
    end
    fprintf(fid1,'%s\n',num2str(nomodes));
    fprintf(fid2,'%s\n',num2str(nomodes));
    fprintf(fid3,'%s\n',num2str(nomodes));
    params=[params,'%f\n'];
    
    fid=fopen([cb_dir,'/Mode_',num2str(nomodes)],'w');
    fprintf(fid,'%d\t%d\n',cycle_bounds{nomodes});
    fclose(fid);

    fprintf(fid1,params,A');
    fprintf(fid2,params,P');
    fprintf(fid3,params,F');
    fclose('all');
end