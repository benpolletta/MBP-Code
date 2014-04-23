function plot_Freqs_Bernat

%% Basic stuff.

measure = 'p0.99_IEzs';

load('f_bins.mat')

load('AP_freqs.mat')

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

%% Loading MI parameters.

All_params = [];
All_drugs = cell(0,1);
All_hrs = cell(0,1);
All_4hrs = cell(0,1);
All_states = cell(0,1);

no_epochs = zeros(no_channels,1);

for c = 1:no_channels
    
    channel_name = channel_names{c};
    
    name=sprintf('ALL_%s',channel_name);
    
    % Loading data.
    
    chan_drugs=text_read([name,'/',name,'_',measure,'_drugs.txt'],'%s');
    chan_hrs=text_read([name,'/',name,'_',measure,'_hr_periods.txt'],'%s');
    chan_fourhrs=text_read([name,'/',name,'_',measure,'_4hr_periods.txt'],'%s');
    chan_states=text_read([name,'/',name,'_',measure,'_states.txt'],'%s');
    load([name,'/',name,'_',measure,'_freqs.mat'])
    
    % Concatenating data.
    
    All_params = [All_params; hr_params];
    All_drugs = {All_drugs{:} chan_drugs{:}};
    All_hrs = {All_hrs{:} chan_hrs{:}};
    All_4hrs = {All_4hrs{:} chan_fourhrs{:}};
    All_states = {All_states{:} chan_states{:}};
    
    no_epochs(c) = size(hr_params,1);
    
end

% Creating vector of channel names.

All_channels = cell(1,sum(no_epochs));

chan_ends = cumsum([0; no_epochs]);

for c = 1:no_channels
    
    All_channels((chan_ends(c)+1):chan_ends(c+1)) = channel_names(c);
    
end

%% Creating bins.

hr_bins{1} = linspace(min(All_params(:,1)),max(All_params(:,1)),100);
hr_bins{2} = phase_freqs;
hr_bins{3} = amp_freqs;

hr_param_labels = {'maxIE','pref_fp','pref_fa'};
hr_param_titles = {'Max. IE','Pref. f_p','Pref. f_a'};

% no_bands = size(bands,1);
%
% band_bins = cell(2*no_bands,1);
% band_labels = cell(2*no_bands,1);
% band_titles = cell(2*no_bands,1);
%
% for b = 1:no_bands
%
%     band_bins{2*b-1} = linspace(min(All_params(:,3+2*b-1)),max(All_params(:,3+2*b-1)),100);
%
%     band_bins{2*b} = f_bins(bands(b,1) <= f_bins & f_bins <= bands(b,2));
%
%     band_labels{2*b-1} = sprintf('%g-%g_pow',bands(b,1),bands(b,2));
%
%     band_labels{2*b-1} = sprintf('%g-%g_f_peak',bands(b,1),bands(b,2));
%
%     band_titles{2*b-1} = sprintf('%g - %g Hz Power',bands(b,1),bands(b,2));
%
%     band_titles{2*b-1} = sprintf('%g - %g Hz Peak Freq.',bands(b,1),bands(b,2));
%
% end
%
% hist_bins = {hr_bins{:}; band_bins{:}};
%
% measure_labels={hr_labels{:}; band_labels{:}};
%
% measure_titles={hr_titles{:}; band_titles{:}};

hist_bins = hr_bins; measure_labels = hr_param_labels; measure_titles = hr_param_titles;

no_measures=length(measure_labels);

%% Plotting 1-D Histograms, by both State and Channel.

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
                        
                        histogram = hist(All_params(indices,m),hist_bins{m});
                        
                    else
                        
                        histogram = nan(size(hist_bins{m}'));
                        
                    end
                    
                    handle(index) = plot(hist_bins{m}',histogram/sum(indices),[state_colors{s},channel_linestyles{c}]);
                    
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
                
                xlabel(measure_titles{m})
                
            end
            
            if h == 1
                
                ylabel({drug;'Proportion Observed'})
                
            end
            
        end
        
    end
    
    save_as_pdf(gcf,['All_hr_by_drug_',measure_labels{m},'_hist'])
    
end

%% Plotting 1D Histograms, by State and by Channel.

for m = 1:no_measures
    
    for d = 1:no_drugs
        
        drug = drugs{d};
        
        for h = 1:no_hrs
            
            hr = hr_labels{h};
            
            %% Plotting by State.
            
            figure(no_measures+2*m-1)
            
            subplot(no_drugs, no_hrs, (d-1)*no_hrs+h)
            
            for s  = 1:no_states
                
                state = state_labels{s};
                
                indices = strcmp(All_drugs,drug) & strcmp(All_4hrs,hr) & strcmp(All_states,state);
                
                if sum(indices) > length(hist_bins{m})
                    
                    histogram = hist(All_params(indices,m),hist_bins{m});
                    
                else
                    
                    histogram = nan(size(hist_bins{m}'));
                    
                end
                
                plot(hist_bins{m}',histogram/sum(indices),state_colors{s});
                
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
                
                xlabel(measure_titles{m})
                
            end
            
            if h == 1
                
                ylabel({drug;'Proportion Observed'})
                
            end
            
            %% Plotting by Channel.
            
            figure(no_measures+2*m)
            
            subplot(no_drugs, no_hrs, (d-1)*no_hrs+h)
            
            for c = 1:no_channels
                
                channel = channel_names{c};
                
                indices = strcmp(All_drugs,drug) & strcmp(All_4hrs,hr) & strcmp(All_channels,channel);
                
                if sum(indices) > length(hist_bins{m})
                    
                    histogram = hist(All_params(indices,m),hist_bins{m});
                    
                else
                    
                    histogram = nan(size(hist_bins{m}'));
                    
                end
                
                plot(hist_bins{m}',histogram/sum(indices),channel_linestyles{c});
                
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
                
                xlabel(measure_titles{m})
                
            end
            
            if h == 1
                
                ylabel({drug;'Proportion Observed'})
                
            end
            
        end
        
    end

    save_as_pdf(no_measures+2*m-1,['All_hr_by_drug_by_state_',measure_labels{m},'_hist']) 
    
    save_as_pdf(no_measures+2*m,['All_hr_by_drug_by_channel_',measure_labels{m},'_hist']) 
    
end