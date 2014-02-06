function Misuzeki_phasic_analysis

sampling_freq=1000;

[listname,listpath]=uigetfile('*bouts.list','Choose a bout list to run REM power & frequency analysis.');
filenames=textread([listpath, listname],'%s%*[^\n]');
dirname=[listpath, '/', listname(1:end-5), '_Misuzeki'];
mkdir(dirname);

parfor i=1:length(filenames)

    filename=char(filenames(i));
    data=load(filename);
        
      
    [n,Wn]=buttord(2*[4.5 11.5]/sampling_freq,2*[3.5 12.5]/sampling_freq,1,70);
    
    [z,p,k]=butter(n,Wn); [sos,g]=zp2sos(z,p,k); h=dfilt.df2sos(sos,g);
%     [H,W]=freqz(h,nyquist_index);
%     
%     filter=zeros(signal_length,1);
%     filter(1:nyquist_index)=H;
%     filter(nyquist_index+1:signal_length)=flipud(filter(1:signal_length-nyquist_index));
%     plot(abs(filter));
%     hold on;
                
    theta=filtfilthd(h,data,'reflect');
    
    dtheta=diff(theta);
    dtheta=sign(dtheta);
    peak_indices=find(diff(dtheta)==-2);
    
    interpeak_intervals=diff(peak_indices);
    
    smoothed_freq=nan(size(theta));
    
    for c=1:length(peak_indices)
        
        smoothed_freq(peak_indices(c):peak_indices(c+1))=interpeak_intervals(c)*ones(size(smoothed_freq(peak_indices(c):peak_indices(c+1))));
        
    end
    
    smoothed_freq=conv(smoothed_freq,ones(11,1),'same');
    
end