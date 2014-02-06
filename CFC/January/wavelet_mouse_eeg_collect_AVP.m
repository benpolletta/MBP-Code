function [AVP_all]=wavelet_mouse_eeg_collect_AVP(epoch_list,condition_dirs,phase_freq,norm_flag)

close('all')

no_states=length(condition_dirs);

epoch_list=char(epoch_list);

[epoch_names,epoch_states]=textread(epoch_list,'%s%d%*[^\n]');
no_epochs=length(epoch_names);

bins=.05:.1:1.95;
bands_lo=4:.25:12;
bands_hi=20:5:180;

nobins=length(bins);
noamps=length(bands_hi);
[~,phase_index]=min(abs(bands_lo-phase_freq));

present_dir=pwd;

all_dirname=['ALL_',epoch_list(1:end-5)];
mkdir (all_dirname)

if norm_flag==1
    fid_AVP=fopen([all_dirname,'/',all_dirname,'_AVP_',num2str(phase_freq),'_norm.txt'],'w');
else
    fid_AVP=fopen([all_dirname,'/',all_dirname,'_AVP_',num2str(phase_freq),'.txt'],'w');
end

fprintf(fid_AVP,'%s\t%s\t','epoch','state');
    
for i=1:noamps
    for j=1:nobins
        band_label=[num2str(bands_hi(i)),'-amp-around-',num2str(bins(j)),'-pi'];
        fprintf(fid_AVP,'%s\t',band_label);
        band_labels{(i-1)*noamps+j}=band_label;
    end
end

fprintf(fid_AVP,'%s\n','');

format=make_format(noamps*nobins+2,'f');

AVP_all=zeros(no_epochs,noamps*nobins);

for j=1:no_epochs
    
    epoch_state=epoch_states(j);
    
    if epoch_state<no_states
    
        dir_name=char(condition_dirs{epoch_state+1});
        
        epoch_name=char(epoch_names(j));
        epoch_name=epoch_name(1:end-4);
        
        filename=[dir_name,'/',epoch_name,'_IE.mat'];
        
        AVP_struct=load(filename,'M');
        AVP=AVP_struct.M;
        
        if norm_flag==1
        
            mean_avg_amp=repmat(mean(AVP,2),1,nobins);
            AVP=AVP./mean_avg_amp-1;
            
        end
        
        AVP=reshape(AVP(:,:,phase_index)',1,nobins*noamps);
        
        fprintf(fid_AVP,format,[j epoch_state AVP]);
        
        AVP_all(j,:)=AVP;
                
    else
        
        AVP_all(j,:)=nan(1,noamps*nobins);
        
    end

end

fclose(fid_AVP)

if norm_flag==1

    save([all_dirname,'/',all_dirname,'_AVP_',num2str(phase_freq),'_norm.mat'],'AVP_all')
else
    
    save([all_dirname,'/',all_dirname,'_AVP_',num2str(phase_freq),'.mat'],'AVP_all')

end
    
cd (present_dir);