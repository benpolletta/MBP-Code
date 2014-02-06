function [spec_all,BP_all]=wavelet_mouse_eeg_collect_power(sampling_freq,signal_length,epoch_list,data_dir,band_limits,band_labels)

present_dir=pwd;

close('all')

% Retrieving epoch names & states.

epoch_list=char(epoch_list);

[epoch_names,epoch_states]=textread([data_dir,'/',epoch_list],'%s%d%*[^\n]');
no_epochs=length(epoch_names);

% Opening files to save collected data.

all_dirname=['ALL_',epoch_list(1:end-5)];
mkdir (all_dirname)

measures={'spec_pow','band_pow'};
no_measures=length(measures);

for i=1:no_measures
    fid_vec(i)=fopen([all_dirname,'/',all_dirname,'_',measures{i},'.txt'],'w');
    fprintf(fid_vec(i),'%s\t%s\t','epoch','state');
end

% Parameters for FFT & band power.

f=sampling_freq*[0:signal_length/2]/(signal_length);
no_freqs=length(f);

fprintf(fid_vec(1),make_format(no_freqs,'f'),f);

spec_format=make_format(no_freqs+2,'f');

[no_bands,cols]=size(band_limits);

if cols~=2
    display('band_limits is 2 by n, where n is the number of bands, and the first row is the low frequency limit, and the second row is the high frequency limit.')
    return
end

for i=1:no_bands
    fprintf(fid_vec(2),'%s\t',band_labels{i}); % Printing at top of each file.
    band_indices{i}=find(band_limits(i,1)<=f & f<=band_limits(i,2));
end

BP_format=make_format(no_bands+2,'f');

spec_all=zeros(no_epochs,no_freqs);
BP_all=zeros(no_bands,no_bands);

for j=1:no_epochs
    
    epoch_state=epoch_states(j);
    
    if epoch_state<3
    
        epoch_name=char(epoch_names(j));
        
        data=load([data_dir,'/',epoch_name]);
        
        data_hat=pmtm(data,[],signal_length);
     
        for i=1:no_bands
            
            BP=sum(abs(data_hat(band_indices{i})).^2);
            
        end
        
        
        fprintf(fid_vec(1),spec_format,j,epoch_state,data_hat);
        fprintf(fid_vec(2),BP_format,[j epoch_state BP]);

        spec_all(j,:)=data_hat;
        BP_all(j,:)=BP;
        
    else
        
        spec_all(j,:)=nan(1,no_freqs);
        BP_all(j,:)=nan(1,no_bands);
        
    end

end

for i=1:length(fid_vec)
    
    fclose(fid_vec(i));
    
end

save([all_dirname,'/',all_dirname,'_BP.mat'],'spec_all','BP_all')

cd (present_dir);