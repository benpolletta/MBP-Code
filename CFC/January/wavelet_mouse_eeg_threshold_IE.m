function wavelet_mouse_eeg_threshold_IE(cutoff_prompt,challenge_list,challenge_descriptor,challenge_labels,subplot_dims)

% Thresholds data - as listed in (list of lists) challenge_list - by stats,
% given by cutoff_prompt, or searched for in the directory containing the
% data. challenge_descriptor, challenge_labels, and subplot_dims are all
% degenerate variables at one time used for plotting.

close('all')

challenge_list_name=char(challenge_list);
challenge_descriptor=char(challenge_descriptor);

if nargin<5
    for i=1:length(challenge_params)
        challenge_labels{i}=num2str(challenge_params(i));
    end
end

% Getting lists contained in list of lists.
listnames=textread(challenge_list_name,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=challenge_list_name(1:end-5);

% Labels and titles for different thresholding methods.
thresh_labels={'pt','zt','lt','zs','lzs'};
thresh_titles={'Empirical p-Value Thresholded','Normal Thresholded','Lognormal Thresholded','Normal z-Scored','Lognormal z-Scored'};

% Bands for PAC analysis.
bands_lo=[1:.25:30]';
bands_hi=[20:5:250]';
bincenters=-.95:.1:.95;

nofits=length(thresh_titles);
noamps=length(bands_lo);
nophases=length(bands_hi);

present_dir=pwd;

for j=1:no_challenges
    
    % Making titles for plots.
    
    for k=1:nofits

        if length(challenge_labels)>=no_challenges
            
            MI_titles{k,j}={[challenge_descriptor,' ',challenge_labels{j}];[thresh_titles{k},' IE'];'File Shuffled'};
            
        elseif length(challenge_labels)==sum(subplot_dims)
            
            col_index=mod(j,subplot_dims(2));
            if col_index==0
                col_index=subplot_dims(2);
            end
            row_index=ceil(j/subplot_dims(2));
            
            MI_titles{k,j}={[challenge_descriptor,' ',challenge_labels{subplot_dims(2)+row_index},' ',challenge_labels{col_index}];[thresh_titles{k},' IE'];'File Shuffled'};
                        
        else
            
            MI_titles{k,j}='';
            
        end
    
    end

    listname=char(listnames(j));

    filenames=textread(listname,'%s%*[^\n]');
    filenum=length(filenames);
    
    listname=listname(1:end-5);
    if isdir(listname)
        cd (listname)
        cd_flag=1;
    else
        cd_flag=0;
    end
    
    listdir=pwd;
    
    % Going through lots of trouble to find the file containing the
    % surrogate statistics, in multiple different ways.
    
    cutoff_dir=[];
    
    % If a prompt (part of the filename of the file containing the stats)
    % is given.
    if ~isempty(cutoff_prompt)
        if ischar(cutoff_prompt) && ~isempty(dir(cutoff_prompt))
            cutoff_dir=dir(cutoff_prompt);
            if length(cutoff_dir)~=1
                cutoff_dir=uigetdir(cutoff_prompt,['Choose directory containing stats for thresholding ',listname,'.']);
            else
                cutoff_dir=cutoff_dir.name;
            end
        elseif isfloat(cutoff_prompt) && ~isempty(dir(['STATS_FILE_SHUFFLE_',listname,'_',num2str(cutoff_prompt),'_*']))
                cutoff_dir=dir(['STATS_FILE_SHUFFLE_',listname,'_',num2str(cutoff_prompt),'_*']);
                cutoff_dir=cutoff_dir.name;
        else
            display({'Unable to find STATS* directory using cutoff_prompt.';'cutoff_prompt must be either a string or a number (the number of shuffles).'})
        end
    end
    
    % If no prompt is given.
    if isempty(cutoff_dir)
        if ~isempty(dir(['STATS_FILE_SHUFFLE_',listname,'_*']))
            cutoff_dir=dir(['STATS_FILE_SHUFFLE_',listname,'_*']);
            if length(cutoff_dir)~=1
                cutoff_dir=uigetdir(['STATS_FILE_SHUFFLE_',listname,'_*'],['Choose directory containing stats for thresholding ',listname,'.']);
            else
                cutoff_dir=cutoff_dir.name;
            end
        else
            cutoff_dir=uigetdir('*shufs',['Choose file containing stats for thresholding ',listname,'.']);
        end
    end
    
    % File containing the cutoffs.
    cutoff_file=dir([cutoff_dir,'/',cutoff_dir,'*IE.mat']);
    cutoff_dir=[cutoff_dir,'/'];
    
    % Creating directory to save thresholded data.
    dirname=['THRESH_',cutoff_dir(7:end)];
    mkdir (dirname)
    
    % Creating directory to save averaged data.
    avg_dirname=['AVG_',dirname];
    mkdir (avg_dirname)
    
    for c=1:length(cutoff_file)
    
        % Getting cutoffs.
        cutoff_name=cutoff_file(c).name;
        stats_struct=load([cutoff_dir,cutoff_name]);
        MI_stats=stats_struct.MI_stats;
        
        cutoff_suffix=cutoff_name(length(cutoff_dir):end-4);
        
        avg_MI_thresh=zeros(nophases,noamps,nofits); % Creating file to store average thresholded data.
        
        parfor k=1:filenum % Doing the thresholding, in parallel.
            
            filename=char(filenames(k));
            filename=filename(1:end-4);
            MI_filename=[filename,'_IE.mat'];
            
            MI=load(MI_filename,'MI'); % Loading raw data.
            MI=MI.MI;
            
            MI_thresh=threshold_saver(MI,MI_stats,[filename,cutoff_suffix],dirname); % Doing the thresholding and saving.
            
            avg_MI_thresh=avg_MI_thresh+MI_thresh; % Adding results to average.
            
        end
        
        avg_MI_thresh=avg_MI_thresh/filenum;
        
        cd (avg_dirname)
        
        save(['AVG_',cutoff_name(7:end)],'bands_lo','bands_hi','avg_MI_thresh');
        
        for k=1:nofits
            
            MI_plotter_Jan(avg_MI_thresh(:,:,k),['AVG_',cutoff_name(7:end-4),'_',thresh_labels{k}],bands_hi,bands_lo,MI_titles{k,j},'Hz');
            
            close('all')
            
        end
        
%         close('all')
        
        clear avg_MI_thresh
        
        cd (listdir)
        
    end
   
    cd (present_dir)

end

try
    
    if no_challenges>1
        
        for k=1:nofits
            
            figure_replotter([1:nofits:nofits*no_challenges],subplot_dims(1),subplot_dims(2),bands_lo,bands_hi,MI_titles(k,:));
            
            saveas(gcf,[challenge_list_name,'_',char(thresh_labels(k)),'_avgMI_thresh.fig'])
            
        end
        
    end
    
end