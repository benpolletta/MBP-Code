function [f,data_hat,bands,signals,A,P,Pmod]=plotfft_fancy(data,varargin)

% varargin can contain five options, each prefaced by an option specifier:
% 'sampling frequency',sampling_freq: The sampling frequency of the signal.
%     Default is 1.
% 'nobands',number of bands: Determines the number of bands the signal will be
%     filtered into. Default is 10 bands, ranging from 1/signal_length to the 
%     nyquist frequency.
% 'filename','filename': The name of the data being analyzed; will be used to 
%     save figures.
% 'spacing','linear' or 'log' or 'sqrt': Determines how a range of frequencies 
%     is divided into bins. Default is sqrt.
% 'bandranges',vector of bandlimits (low1,hi1,low2,hi2),vector of bands numbers: 
%     Determines the upper and lower limits of ranges of frequencies, each divided 
%     into a specified number of bins. 'bandranges' should always be the last set
%     of arguments.

signal_length=length(data);

% Defaults.
sampling_freq=1;
noranges=1;
nobands=10;
spacing='sqrt';
filename=[];
bandranges=[1/signal_length sampling_freq/2];

% Changing defaults.
for i=1:floor(length(varargin)/2)
    if strcmp(varargin(2*i-1),'fs')==1
        sampling_freq=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'nobands')==1
        nobands=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'filename')==1
        filename=char(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'spacing')==1
        spacing=char(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'bandranges')==1
        bandranges=cell2mat(varargin(2*i));
        nobands=cell2mat(varargin(2*i+1));
        noranges=length(bandranges)/2;    
    end
end
    
data_hat=fft(data);

figure();
subplot(1,2,1)
t=1:signal_length;
t=t/sampling_freq;
plot(t,data)
title('Data')
subplot(1,2,2)
indices=1:signal_length/2;
f=sampling_freq*(indices'-1)/signal_length;
plot(f,abs(data_hat(1:signal_length/2)))
title('FFT (Power)')

if ~isempty(filename)
    saveas(gcf,[filename,'_fft.fig']);
    fid=fopen([filename,'_fft.txt'],'w');
    fprintf(fid,'%f\t%f\n',[f data_hat(1:signal_length/2)]');
end

nyquist=sampling_freq/2;

signals=[]; A=[]; P=[]; Pmod=[]; bands=[]; params=[]; names=[];

for i=1:noranges
    
    bands=[];
    
    bands(sum(nobands(1:i-1))+1:sum(nobands(1:i)),:)=makebands(nobands(i),bandranges(2*i-1),bandranges(2*i),spacing);
    
    figure(); hold on;
    
    for j=1:nobands(i)

        bandindex=sum(nobands(1:i-1))+j;
        flo=bands(j,3*(i-1)+1);
        fhi=bands(j,3*i);
        bandnames{bandindex}=[num2str(flo),' to ',num2str(fhi)];

        filter=butterworth(3,signal_length,sampling_freq,flo,fhi,0);

        filtered=data_hat.*sqrt(filter);
        signals(:,bandindex)=real(ifft(filtered));

        H(:,bandindex)=hilbert(signals(:,bandindex));
        A(:,bandindex)=abs(H(:,bandindex));
        P(:,bandindex)=phase(H(:,bandindex));
        Pmod(:,bandindex)=mod(P(:,bandindex),2*pi)/pi;

        if nobands(i)>10
            clf();
            
            subplot(3,1,1);
            plot(t,signals(:,bandindex));
            title([bandnames{bandindex},' Hz Band'])

            subplot(3,1,2);
            plot(t,A(:,bandindex));
            title(['Amplitude of ',bandnames{bandindex},' Hz Band']);

            subplot(3,1,3);
            plot(t,Pmod(:,bandindex));
            title(['Phase of ',bandnames{bandindex},' Hz Band']);

            if ~isempty(filename)
                saveas(gcf,[filename,'_',bandnames{bandindex},'_band.fig']);
            end
        else
            subplot(nobands,3,3*i-2);
            plot(signals(:,i));
            title([bandnames{bandindex},' Hz Band'])

            subplot(nobands,3,3*i-1);
            plot(A(:,i));
            title(['Amplitude of ',bandnames{bandindex},' Hz Band']);

            subplot(nobands,3,3*i);
            plot(Pmod(:,i));
            title(['Phase of ',bandnames{bandindex},' Hz Band']);
        end
        
    end
    
    if nobands(i)<=10 & ~isempty(filename) & noranges>1
        saveas(gcf,[filename,'_fft_bands_',num2str(i),'.fig']);
    elseif nobands(i)<=10 & ~isempty(filename)
        saveas(gcf,[filename,'_fft_bands.fig']);
    end
    
    close(gcf);
    
end
    
if ~isempty(filename)
    fid=fopen([filename,'_fft_bands.txt'],'w');
    fid1=fopen([filename,'_fft_band_amps.txt'],'w');
    fid2=fopen([filename,'_fft_band_phases.txt'],'w');
    
    for i=1:sum(nobands)-1
        fprintf(fid,'%s\t',bandnames{i});
        fprintf(fid1,'%s\t',bandnames{i});
        fprintf(fid2,'%s\t',bandnames{i});
        params=[params,'%f\t'];
    end
    fprintf(fid,'%s\n',bandnames{sum(nobands)});
    fprintf(fid1,'%s\n',bandnames{sum(nobands)});
    fprintf(fid2,'%s\n',bandnames{sum(nobands)});
    params=[params,'%f\n'];
    
    fprintf(fid,params,signals');
    fprintf(fid1,params,A');
    fprintf(fid2,params,P');
    fclose('all');
end

%     bands_label=[];
%     for i=1:noranges
%         bands_label=[bands_label,'_',num2str(nobands(i)),'_bands_from_',num2str(bandranges(2*i-1)),'_to_',num2str(bandranges(2*i))];
%     end
%     
%     bands_dir=[filename,bands_label];
%     mkdir (bands_dir);