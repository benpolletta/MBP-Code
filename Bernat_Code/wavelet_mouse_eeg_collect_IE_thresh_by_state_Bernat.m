function wavelet_mouse_eeg_collect_IE_thresh_by_state_Bernat(subject,drug,channel,pval)

close('all')

present_dir=pwd;

measures={'pt','zt','lt','zs'};
no_measures=length(measures);

record_name=[char(subject),'_',char(drug)];

cd (record_name);

channel_name=[record_name,'_chan',num2str(channel)];

cd ([channel_name,'_epochs']);

epoch_list=[channel_name,'_4hrs_by_state_epochs.list'];

[epoch_numbers,epoch_periods,epoch_states,epoch_names]=textread(epoch_list,'%d%s%s%s%*[^\n]');
no_epochs=length(epoch_numbers);

all_dirname=['ALL_',channel_name,'_4hrs_by_state'];
mkdir (all_dirname);

bands_lo=1:.25:12;
bands_hi=20:5:200;

noamps=length(bands_hi);
nophases=length(bands_lo);

for m=1:no_measures
    IE_fid_vec(m)=fopen([all_dirname,'/',all_dirname,'_p',num2str(pval),'_IE',measures{m},'.txt'],'w');
end

% for p=1:nophases
%     for a=1:noamps
%         band_label=[num2str(bands_hi(a)),'_by_',num2str(bands_lo(p))];
%         for m=1:no_measures
%             fprintf(IE_fid_vec(m),'%s\t',band_label);
%         end
% %         band_labels{(p-1)*nophases+a}=band_label;
%     end
% end
% 
% for m=1:no_measures
%     fprintf(IE_fid_vec(m),'%s\n','');
% end

% format=['%d\t%s\t',make_format(noamps*nophases,'f')];
format=make_format(noamps*nophases,'f');

for e=1:no_epochs
    
    epoch_period=char(epoch_periods(e));
    
    epoch_state=char(epoch_states(e));
    
    thresh_name=dir(['THRESH*',channel_name,'_',epoch_period,'_',epoch_state,'_*shufs']);
    thresh_name=thresh_name.name;
    
    epoch_name=char(epoch_names(e));
    epoch_name=epoch_name(1:end-4);
    
    filename=[thresh_name,'/',epoch_name,'_p',num2str(pval),'_IE_thresh.mat'];
        
    MI=load(filename,'MI_thresh');
    MI=MI.MI_thresh;
    MI = MI(1:noamps, 1:nophases, :);
    
    for m=1:min(no_measures,size(MI,3))

        MI_vec=reshape(MI(:,:,m),1,noamps*nophases);
        
        fprintf(IE_fid_vec(m),format,MI_vec);
       
    end
    
end

fclose('all');

cd (present_dir);