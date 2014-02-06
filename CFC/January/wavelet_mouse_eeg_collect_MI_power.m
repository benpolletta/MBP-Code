function [MI_all]=wavelet_mouse_eeg_collect_MI_power(epoch_list,data_dir,condition_dirs,band_limits,PAC_labels)

present_dir=pwd;

close('all')

% Retrieving epoch names & states.

epoch_list=char(epoch_list);

[epoch_names,epoch_states]=textread(epoch_list,'%s%d%*[^\n]');
no_epochs=length(epoch_names);

% Opening files to save collected data.

all_dirname=['ALL_',epoch_list(1:end-5)];
mkdir (all_dirname)

measures={'IE','canMI','PLV'};
no_measures=length(measures);

for i=1:no_measures
    fid_vec(i)=fopen([all_dirname,'/',all_dirname,'_',measures{i},'.txt'],'w');
    fprintf(fid_vec(i),'%s\t%s\t','epoch','state');
end

% Parameters for PAC.

bands_lo=4:.25:12;  % Phase bands.
bands_hi=20:5:180;  % Amplitude bands.

noamps=length(bands_lo);
nophases=length(bands_hi);

for i=1:nophases
    for j=1:noamps
        PAC_label=[num2str(bands_hi(j)),'_by_',num2str(bands_lo(i))];   % PAC labels.
        for k=1:no_measures
            fprintf(fid_vec(k),'%s\t',PAC_label); % Printing at top of each file.
        end
        PAC_labels{(i-1)*nophases+j}=PAC_label; % Adding to cell array of all labels.
    end
end

for k=1:no_measures
    fprintf(fid_vec(k),'%s\n','');
end

PAC_format=make_format(noamps*nophases+2,'f'); % Format for saving PAC data.

% Parameters for FFT & band power.

f=sampling_freq*[1:signal_length/2]/(signal_length);

[no_bands,cols]=size(band_limits);

if cols~=2
    display('band_limits is 2 by n, where n is the number of bands, and the first row is the low frequency limit, and the second row is the high frequency limit.')
    return
end

for i=1:no_bands
    band_indices{i}=find(band_limits(i,1)<=f & f<=band_limits(i,2));
end

MI_all=zeros(no_epochs,noamps*nophases);
canolty_all=zeros(no_epochs,noamps*nophases);
PLV_all=zeros(no_epochs,noamps*nophases);

for j=1:no_epochs
    
    epoch_state=epoch_states(j);
    
    if epoch_state<3
    
        epoch_name=char(epoch_names(j));
        
        data=load([data_dir,'/',epoch_name]);
        
        data_hat=pmtm(data,[],signal_length);
        
        for i=1:no_bands
            
            BP=sum(abs(data_hat(band_indices{i})).^2);
            
        end
        
        BP_all(j,:)=BP;
        
        epoch_name=epoch_name(1:end-4);
        
        dir_name=char(condition_dirs{epoch_state+1});
                
        filenames{1}=[dir_name,'/',epoch_name,'_IE.mat'];
        filenames{2}=[dir_name,'/',dir_name,'_canolty/',epoch_name,'_canolty_MI.mat'];
        filenames{3}=[dir_name,'/',dir_name,'_PLV/',epoch_name,'_PLV.mat'];
        
        MI_struct=load([dir_name,'/',epoch_name,'_IE.mat'],'MI');
        MI=MI_struct.MI;
        MI=reshape(MI,1,noamps*nophases);
        
        fprintf(fid_vec(1),PAC_format,[j epoch_state MI]);
        
        MI_all(j,:)=MI;
        
        canMI_struct=load([dir_name,'/',dir_name,'_canolty/',epoch_name,'_canolty_MI.mat'],'MI');
        canMI=canMI_struct.MI;
        canMI=reshape(canMI,1,noamps*nophases);
        
        fprintf(fid_vec(2),PAC_format,[j epoch_state canMI]);
        
        canMI_all(j,:)=canMI;
        
        PLV_struct=load([dir_name,'/',dir_name,'_PLV/',epoch_name,'_PLV.mat'],'MI');
        PLV=PLV_struct.MI;
        PLV=reshape(PLV,1,noamps*nophases);
        
        fprintf(fid_vec(3),PAC_format,[j epoch_state PLV]);
        
        PLV_all(j,:)=PLV;
        
    else
        
        MI_all(j,:)=nan(1,noamps*nophases);
        
    end

end

for i=1:length(fid_vec)
    
    fclose(fid_vec(i));
    
end

save([all_dirname,'/',all_dirname,'_IE.mat'],'MI_all','canMI_all','PLV_all')

cd (present_dir);