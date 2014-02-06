function [epochs,MI_stats_all]=collect_MI_null_stats(prefix,suffix)

front_skip=length(char(prefix));
end_skip=length(char(suffix));

[listname,listpath]=uigetfile('*list','Choose list of data files.');

stats_labels={'pt_cutoffs','z_means','z_stds','lz_means','lz_stds'};
stats_titles={'Threshold Value of Shuffled MI';'Mean Shuffled MI';'S.D. Shuffled MI';'Mean Log Shuffled MI';'S.D. Log Shuffled MI'};

for i=1:5
    
    fid_vec(i)=fopen([listname(1:end-5),'_',stats_labels{i},'.txt'],'w');
    fprintf(fid_vec(i),'%s\t','epoch');

end

band_labels={'hg';'lg';'ab';'t'};

line_format='%d\t'; index=0;

for l=1:3
    for m=l+1:4
           
        index=index+1;
        
        band_pair_labels{index}=[band_labels{m},' on ',band_labels{l}];
        
        for n=1:5
            fprintf(fid_vec(n),'%s\t',[band_labels{m},'_on_',band_labels{l}]);
        end
        
        line_format=[line_format,'%f\t'];
        
    end
end

for l=1:5
    fprintf(fid_vec(l),'%s\n','');
end

line_format=[line_format(1:end-1),'n'];

filenames=textread([listpath,listname],'%s');
filenum=length(filenames);

epochs=zeros(filenum,1);
MI_stats_all=zeros(6,filenum,3);

for i=1:filenum
    
    filename=char(filenames(i));
    filename=filename(1:end-4);
    epochs(i)=str2num(filename(front_skip+1:end-end_skip));
    
    present_dir=pwd;
    
    MI_dirname=[filename,'_inv_entropy'];
    
    cd (MI_dirname)
    
    for j=1:5
        
        MI_stats=load([filename,'_',stats_labels{j},'.txt']);
        MI_stats=MI_stats(2:end,2:end);
        MI_stats_vec=[];
        
        for l=1:3

            for m=l+1:4

                MI_stats_vec=[MI_stats_vec MI_stats(l,m)];

            end

        end
            
        MI_stats_all(:,i,j)=MI_stats_vec';

        fprintf(fid_vec(j),line_format,[epochs(i) MI_stats_vec]);

    end
    
    cd (present_dir)
    
end

fclose('all')

for i=1:5
    
    figure()
    
    plot(epochs,MI_stats_all(:,:,i)','o')
    legend(band_pair_labels)
    title([stats_titles{i},' by Epoch Number for ',listname])
    xlabel('Epoch')
    ylabel(stats_titles{i})
    saveas(gcf,[listname(1:end-5),'_',stats_labels{i},'.fig']);
    
    figure()
    
    boxplot(MI_stats_all(:,:,i)')
    title([stats_titles{i},' for ',listname])
    xlabel('Band Pair')
    ylabel(stats_titles{i})
    set(gca,'XTickLabel',band_pair_labels)
    saveas(gcf,[listname(1:end-5),'_',stats_labels{i},'_boxplot.fig']);
    
end

for i=1:2
    
    figure()
    h(1:6)=plot(MI_stats_all(:,:,2*i)');
    hold on
    plot(MI_stats_all(:,:,2*i)'+MI_stats_all(:,:,2*i+1)','--')
    plot(MI_stats_all(:,:,2*i)'-MI_stats_all(:,:,2*i+1)','--')
    legend(band_pair_labels)
    title([stats_titles{2*i},' \pm S.D. by Epoch for ',listname])
    xlabel('Epoch')
    ylabel([stats_titles{2*i},' \pm S.D.'])
    saveas(gcf,[listname(1:end-5),'_',stats_labels{2*i},'_w_sd.fig'])
    
end