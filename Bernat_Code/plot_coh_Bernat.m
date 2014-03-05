function plot_coh_Bernat(chan1_name,chan1_channels,chan2_name,chan2_channels)

pair_dir=sprintf('All_%s_by_%s_cohy',chan1_name,chan2_name);
mkdir (pair_dir)

sampling_freq=1000;
signal_length=4096*4;
f=(sampling_freq/2)*([1:signal_length/2+1]-1)/(signal_length);
f(f>200)=[];
no_freqs=length(f);
cohy_format=make_format(no_freqs,'f');

present_dir=pwd;

load('subjects.mat')
load('drugs.mat')
load('channels.mat')

drugs_fid=fopen([pair_dir,'/',pair_dir,'_drugs.txt'],'w');
subjects_fid=fopen([pair_dir,'/',pair_dir,'_subjects.txt'],'w');
hrs_fid=fopen([pair_dir,'/',pair_dir,'_hrs.txt'],'w');
rcoh_fid=fopen([pair_dir,'/',pair_dir,'_rcoh.txt'],'w');
icoh_fid=fopen([pair_dir,'/',pair_dir,'_icoh.txt'],'w');
coh_fid=fopen([pair_dir,'/',pair_dir,'_icoh.txt'],'w');

for s=1:length(subjects)
    
    subject=subjects{s};
    subj_chan1=chan1_channels(s);
    subj_chan2=chan2_channels(s);
    
    channel_pair=[subj_chan1 subj_chan2];
    
    for d=1:length(drugs)
        
        drug=drugs{d};
        
        subject_dir=[subject,'_',drug];
        cd (subject_dir)
        
        pair_filename=sprintf('%s_ch%d_by_ch%d_cohy.mat',subject_dir,channel_pair);
        cohy_struct=load(pair_filename);
        cohy_norm=cohy_struct.cohy_norm;
        coh_norm=cohy_struct.coh_norm;
        no_pds=size(cohy_norm,1);
        
        pd_list_prefix=sprintf('%s_chan%d',subject_dir,channel_pair(1));
        pd_listname=sprintf('%s_epochs/%s_hours_master.list',pd_list_prefix,pd_list_prefix);
        pd_list=textread(pd_listname,'%s');
        pds=cell(no_pds,1);
        
        for p=1:no_pds
           
            pds{p}=pd_list{p};
            pds{p}=pds{p}(length(pd_list_prefix)+2:end-5);
            
            fprintf(drugs_fid,'%s\n',drug);
            fprintf(subjects_fid,'%s\n',subject);
            fprintf(hrs_fid,'%s\n',pds{p});
            fprintf(rcoh_fid,cohy_format,real(cohy_norm(p,:)));
            fprintf(icoh_fid,cohy_format,imag(cohy_norm(p,:)));
            fprintf(coh_fid,cohy_format,coh_norm(p,:));
            
        end
        
        figure(2*s-1)
        
        subplot(1,4,d)
        imagesc(imag(cohy_norm)')
        axis xy
        colorbar
        title(drug)
        xlabel('Hour Relative to Injection')
        set(gca,'XTick',1:floor(no_pds/3):no_pds,'XTickLabel',pds(1:floor(no_pds/3):no_pds),'YTick',1:floor(no_freqs/10):no_freqs,'YTickLabel',round(f(1:floor(no_freqs/10):no_freqs)))
        if d==1
            ylabel(sprintf('Imaginary Coherence for %s, %s by %s',subject,chan1_name,chan2_name))
        end
        
        figure(2*s)
        
        subplot(1,4,d)
        imagesc(real(cohy_norm)')
        axis xy
        colorbar
        title(drug)
        xlabel('Hour Relative to Injection')
        set(gca,'XTick',1:floor(no_pds/3):no_pds,'XTickLabel',pds(1:floor(no_pds/3):no_pds),'YTick',1:floor(no_freqs/10):no_freqs,'YTickLabel',round(f(1:floor(no_freqs/10):no_freqs)))
        if d==1
            ylabel(sprintf('Coherence for %s, %s by %s',subject,chan1_name,chan2_name))
        end
        
        cd (present_dir)
        
    end
    
    saveas(2*s-1,[pair_dir,'/',pair_dir,'_',subject,'_icoh'],'fig')
    saveas(2*s,[pair_dir,'/',pair_dir,'_',subject,'_rcoh'],'fig')
    
end