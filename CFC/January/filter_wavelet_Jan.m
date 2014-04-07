function [bands,H,A,P]=filter_wavelet_Jan(data,varargin)

% Filters a signal via convolution with complex Morlet wavelets at a vector of
% frequencies, and returns the complex signal, its amplitude, and its
% phase.
%
% Example:
% [bands,H,A,P]=filter_wavelet_Jan(PD_data,'bands',1:50,'sampling_freq',20000);
%
% INPUTS:
% varargin can contain eight options, each prefaced by an option specifier:
% 'sampling_freq', scalar: The sampling frequency of the signal.
%     Default is 1.
% Frequency resolution can be designated two ways:
% 1) 'no_cycles', scalar or vector: Number of cycles for each wavelet. Either
%   a scalar (in which case all are the same) or a vector the same length as
%   the vector of band centers.
% 2) 'freq_resol', vector: Half of the desired frequency resolution for
%   each band center frequency.
% 3) 'time_resol', vector: Half of the desired time resolution for
%   each band center frequency.
% Band centers can be designated two ways:
% 1) 'bands', vector of band centers or matrix of bands: Gives band centers.
%   Must be a column vector or a matrix with three or five columens.
% 2) 'nobands', number of bands: Determines the number of bands the signal will be
%     filtered into. Default is 10 bands, ranging from 1/signal_length to the 
%     nyquist frequency.
% 'bandrange', vector of bandlimits [low,hi]: 
%     Determines the upper and lower limits of range of frequencies, to be 
%     divided into a specified number of bins.
% 'spacing', 'linear' or 'log' or 'sqrt': Determines how a range of frequencies 
%     is divided into bins. Default is linear. 
% 
% OUTPUTS:
% 'bands' is a vector containing the (estimated) center frequencies of each
% output (wavelet-convolved) vector.
% 'H' is a matrix whose columns contain the complex-valued
% wavelet-convolved output vectors, at the frequencies specified in
% 'bands'.
% 'A' is a matrix whose columns contain the amplitudes of the
% wavelet-convolved output vectors.
% 'P' is a matrix whose columns contain the phases of the wavelet-convolved
% output vectors.

[r,c]=size(data);
if r<c
    data=data';
end

signal_length=length(data);

% Defaults.
sampling_freq=1;
nobands=10;
spacing='linear';
range_given=0;
bands=[];
no_cycles=8;
no_cycles_given=0;
freq_resol=[];
time_resol=[];

% Changing defaults.
for i=1:floor(length(varargin)/2)
    if strcmp(varargin(2*i-1),'sampling_freq')==1
        sampling_freq=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'nobands')==1
        nobands=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'spacing')==1
        if ischar(varargin(2*i))
            spacing=char(varargin(2*i));
        else
            spacing=cell2mat(varargin(2*i));
        end
    elseif strcmp(varargin(2*i-1),'bandrange')==1
        bandrange=cell2mat(varargin(2*i));
        range_given=1;
    elseif strcmp(varargin(2*i-1),'bands')==1
        bands=cell2mat(varargin(2*i));
        [r,c]=size(bands);
        if r<c
            bands=bands';
        end
        [nobands,band_cols]=size(bands);
    elseif strcmp(varargin(2*i-1),'no_cycles')==1
        no_cycles=cell2mat(varargin(2*i));
        no_cycles_given=1;
    elseif strcmp(varargin(2*i-1),'freq_resol')==1
        freq_resol=cell2mat(varargin(2*i));
    elseif strcmp(varargin(2*i-1),'time_resol')==1
        time_resol=cell2mat(varargin(2*i));
    end
end

if range_given==0
    
    bandrange=[1/signal_length sampling_freq/2];
    
end

H=zeros(signal_length,nobands);

if isempty(bands)
    
    bands=makebands(nobands,bandrange(1),bandrange(2),spacing);
    bands=bands(:,2);
    band_cols=1;
    
end

if band_cols==3

    bands=bands(:,2);

elseif band_cols==5

    bands=bands(:,3);

end

if ~isempty(freq_resol)
    
    if no_cycles_given==1 || ~isempty(time_resol)
        
        display('Only one of freq_resol, time_resol or no_cycles can be specified.')
        
        return
        
    else
        
        [~,cols]=size(freq_resol);
        if cols~=1
            freq_resol=freq_resol';
        end
        
        no_cycles=2*freq_resol./bands;
        
    end
    
end

if ~isempty(time_resol)
    
    if no_cycles_given==1 || ~isempty(freq_resol)
        
        display('Only one of freq_resol, time_resol or no_cycles can be specified.')
        
        return
        
    else
        
        [~,cols]=size(time_resol);
        if cols~=1
            time_resol=time_resol';
        end
        
        no_cycles=7*time_resol.*bands/(2*sampling_freq);
        
    end
    
end

[wavelet,~,freqresol,~] = dftfilt3(bands, no_cycles, sampling_freq, 'winsize', sampling_freq);

[r,c]=size(bands);
if r<c
    bands=bands';
end

[r,c]=size(freqresol);
if r<c
    freqresol=freqresol';
end

bands=[bands-freqresol/2 bands bands+freqresol/2];

for j=1:nobands

    temp=conv(data,wavelet(j,:));
    H(:,j)=temp(sampling_freq/2+1:end-sampling_freq/2);
    
end

A=abs(H);
P=angle(H);