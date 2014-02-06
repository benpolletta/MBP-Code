function [f,data_hat,bands,signals,H,A,P,F,cycle_bounds]=filter_fft(data,varargin)

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
% 'bandrange',vector of bandlimits [low,hi]: 
%     Determines the upper and lower limits of range of frequencies, to be divided 
%     into a specified number of bins.

current_dir=pwd;

[r,c]=size(data);
if r<c
    data=data';
end

signal_length=length(data);
highest_freq=ceil(signal_length/2);

% Defaults.
sampling_freq=1;
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
    elseif strcmp(varargin(2*i-1),'bandrange')==1
        bandrange=cell2mat(varargin(2*i));    
    elseif strcmp(varargin(2*i-1),'dirname')==1
        dirname=char(varargin(2*i));
    end
end
    
data_hat=fft(data);
[r,c]=size(data_hat);
if r<c
    data_hat=data_hat';
end
indices=1:highest_freq;
f=sampling_freq*(indices'-1)/signal_length;

if ~isempty(filename)
    if ~isempty(dirname)
        mkdir (dirname);
        cd (dirname);
        fid=fopen([filename,'_fft.txt'],'w');
        fprintf(fid,'%f\t%f\n',[f abs(data_hat(1:highest_freq))]');
        cd (current_dir);
    else
        fid=fopen([filename,'_fft.txt'],'w');
        fprintf(fid,'%f\t%f\n',[f abs(data_hat(1:highest_freq))]');
    end
end

nyquist=sampling_freq/2;

signals=[]; H=[]; A=[]; P=[]; F=[]; bands=[]; params=[]; cycle_bounds=[];
    
bands=makebands(nobands,bandrange(1),bandrange(2),spacing);

for j=1:nobands

    flo=bands(j,1);
    fhi=bands(j,3);

    filter=butterworth(3,signal_length,sampling_freq,flo,fhi,0);
%     [b,a]=butter(3,[flo fhi]/sampling_freq);
%     [h,w]=freqz(b,a,highest_freq);
%     filter=h;
%     filter(highest_freq+1:signal_length)=flipud(filter(1:signal_length-highest_freq));
    
    filtered=data_hat.*sqrt(abs(filter));
    signals(:,j)=real(ifft(filtered));
    
end

H=hilbert(signals);
A=abs(H);
P=inc_phase(H);
[F,cycle_bounds,cycle_bands,cycle_freqs]=cycle_by_cycle_freqs(P,sampling_freq);


if ~isempty(filename)
    
    bands_label=['_fft_',num2str(nobands),'_bands_from_',num2str(bandrange(1)),'_to_',num2str(bandrange(2))];
    
    if length([filename,bands_label])<namelengthmax-11
        bands_name=[filename,bands_label];
    elseif length(filename)<namelengthmax-11
        bands_name=filename;
    else
        bands_name='';
    end
    
    if ~isempty(dirname)
        bands_dir=[dirname,'\',bands_name];
    else
        bands_dir=bands_name;
    end
    mkdir (bands_dir);
    cd (bands_dir);
    
    fid=fopen([bands_name,'_bands.txt'],'w');
    fid1=fopen([bands_name,'_sigs.txt'],'w');
    fid2=fopen([bands_name,'_amps.txt'],'w');
    fid3=fopen([bands_name,'_phases.txt'],'w');
    fid4=fopen([bands_name,'_freqs.txt'],'w');
    
    for i=1:nobands-1
        params=[params,'%f\t'];
    end
    params=[params,'%f\n'];
    
    fprintf(fid,'%f\t%f\t%f\n',bands');
    fprintf(fid1,params,signals');
    fprintf(fid2,params,A');
    fprintf(fid3,params,P');
    fprintf(fid4,params,F');
    fclose('all');
    
    cd (current_dir);
    
end