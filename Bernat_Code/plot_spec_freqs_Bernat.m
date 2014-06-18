function plot_spec_freqs_Bernat(bands)

%% Basic stuff.

load('f_bins.mat')

load('drugs.mat')

load('channels')
no_channels = length(channel_names);
channel_linestyles = {'-',':','--'};

state_labels={'W','NR','R'};
no_states = length(state_labels);
% state_titles={'Wake','NREM','REM'};
state_colors = {'b','g','r'};

% [hr_labels,~,long_hr_labels] = make_period_labels(2,8,'hrs');
[hr_labels,~,long_hr_labels] = make_period_labels(4,12,'4hrs');
no_hrs = length(hr_labels);

%% Bands stuff.

[r,c] = size(bands);

if ~(r==2 || c==2)
    
    display('Input variable "bands" must be n by 2.')
    
    return
    
elseif r==2 && c~=2
    
    bands = bands';
    
end

bands_name = '';

for b = 1:size(bands,1)
    
    bands_name = [bands_name,sprintf('%g-%g_',bands(b,1),bands(b,2))];
    
end

%% Loading MI parameters.

if isempty(dir(['All_',bands_name,'spec_params.mat']))
    
    All_spec_params = [];
    All_pct_params = [];
    All_zs_params = [];
    All_drugs = cell(0,1);
    All_4hrs = cell(0,1);
    All_states = cell(0,1);
    
    no_epochs = zeros(no_channels,1);
    
    for c = 1:no_channels
        
        channel_name = channel_names{c};
        
        name=sprintf('ALL_%s',channel_name);
        
        % Loading data.
        
        chan_drugs=text_read([name,'/',name,'_drugs.txt'],'%s');
        chan_fourhrs=text_read([name,'/',name,'_4hrs.txt'],'%s');
        chan_states=text_read([name,'/',name,'_states.txt'],'%s');
        load([name,'/',name,'_',bands_name,'spec_params.mat'])
        
        % Concatenating data.
        
        All_spec_params = [All_spec_params; spec_params];
        All_pct_params = [All_pct_params; spec_pct_params];
        All_zs_params = [All_zs_params; spec_zs_params];
        All_drugs = {All_drugs{:} chan_drugs{:}};
        All_4hrs = {All_4hrs{:} chan_fourhrs{:}};
        All_states = {All_states{:} chan_states{:}};
        
        no_epochs(c) = size(spec_params,1);
        
    end
    
    All_params = [All_spec_params All_pct_params All_zs_params];
    
    % Creating vector of channel names.
    
    All_channels = cell(1,sum(no_epochs));
    
    chan_ends = cumsum([0; no_epochs]);
    
    for c = 1:no_channels
        
        All_channels((chan_ends(c)+1):chan_ends(c+1)) = channel_names(c);
        
    end
    
    save(['All_',bands_name,'spec_params.mat'],'All_params','All_channels','All_drugs','All_4hrs','All_states')
    
else
    
    load(['All_',bands_name,'spec_params.mat'])
    
end

%% Creating bins.

norm_labels = {'spec','spec_pct','spec_zs'};
norm_titles = {'Spectral Power','Power Increase','z-Scored Power'};
no_norms = length(norm_labels);

no_bands = size(bands,1);

band_bins = cell(no_norms*2*no_bands,1);
band_labels = cell(no_norms*2*no_bands,1);
band_titles = cell(no_norms*2*no_bands,1);

for n = 1:no_norms % For each of the three normalizations (raw, pct. above baseline, z-scored).
    
    for b = 1:no_bands
        
        band_bins{(n-1)*2*no_bands+2*b-1} = linspace(min(All_params(:,(n-1)*2*no_bands+2*b-1)),max(All_params(:,(n-1)*2*no_bands+2*b-1)),50);
        
        f_bins_restricted = f_bins(f_bins >= bands(b,1) & f_bins <= bands(b,2));
        
        if length(f_bins_restricted)<50
            
            band_bins{(n-1)*2*no_bands+2*b} = f_bins_restricted;
            
        else
        
            band_bins{(n-1)*2*no_bands+2*b} = linspace(bands(b,1),bands(b,2),50);
        
        end
            
        band_labels{(n-1)*2*no_bands+2*b-1} = sprintf('%s_%g-%g_peak_val',norm_labels{n},bands(b,1),bands(b,2));
        
        band_labels{(n-1)*2*no_bands+2*b} = sprintf('%s_%g-%g_f_peak',norm_labels{n},bands(b,1),bands(b,2));
        
        band_titles{(n-1)*2*no_bands+2*b-1} = {'Peak Value,';norm_titles{n};sprintf('%g - %g Hz',bands(b,1),bands(b,2))};
        
        band_titles{(n-1)*2*no_bands+2*b} = {'Peak Freq.,';norm_titles{n};sprintf('%g - %g Hz',bands(b,1),bands(b,2))};
        
    end
    
end

hist_bins = band_bins; measure_labels = band_labels; measure_titles = band_titles;

no_measures = length(measure_labels)/no_norms;

%% Plotting 1-D Histograms, by both State and Channel.

