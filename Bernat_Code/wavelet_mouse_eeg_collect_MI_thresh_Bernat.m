function [MI_all]=wavelet_mouse_eeg_collect_MI_thresh_Bernat(subject,drug,channel,pval)

close('all')

present_dir=pwd;

% measures={'IE','canMI','PLV'};
% measures={'p0.95_IE','p0.99_IE','p0.999_IE','p0.95_canMI','p0.99_canMI','p0.999_canMI'};
measures={'IE','canMI'};
no_measures=length(measures);

record_name=[char(subject),'_',char(drug)];

cd (record_name);

channel_name=[record_name,'_chan',num2str(channel)];

cd ([channel_name,'_epochs']);

epoch_list=[channel_name,'_hours_epochs.list'];

all_dirname=['ALL_',epoch_list(1:end-12)];
mkdir (all_dirname);

[epoch_numbers,epoch_periods,epoch_names]=textread(epoch_list,'%d%s%s%*[^\n]');
no_epochs=length(epoch_numbers);

bands_lo=1:.25:12;
bands_hi=20:5:200;

noamps=length(bands_hi);
nophases=length(bands_lo);

for m=1:no_measures
    fid_vec(m)=fopen([all_dirname,'/',all_dirname,'_',num2str(pval),'_',measures{m},'_thresh.txt'],'w');
    fprintf(fid_vec(m),'%s\t%s\t','epoch','period');
end

for p=1:nophases
    for a=1:noamps
        band_label=[num2str(bands_hi(a)),'_by_',num2str(bands_lo(p))];
        for k=1:no_measures
            fprintf(fid_vec(k),'%s\t',band_label);
        end
        band_labels{(p-1)*nophases+a}=band_label;
    end
end

for k=1:no_measures
    fprintf(fid_vec(k),'%s\n','');
end

format=make_format(noamps*nophases+2,'f');

MI_all=zeros(no_epochs,noamps*nophases);
canolty_all=zeros(no_epochs,noamps*nophases);
% PLV_all=zeros(no_epochs,noamps*nophases);

for j=1:no_epochs
    
    epoch_period=char(epoch_periods(j));
    
    %     if epoch_state<no_states
    
    MI_struct=struct('name','MI_struct');
    
    thresh_name=dir(['THRESH*',channel_name,'_',epoch_period,'_*shufs']);
    thresh_name=thresh_name.name;
    
    epoch_name=char(epoch_names(j));
    epoch_name=epoch_name(1:end-4);
    
    for i=1:no_measures
    
        measure=char(measures{i});
        
        filename=[thresh_name,'/',epoch_name,'_p',num2str(pval),'_',measure,'_thresh.mat'];
        
        MI=load(filename,'MI_thresh');
        MI=MI.MI_thresh;
        MI=reshape(MI(:,:,1),1,noamps*nophases);
        
        MI_struct=setfield(MI_struct,char(measures{i}),MI);
        
        fprintf(fid_vec(i),format,[j epoch_state MI]);
        
    end
    
    MI_all(j,:)=MI_struct.IE;
    canolty_all(j,:)=MI_struct.canMI;
    %         PLV_all(j,:)=MI_struct.PLV;
    
    %     else
    %
    %         MI_all(j,:)=nan(1,noamps*nophases);
    %         canolty_all(j,:)=nan(1,noamps*nophases);
    % %         PLV_all(j,:)=nan(1,noamps*nophases);
    %
    %     end
    
end

fclose('all');

save([all_dirname,'/',all_dirname,'_IE_thresh.mat'],'MI_all')
save([all_dirname,'/',all_dirname,'_canMI_thresh.mat'],'canolty_all')
% save([all_dirname,'/',all_dirname,'_PLV_thresh.mat'],'PLV_all')

cd (present_dir);