function [H,A,P,Pmod]=plotHAP(hhtdata,sampling_freq,filename,dirname)

[signal_length,nomodes]=size(hhtdata);
t=1:signal_length;
t=t*sampling_freq;

H=[]; A=[]; P=[]; Pmod=[]; params=[];

H=hilbert(hhtdata);
A=abs(H);

figure();

for i=1:nomodes
    
    P(:,i)=phase(H(:,i));
    Pmod(:,i)=mod(P(:,i),2*pi)/pi;
    
    if nomodes>10
        clf();

        subplot(3,1,1);
        plot(hhtdata(:,i));
        title(['Mode ',num2str(i)])

        subplot(3,1,2);
        plot(t,A(:,i));
        title(['Amplitude of Mode ',num2str(i)]);

        subplot(3,1,3);
        plot(Pmod(:,i));
        title(['Phase of Mode ',num2str(i)]);

        if nargin>2
            if nargin>3
                saveas(gcf,[dirname,'\',filename,'_mode_',num2str(i),'.fig']);
            else
                saveas(gcf,[filename,'_mode_',num2str(i),'.fig']);
            end
        end
        
    else
        subplot(nomodes,3,3*i-2);
        plot(hhtdata(:,i));
        title(['Mode ',num2str(i)])

        subplot(nomodes,3,3*i-1);
        plot(A(:,i));
        title(['Amplitude of Mode ',num2str(i)]);

        subplot(nomodes,3,3*i);
        plot(Pmod(:,i));
        title(['Phase of Mode ',num2str(i)]);
    end
    
end

if nomodes<=10 & nargin>2
    if nargin>3
        saveas(gcf,[dirname,'\',filename,'_modes.fig']);
    else
        saveas(gcf,[filename,'_modes.fig']);
    end
end

if nargin>2 
    if nargin>3
        fid1=fopen([dirname,'\',filename,'_mode_amps.txt'],'w');
        fid2=fopen([dirname,'\',filename,'_mode_phases.txt'],'w');
    else
        fid1=fopen([filename,'_mode_amps.txt'],'w');
        fid2=fopen([filename,'_mode_phases.txt'],'w');
    end
    
    for i=1:nomodes-1
        fprintf(fid1,'%s\t',num2str(i));
        fprintf(fid2,'%s\t',num2str(i));
        params=[params,'%f\t'];
    end
    fprintf(fid1,'%s\n',num2str(nomodes));
    fprintf(fid2,'%s\n',num2str(nomodes));
    params=[params,'%f\n'];

    fprintf(fid1,params,A');
    fprintf(fid2,params,P');
    fclose('all');
end