load('drugs')
load('subjects')


for d = 1:length(drugs)
    
    for s = 1:length(subjects)
   
        for c = 1:7
            
            try
                
                wavelet_mouse_eeg_collect_IE_thresh_by_state_Bernat(subjects{s},drugs{d},c,0.99)
                
            end
            
        end
        
    end
    
end