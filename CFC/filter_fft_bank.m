function [f,data_hat,bands,signals,H,A,P,F,cycle_bounds]=filter_fft_bank(data,sampling_freq,min_cycles_no,nobands,bandrange,spacing,buttorder,pct_pass,filename,dirname,opt_bands)

current_dir=pwd;

[r,c]=size(data);
if r<c
    data=data';
end

signal_length=length(data);
nyquist_index=ceil(signal_length/2);
    
data_hat=fft(data);
[r,c]=size(data_hat);
if r<c
    data_hat=data_hat';
end
indices=1:nyquist_index;
f=sampling_freq*(indices'-1)/signal_length;

if nargin>7
    if nargin>8
        mkdir (dirname);
        cd (dirname);
        if length([filename,'_fft.txt'])<=namelengthmax        
            fid=fopen([filename,'_fft.txt'],'w');
        else
            fid=fopen([filename(end-namelengthmax+8:end),'_fft.txt'],'w');
        end
        fprintf(fid,'%f\t%f\n',[f abs(data_hat(1:nyquist_index))]');
        cd (current_dir);
    else
        fid=fopen([filename,'_fft.txt'],'w');
        fprintf(fid,'%f\t%f\n',[f abs(data_hat(1:nyquist_index))]');
    end
end

% nyquist=sampling_freq/2;
   
if strcmp(spacing,'custom')==1
    bands=opt_bands;
    [nobands,~]=size(bands);
    nomodes=nobands;
else    
    bands=makebands(nobands,bandrange(1),bandrange(2),spacing);
end

signals=zeros(signal_length,nobands); H=zeros(signal_length,nobands); A=zeros(signal_length,nobands); P=zeros(signal_length,nobands); F=zeros(signal_length,nobands); params=[]; cycle_bounds=[];

% Passing data sequentially through highpass filters.

figure();

if strcmp(spacing,'custom')==1    
    filter_index=1;
    
    bw=bands(end,3)-bands(end,1);
    pbw=pct_pass*bw;
    overlap=bw-pbw;
    phi=bands(end,2)-pbw/2;
    shi=bands(end,2)-pbw/2-overlap;
    
    if buttorder==-1

        filter=butterworth_lopass(buttorder,signal_length,sampling_freq,phi,0);
        filtered=data_hat.*abs(filter);
        data_hat=data_hat-filtered;

    else

        if buttorder==0
            [n,Wn]=buttord(2*phi/sampling_freq,2*shi/sampling_freq,1,20);
        else
            n=buttorder;
            Wn=2*phi/sampling_freq;
        end

        [z,p,k]=butter(n,Wn,'low'); [sos,g]=zp2sos(z,p,k); h=dfilt.df2sos(sos,g);

        [H,~]=freqz(h,nyquist_index);
        filter=zeros(signal_length,1);
        filter(1:nyquist_index)=H;
        filter(nyquist_index+1:signal_length)=flipud(filter(1:signal_length-nyquist_index));
        plot(abs(filter),'k');
        hold on;

        data=filtfilthd(h,data,'reflect');

    end
    
else
    filter_index=2;
end

for j=nobands:-1:filter_index
    
    bw=bands(j,3)-bands(j,1);
    pbw=pct_pass*bw;
    overlap=bw-pbw;
    plo=bands(j,2)-pbw/2;
    slo=bands(j,2)-pbw/2-overlap;
    
    if buttorder==-1
        
        filter=butterworth_hipass(buttorder,signal_length,sampling_freq,plo,0);
    
        filtered=data_hat.*abs(filter);
        signals(:,nobands+1-j)=real(ifft(filtered));
        data_hat=data_hat-filtered;
    
    else

        if buttorder==0
            [n,Wn]=buttord(2*plo/sampling_freq,2*slo/sampling_freq,1,20);
%             [m,Wm]=buttord(2*slo/sampling_freq,2*plo/sampling_freq,1,20);
        else
            n=buttorder;
            Wn=2*plo/sampling_freq;
%             m=buttorder;
%             Wm=2*slo/sampling_freq;
        end

        [z,p,k]=butter(n,Wn,'high'); [sos,g]=zp2sos(z,p,k); h=dfilt.df2sos(sos,g);
        
        [H,~]=freqz(h,nyquist_index);
        filter=zeros(signal_length,1);
        filter(1:nyquist_index)=H;
        filter(nyquist_index+1:signal_length)=flipud(filter(1:signal_length-nyquist_index));
        plot(abs(filter));
        hold on;
        
        filtered=filtfilthd(h,data,'reflect');
        signals(:,nobands+1-j)=filtered;
        data=data-filtered;
        data_hat=fft(data);
        
%         [z1,p1,k1]=butter(m,Wm,'low'); [sos1,g1]=zp2sos(z1,p1,k1); h1=dfilt.df2sos(sos1,g1);
%         
%         [H1,W1]=freqz(h1,nyquist_index);
%         filter1=zeros(signal_length,1);
%         filter1(1:nyquist_index)=H1;
%         filter1(nyquist_index+1:signal_length)=flipud(filter1(1:signal_length-nyquist_index));
%         plot(abs(filter1),'k');
%        
%         data=filtfilthd(h1,data,'reflect');
        
    end
    
end

% Remaining data (lowpass filtered).

if strcmp(spacing,'custom')==0
    
    data=real(ifft(data_hat));
    signals(:,nobands)=data;
    
end

% bands=flipud(bands);

H=hilbert(signals);
A=abs(H);
P=inc_phase(H);
[F,cycle_bounds_0,bands,~]=cycle_by_cycle_freqs(P,sampling_freq);

% Excluding modes with very low cycle numbers. 

if strcmp(spacing,'custom')==0

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
%         cycle_freqs{i}=cycle_freqs_0{reliable_modes(i)};
    end
    bands=bands(reliable_modes,:);
    
else
    
    for i=1:nomodes
        cycle_bounds{i}=cycle_bounds_0{i};
%         cycle_freqs{i}=cycle_freqs_0{i};
    end   
    
end


if nargin>8
    
%     bands_label=[num2str(nobands),'_bands_from_',num2str(bandrange(1)),'_to_',num2str(bandrange(2))];
    
%     if length([filename,bands_label])<namelengthmax-11
%         bands_name=[filename,bands_label];
%     elseif length(filename)<namelengthmax-11
%         bands_name=filename;
%     else
%         bands_name=filename(end-namelengthmax+11:end);
%     end

    cd (dirname)
    
    mkdir (filename)
    
    cd (filename)
% 
%     if length(filename)<=namelengthmax-11
%     
%         saveas(gcf,[filename,'_filters.fig'])
%         close(gcf)
% 
%         fid=fopen([bands_label,'_bands.txt'],'w');
%         fid1=fopen([bands_label,'_sigs.txt'],'w');
%         fid2=fopen([bands_label,'_amps.txt'],'w');
%         fid3=fopen([bands_label,'_phases.txt'],'w');
%         fid4=fopen([bands_label,'_freqs.txt'],'w');
%     
%         for i=1:nobands-1
%             params=[params,'%f\t'];
%         end
%         params=[params,'%f\n'];
% 
%         fprintf(fid,'%f\t%f\t%f\n',bands');
%         fprintf(fid1,params,signals');
%         fprintf(fid2,params,A');
%         fprintf(fid3,params,P');
%         fprintf(fid4,params,F');
%         fclose('all');
%         
%     else
%            
%         mkdir (bands_label);
%         cd (bands_label)

    saveas(gcf,'filters.fig')
    close(gcf)

    mkdir cycle_bounds
    
    cd cycle_bounds
    
    for i=1:nomodes-1
        
        params=[params,'%f\t'];
  
        fid=fopen(['Mode_',num2str(i)],'w');
        fprintf(fid,'%d\t%d\n',cycle_bounds{i});
        fclose(fid);
        
    end
    
    params=[params,'%f\n'];
    
    fid=fopen(['Mode_',num2str(nomodes)],'w');
    fprintf(fid,'%d\t%d\n',cycle_bounds{nomodes});
    fclose(fid);
    
    cd ..
    
    fid=fopen('bands.txt','w');
    fid1=fopen('sigs.txt','w');
    fid2=fopen('amps.txt','w');
    fid3=fopen('phases.txt','w');
    fid4=fopen('freqs.txt','w');

    fprintf(fid,'%f\t%f\t%f\n',bands');
    fprintf(fid1,params,signals');
    fprintf(fid2,params,A');
    fprintf(fid3,params,P');
    fprintf(fid4,params,F');
    
    fclose('all');
%         
%     end
        
    cd (current_dir);
    
end