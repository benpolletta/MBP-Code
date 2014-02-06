function wavelet_mouse_eeg_threshold(cutoff_prompt,challenge_list,challenge_descriptor,challenge_labels,subplot_dims)

close('all')

challenge_list_name=char(challenge_list);
challenge_descriptor=char(challenge_descriptor);

% if nargin<5
%     for i=1:length(challenge_params)
%         challenge_labels{i}=num2str(challenge_params(i));
%     end
% end

listnames=textread(challenge_list_name,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=challenge_list_name(1:end-5);

thresh_labels={'pt','zt','lt'};
thresh_titles={'Empirical p-Value Thresholded','Standard Normal Thresholded','Lognormal Thresholded'};

bands_lo=[4:.25:12]';
bands_hi=[20:5:180]';
bincenters=-.95:.1:.95;

nofits=length(thresh_titles);
noamps=length(bands_lo);
nophases=length(bands_hi);
nobins=length(bincenters);

present_dir=pwd;

for j=1:no_challenges
    
    for k=1:nofits

        if length(challenge_labels)==no_challenges
            
            MI_titles{k,j}={[challenge_descriptor,' ',challenge_labels{j}];[thresh_titles{k},' MI'];'File Shuffled'};
            canolty_titles{k,j}={[challenge_descriptor,' ',challenge_labels{j}];[thresh_titles{k},' Canolty MI'];'File Shuffled'};
            PLV_titles{k,j}={[challenge_descriptor,' ',challenge_labels{j}];[thresh_titles{k},' PLV'];'File Shuffled'};
            
        elseif length(challenge_labels)==sum(subplot_dims)
            
            col_index=mod(j,subplot_dims(2));
            if col_index==0
                col_index=subplot_dims(2);
            end
            row_index=ceil(j/subplot_dims(2));
            
            MI_titles{k,j}={[challenge_descriptor,' ',challenge_labels{subplot_dims(2)+row_index},' ',challenge_labels{col_index}];[thresh_titles{k},' MI'];'File Shuffled'};
            canolty_titles{k,j}={[challenge_descriptor,' ',challenge_labels{subplot_dims(2)+row_index},' ',challenge_labels{col_index}];[thresh_titles{k},' Canolty MI'];'File Shuffled'};
            PLV_titles{k,j}={[challenge_descriptor,' ',challenge_labels{subplot_dims(2)+row_index},' ',challenge_labels{col_index}];[thresh_titles{k},' PLV'];'File Shuffled'};
                        
        end
    
    end

    listname=char(listnames(j));

    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    listname=listname(1:end-5);
    cd (listname)
    canolty_dir=[listname,'_canolty'];
    PLV_dir=[listname,'_PLV'];
    
    if ~isempty(cutoff_prompt) && ~isempty(dir(cutoff_prompt))
        cutoff_dir=dir(cutoff_prompt);
        cutoff_dir=cutoff_dir.name;
        cutoff_file=[cutoff_dir,'.mat'];
        cutoff_dir=[cutoff_dir,'/'];
    else
        [cutoff_file,cutoff_dir]=uigetfile('*.mat','Choose file containing stats for thresholding.');
    end
        
    stats_struct=load([cutoff_dir,cutoff_file]);
    MI_stats=stats_struct.MI_stats;
    canolty_stats=stats_struct.canolty_stats;
    PLV_stats=stats_struct.PLV_stats;
    
    dirname=['THRESH_',cutoff_file(7:end-4)];
    mkdir (dirname)
    
    avg_MI_thresh=zeros(noamps,nophases,3);
    avg_canolty_thresh=zeros(noamps,nophases,3);
    avg_PLV_thresh=zeros(noamps,nophases,3);
    
    parfor k=1:filenum

        filename=char(filenames(k));
        filename=filename(1:end-4);
        MI_filename=[filename,'_IE.mat'];
        canolty_filename=[filename,'_canolty_MI.mat'];
        PLV_filename=[filename,'_PLV.mat'];
        
        MI=load(MI_filename,'MI');
        MI=MI.MI;
        
        MI_thresh=threshold_saver(MI,MI_stats,MI_filename(1:end-4),dirname);
        
        avg_MI_thresh=avg_MI_thresh+MI_thresh;
        
        canolty_MI=load([canolty_dir,'/',canolty_filename],'MI');
        canolty_MI=canolty_MI.MI;
        
        canolty_thresh=threshold_saver(canolty_MI,canolty_stats,canolty_filename(1:end-4),dirname);
        
        avg_canolty_thresh=avg_canolty_thresh+canolty_thresh;
        
        PLV_MI=load([PLV_dir,'/',PLV_filename],'MI');
        PLV_MI=PLV_MI.MI;
        
        PLV_thresh=threshold_saver(PLV_MI,PLV_stats,PLV_filename(1:end-4),dirname);
        
        avg_PLV_thresh=avg_PLV_thresh+PLV_thresh;
        
    end
   
    avg_MI_thresh=avg_MI_thresh/filenum;
    avg_canolty_thresh=avg_canolty_thresh/filenum;
    avg_PLV_thresh=avg_PLV_thresh/filenum;
    
    avg_name=['AVG_',dirname];
    mkdir ([present_dir,'/',avg_name])
    cd ([present_dir,'/',avg_name])
    
    save([avg_name,'.mat'],'bands_lo','bands_hi','avg_MI_thresh','avg_canolty_thresh','avg_PLV_thresh');
    
    for k=1:nofits
        
        MI_plotter_Jan(avg_MI_thresh(:,:,k),[dirname,'_',thresh_labels{k}],bands_hi,bands_lo,MI_titles{k,j},'Hz');
        MI_plotter_Jan(avg_canolty_thresh(:,:,k),[dirname,'_canolty_',thresh_labels{k}],bands_hi,bands_lo,canolty_titles{k,j},'Hz');
        MI_plotter_Jan(avg_PLV_thresh(:,:,k),[dirname,'_PLV_',thresh_labels{k}],bands_hi,bands_lo,PLV_titles{k,j},'Hz');
    
    end
    
    clear avg_MI_thresh avg_canolty_thresh avg_PLV_thresh
   
    cd (present_dir)

end

if no_challenges>1
    
    for k=1:nofits
    
        figure_replotter([1:3*nofits:3*nofits*no_challenges],subplot_dims(1),subplot_dims(2),bands_lo,bands_hi,MI_titles(k,:));
    
        saveas(gcf,[challenge_list_name,'_',char(thresh_labels(k)),'_avgMI_thresh.fig'])
    
        figure_replotter([2:3*nofits:3*nofits*no_challenges],subplot_dims(1),subplot_dims(2),bands_lo,bands_hi,canolty_titles(k,:));
        
        saveas(gcf,[challenge_list_name,'_',char(thresh_labels(k)),'_avgcanMI_thresh.fig'])
        
        figure_replotter([3:3*nofits:3*nofits*no_challenges],subplot_dims(1),subplot_dims(2),bands_lo,bands_hi,PLV_titles(k,:));
        
        saveas(gcf,[challenge_list_name,'_',char(thresh_labels(k)),'_avgPLV_thresh.fig'])
        
    end
    
end