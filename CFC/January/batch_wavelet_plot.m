function batch_wavelet_plot(sampling_freq,bands,challenge_list,titles,row_labels,subplot_dims)

close('all')

challenge_list_name=char(challenge_list);

listnames=text_read(challenge_list,'%s%*[^\n]');
no_challenges=length(listnames);
challenge_list_name=challenge_list_name(1:end-5);

present_dir=pwd;

avg_phase_all = cell(1,no_challenges);
avg_amp_all = cell(1,no_challenges);
median_amp_all = cell(1,no_challenges);
std_amp_all = cell(1,no_challenges);

for j=1:no_challenges

    % challenge_row=ceil(j/subplot_dims(1));
    % challenge_col=mod(j,subplot_dims(2));
    % if challenge_col==0
    %     challenge_col=subplot_dims(2);
    % end
    
    listname=char(listnames(j));
    
    if isempty(dir(['AVG_',listname(1:end-5),'_AP.mat']))
        
        filenames=text_read(listname,'%s%*[^\n]');
        filenum=length(filenames);
        
        dirname=listname(1:end-5);
        
        filename=char(filenames(1));
        
        if isempty(dir([filename(1:end-4),'_HAP.mat']))

            data = load(filename);

            [~,~,A,P] = filter_wavelet_Jan(data,'sampling_freq',sampling_freq,'bands',bands,'filename',filename);

        else

            HAP = load([filename(1:end-4),'_HAP.mat']);
            A = HAP.A; P = HAP.P;

        end
            
        avg_amp = A/filenum;
        
        all_amp = nan(size(avg_amp,1),size(avg_amp,2),filenum);
        
        all_amp(:,:,1) = avg_amp;
        
        avg_phase = exp(sqrt(-1)*P)/filenum;
        
        parfor k=2:filenum
            
            filename=char(filenames(k));
            
            if isempty(dir([filename(1:end-4),'_HAP.mat']))
            
                data = load(filename);

                [~,~,A,P] = filter_wavelet_Jan(data,'sampling_freq',sampling_freq,'bands',bands,'filename',filename);

            else
               
                HAP = load([filename(1:end-4),'_HAP.mat']);
                A = HAP.A; P = HAP.P;
                
            end
            
            avg_amp = avg_amp + A/filenum;
            
            all_amp(:,:,k) = A;
            
            avg_phase = avg_phase + exp(sqrt(-1)*P)/filenum;
            
        end
        
        avg_amp_all{j} = avg_amp;
        avg_phase_all{j} = avg_phase;
        median_amp = median(all_amp,3);
        std_amp = std(all_amp,[],3);
        
        median_amp_all{j} = avg_amp;
        
        std_amp_all{j} = std_amp;
        
        avg_name=['AVG_',listname(1:end-5)];
        mkdir (avg_name)
        cd (avg_name)
        
        save(['AVG_',listname(1:end-5),'_AP.mat'],'bands','all_amp','avg_amp','avg_phase','median_amp','std_amp');
        
    else
        
        load(['AVG_',listname(1:end-5),'_AP.mat'])
        
    end
        
    figure;
    
    imagesc((1:size(avg_amp,1))/sampling_freq,bands,zscore(avg_amp)')
    
    axis xy
    
    title(['Mean Amp., ',listname(1:end-5)])
    
    save_as_pdf(gcf,['AVG_',listname(1:end-5),'_A'])
    
    figure;
    
    imagesc((1:size(avg_amp,1))/sampling_freq,bands,zscore(median_amp)')
    
    axis xy
    
    title(['Median Amp., ',listname(1:end-5)])
    
    save_as_pdf(gcf,['AVG_',listname(1:end-5),'_Amed'])
    
    figure;
    
    imagesc((1:size(avg_amp,1))/sampling_freq,bands,zscore(std_amp)')
    
    axis xy
    
    title(['Median Amp., ',listname(1:end-5)])
    
    save_as_pdf(gcf,['AVG_',listname(1:end-5),'_Astd'])
    
    figure;
    
    imagesc((1:size(avg_amp,1))/sampling_freq,bands,zscore(abs(avg_phase))')
    
    axis xy
    
    title(['Mean Phase, ',listname(1:end-5)])
    
    save_as_pdf(gcf,['AVG_',listname(1:end-5),'_P'])
    
    clear avg_amp avg_phase
    
    cd (present_dir)

end

if no_challenges>1
        
    save([challenge_list_name,'_avgAP.mat'],'bands','avg_amp_all','avg_phase_all')

    try
        
        figure;
        
        figure_replotter_labels([1:4:4*no_challenges],subplot_dims(1),subplot_dims(2),5,6,[],bands,titles,[],row_labels)
    
        saveas(gcf,[challenge_list_name,'_avgA.fig'])
        
        figure;
        
        figure_replotter_labels([2:4:4*no_challenges],subplot_dims(1),subplot_dims(2),5,6,[],bands,titles,[],row_labels)
    
        saveas(gcf,[challenge_list_name,'_avgAmed.fig'])
        
        figure;
        
        figure_replotter_labels([3:4:4*no_challenges],subplot_dims(1),subplot_dims(2),5,6,[],bands,titles,[],row_labels)
    
        saveas(gcf,[challenge_list_name,'_avgAstd.fig'])
        
        figure;
        
        figure_replotter_labels([4:4:4*no_challenges],subplot_dims(1),subplot_dims(2),5,6,[],bands,titles,[],row_labels)
    
        saveas(gcf,[challenge_list_name,'_avgP.fig'])
        
    catch error
        
        display(error.message)
    
    end
        
end

fclose('all');

cd (present_dir);