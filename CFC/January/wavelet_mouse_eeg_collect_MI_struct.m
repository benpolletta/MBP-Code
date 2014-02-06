function [MI_all]=wavelet_mouse_eeg_collect_MI_struct(epoch_list,condition_dirs)

no_states=length(condition_dirs);

measures={'IE','canMI','PLV'};
no_measures=length(measures);

close('all')

epoch_list=char(epoch_list);

[epoch_names,epoch_states]=textread(epoch_list,'%s%d%*[^\n]');
no_epochs=length(epoch_names);

bands_lo=4:.25:12;
bands_hi=20:5:180;

noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

all_dirname=['ALL_',epoch_list(1:end-5)];
mkdir (all_dirname)

for i=1:no_measures
    fid_vec(i)=fopen([all_dirname,'/',all_dirname,'_',measures{i},'.txt'],'w');
    fprintf(fid_vec(i),'%s\t%s\t','epoch','state');
end

for i=1:nophases
    for j=1:noamps
        band_label=[num2str(bands_hi(j)),'_by_',num2str(bands_lo(i))];
        for k=1:no_measures
            fprintf(fid_vec(k),'%s\t',band_label);
        end
        band_labels{(i-1)*nophases+j}=band_label;
    end
end

for k=1:no_measures
    fprintf(fid_vec(k),'%s\n','');
end

format=make_format(noamps*nophases+2,'f');

MI_all=zeros(no_epochs,noamps*nophases);
canolty_all=zeros(no_epochs,noamps*nophases);
PLV_all=zeros(no_epochs,noamps*nophases);

for j=48:no_epochs
    
    epoch_state=epoch_states(j);
    
    if epoch_state<no_states
    
        MI_struct=struct('name','MI_struct');
        
        dir_name=char(condition_dirs{epoch_state+1});
        
        epoch_name=char(epoch_names(j));
        epoch_name=epoch_name(1:end-4);
        
        filenames{1}=[dir_name,'/',epoch_name,'_IE.mat'];
        filenames{2}=[dir_name,'/',dir_name,'_canolty/',epoch_name,'_canolty_MI.mat'];
        filenames{3}=[dir_name,'/',dir_name,'_PLV/',epoch_name,'_PLV.mat'];
        
        for i=1:no_measures
            
            MI=load(char(filenames{i}),'MI');
            MI=MI.MI;
            MI=reshape(MI,1,noamps*nophases);
            
            MI_struct=setfield(MI_struct,char(measures{i}),MI);
            
            fprintf(fid_vec(i),format,[j epoch_state MI]);
        
        end
        
        MI_all(j,:)=MI_struct.IE;
        canolty_all(j,:)=MI_struct.canMI;
        PLV_all(j,:)=MI_struct.PLV;
        
    else
        
        MI_all(j,:)=nan(1,noamps*nophases);
        canolty_all(j,:)=nan(1,noamps*nophases);
        PLV_all(j,:)=nan(1,noamps*nophases);
        
    end

end

fclose('all');

save([all_dirname,'/',all_dirname,'_IE.mat'],'MI_all')
save([all_dirname,'/',all_dirname,'_canMI.mat'],'canolty_all')
save([all_dirname,'/',all_dirname,'_PLV.mat'],'PLV_all')

cd (present_dir);