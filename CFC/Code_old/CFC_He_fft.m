function [M,MI]=CFC_He_fft(datafile,sampling_freq,range_lo,range_hi,nobands_lo,nobands_hi,nobins,dataname)

% Finds and plots amplitude vs. phase curves for each pair of modes in the
% EMD of a signal. hhtdata is a matrix whose columns are the EMD modes of a
% signal. nobins is the number of bins the phase interval [-pi,pi] is
% divided into for the amplitude vs. phase curves. units says where the
% indices on a graph of the signal are drawn. bands is a 4-vector
% containing lower and upper frequency limits for the lower and upper
% frequency bands which will be parsed into nobins each.

if ischar(datafile)
    data=load(datafile);
    datafile=char(datafile);
    dataname=datafile(1:end-4);
elseif isfloat(datafile)
    data=datafile;
    dataname=char(dataname);
end

signal_length=length(data);

[f,data_hat,bands_lo,signals_lo,A_lo,P_lo,Pmod_lo]=plotfft_fancy(data,'fs',sampling_freq,'spacing','linear','filename',[dataname,'_lo'],'bandranges',range_lo,nobands_lo);
[f,data_hat,bands_hi,signals_hi,A_hi,P_hi,Pmod_hi]=plotfft_fancy(data,'fs',sampling_freq,'spacing','linear','filename',[dataname,'_hi'],'bandranges',range_hi,nobands_hi);

% Computing amplitude vs. phase curves.

M=amp_v_phase(nobins,A_hi,P_lo,1,[dataname,'_fft'],bands_hi,bands_lo);

% Finding inverse entropy measure for each pair of modes.

MI=inv_entropy(nobins,M,[dataname,'_fft'],bands_hi,bands_lo,'Hz');

% Calculating p-value for MI using bootstrap.
% 
% Shift=rand(100,nomodes)*2*pi;
% for i=1:100
%     P_s=P+ones(size(P))*diag(Shift(i,:));
%     M_s=amp_v_phase(nomodes,nobins,A,P_s,0);
%     MI_s(i,:,:)=inv_entropy(nomodes,nobins,M_s);
% end
% 
% for j=1:nomodes
%     for k=1:nomodes
%     p(j,k)=length(find(MI_s(:,j,k)<MI(j,k)))/100;
%     z(j,k)=(MI(j,k)-mean(MI_s(:,j,k)))/std(MI_s(:,j,k));
%     end
% end
% 
% p=reshape(p,nomodes,nomodes);
% z=reshape(z,nomodes,nomodes);
% 
% % Plotting p.
% 
% figure();
% 
% p_ext=ones(nomodes+1,nomodes+1);
% p_ext(1:nomodes,1:nomodes)=p'; % For the plot, we want k to be rows, j to be columns.
% pcolor(p_ext)
% colorbar
% 
% % Plotting z.
% 
% figure();
% 
% z_ext=ones(nomodes+1,nomodes+1);
% z_ext(1:nomodes,1:nomodes)=z'; % For the plot, we want k to be rows, j to be columns.
% pcolor(z_ext)
% colorbar


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% P_labels=[];
% for i=1:nobands_lo
%     P_labels(i)=strcat(num2str(bands_lo(i,1)),' to ',num2str(bands_lo(i,3)));
% end
% 
% A_labels=[];
% for i=1:nobands_hi
%     A_labels(i)=strcat(num2str(bands_hi(i,1)),' to ',num2str(bands_hi(i,3)));
% end
