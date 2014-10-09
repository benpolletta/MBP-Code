function sMI_model = run_summed_MI_stats

measure = 'p0.99_IEzs';

chan_labels = {'Frontal', 'Occipital', 'CA1'};

no_channels = length(chan_labels);

suffixes = {'drugs', 'subjects', 'hr_periods', 'states'};

suffix_labels = {'drugs', 'subjects', 'hr_periods', 'states'};

no_suffixes = length(suffixes);

channels = {}; sMI = []; bands = {};

for s = 1:no_suffixes
    
    eval([suffix_labels{s}, ' = {};'])
    
end

for ch = 1:no_channels
    
    name=['ALL_', chan_labels{ch}];
    
    load([name,'/',name,'_',measure,'_summed.mat'])
    
    no_bands = length(band_labels);
    
    no_epochs = size(summed_MI, 1);
    
    channel = cell(no_bands*no_epochs, 1);
    
    channel(:) = chan_labels(ch); 
    
    channels = [channels(:); channel];
    
    chan_summed_MI = reshape(summed_MI, no_epochs*no_bands, 1);
    
    sMI = [sMI; chan_summed_MI];
    
    chan_bands = cell(no_epochs*no_bands, 1);
   
    for b = 1:no_bands
       
        chan_bands = cell(size(summed_MI, 1), 1);
        
        chan_bands((b - 1)*no_epochs + (1:no_epochs)) = band_labels(b);
        
    end
    
    bands = [bands(:); chan_bands];
    
    for s = 1:no_suffixes
        
        s_cell = cell(no_epochs*no_bands, 1);
        
        chan_s = text_read([name, '/', name, '_', measure, '_', suffixes{s}, '.txt'], '%s');
        
        for b = 1:no_bands
           
            s_cell((b - 1)*no_epochs + (1:no_epochs)) = chan_s;
            
        end
        
        eval([suffix_labels{s},' = [', suffix_labels{s}, '(:); s_cell];'])
        
    end
    
end

sMI = max(sMI, 0);

sMI_ds = dataset(sMI, channels, bands, drugs, subjects, hr_periods, states);

sMI_model = GeneralizedLinearModel.fit(sMI_ds, 'sMI ~ channels*bands*drugs*hr_periods*states', 'ResponseVar', 'sMI', 'Distribution', 'Gamma');

save('summed_MI_model.mat', sMI_model)