for n = 1:no_norms % For each of the three normalizations (raw, pct. above baseline, z-scored).
    
    for m = 1:no_measures
        
        figure;
        
        for d = 1:no_drugs
            
            drug = drugs{d};
            
            for h = 1:no_hrs
                
                hr = hr_labels{h};
                
                subplot(no_drugs, no_hrs, (d-1)*no_hrs+h)
                
                handle = zeros(no_states*no_channels,1);
                
                sc_legend = cell(no_states*no_channels,1);
                
                index = 1;
                
                for s  = 1:no_states
                    
                    state = state_labels{s};
                    
                    for c = 1:no_channels
                        
                        channel = channel_names{c};
                        
                        indices = strcmp(All_drugs,drug) & strcmp(All_4hrs,hr) & strcmp(All_states,state) & strcmp(All_channels,channel);
                        
                        if sum(indices) > length(hist_bins{m})
                            
                            histogram = hist(All_params(indices, (n-1)*no_measures + m), hist_bins{(n-1)*no_measures + m});
                            
                        else
                            
                            histogram = nan(size(hist_bins{(n-1)*no_measures + m}'));
                            
                        end
                        
                        handle(index) = plot(hist_bins{(n-1)*no_measures+m}',histogram/sum(indices),[state_colors{s},channel_linestyles{c}],'LineWidth',1.5);
                        
                        sc_legend{index} = [state,', ',channel];
                        
                        index = index + 1;
                        
                        hold on
                        
                        clear indices
                        
                    end
                    
                end
                
                axis tight
                
                box off
                
                if d == 1
                    
                    title(long_hr_labels{h})
                    
                    if h == no_hrs
                        
                        legend(handle, sc_legend, 'Location', 'NorthEastOutside')
                        
                    end
                    
                elseif d == no_drugs
                    
                    xlabel(measure_titles{(n-1)*no_measures+m})
                    
                end
                
                if h == 1
                    
                    ylabel({drug;'Prop. Observed'})
                    
                end
                
            end
            
        end
        
        save_as_pdf(gcf,['All_hr_by_drug_',measure_labels{(n-1)*no_measures+m},'_hist'])
        
    end
    
end

%% Plotting 1D Histograms, by State and (separately) by Channel.

for n = 1:-1%no_norms % For each of the three normalizations (raw, pct. above baseline, z-scored).
    
    for m = 1:no_measures
        
        for d = 1:no_drugs
            
            drug = drugs{d};
            
            for h = 1:no_hrs
                
                hr = hr_labels{h};
                
                %% Plotting by State.
                
                figure(no_norms*no_measures + (n-1)*2*no_measures + 2*m-1) % First term for figures plotted above; second term for number of normalizations; third term for odd figures (by state).
                
                subplot(no_drugs, no_hrs, (d-1)*no_hrs+h)
                
                for s  = 1:no_states
                    
                    state = state_labels{s};
                    
                    indices = strcmp(All_drugs,drug) & strcmp(All_4hrs,hr) & strcmp(All_states,state);
                    
                    if sum(indices) > length(hist_bins{(n-1)*no_measures+m})
                        
                        histogram = hist(All_params(indices, (n-1)*no_measures + m),hist_bins{(n-1)*no_measures + m});
                        
                    else
                        
                        histogram = nan(size(hist_bins{(n-1)*no_measures + m}'));
                        
                    end
                    
                    plot(hist_bins{(n-1)*no_measures+m}',histogram/sum(indices),state_colors{s},'LineWidth',1.5);
                    
                    hold on
                    
                    clear indices
                    
                end
                
                
                axis tight
                
                box off
                
                if d == 1
                    
                    title(long_hr_labels{h})
                    
                    if h == no_hrs
                        
                        legend(state_labels, 'Location', 'NorthEastOutside')
                        
                    end
                    
                elseif d == no_drugs
                    
                    xlabel(measure_titles{(n-1)*no_measures + m})
                    
                end
                
                if h == 1
                    
                    ylabel({drug;'Prop. Observed'})
                    
                end
                
                %% Plotting by Channel.
                
                figure(no_norms*no_measures + (n-1)*2*no_measures + 2*m)
                
                subplot(no_drugs, no_hrs, (d-1)*no_hrs+h)
                
                for c = 1:no_channels
                    
                    channel = channel_names{c};
                    
                    indices = strcmp(All_drugs,drug) & strcmp(All_4hrs,hr) & strcmp(All_channels,channel);
                    
                    if sum(indices) > length(hist_bins{(n-1)*no_measures + m})
                        
                        histogram = hist(All_params(indices,(n-1)*no_measures + m), hist_bins{(n-1)*no_measures + m});
                        
                    else
                        
                        histogram = nan(size(hist_bins{(n-1)*no_measures + m}'));
                        
                    end
                    
                    plot(hist_bins{(n-1)*no_measures + m}', histogram/sum(indices), channel_linestyles{c},'LineWidth',1.5);
                    
                    hold on
                    
                    clear indices
                    
                end
                
                axis tight
                
                box off
                
                if d == 1
                    
                    title(long_hr_labels{h})
                    
                    if h == no_hrs
                        
                        legend(channel_names, 'Location', 'NorthEastOutside')
                        
                    end
                    
                elseif d == no_drugs
                    
                    xlabel(measure_titles{(n-1)*no_measures+m})
                    
                end
                
                if h == 1
                    
                    ylabel({drug;'Prop. Observed'})
                    
                end
                
            end
            
        end
        
        save_as_pdf(no_norms*no_measures + (n-1)*2*no_measures + 2*m-1,['All_hr_by_drug_by_state_',measure_labels{(n-1)*no_measures+m},'_hist'])
        
        save_as_pdf(no_norms*no_measures + (n-1)*2*no_measures + 2*m,['All_hr_by_drug_by_channel_',measure_labels{(n-1)*no_measures+m},'_hist'])
        
    end
    
end