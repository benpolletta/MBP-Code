function label = make_label(stem, values, defaults)

if nargin < 3, defaults = []; end

if ndims(values) == ndims(defaults)
    
    if any(size(values) ~= size(defaults))
        
        default_flag = false;
        
    else
        
        if all_dimensions(@sum, values ~= defaults) == 0
            
            default_flag = true;
            
        else
            
            default_flag = false;
            
        end
        
    end

else
    
    default_flag = false;
    
end

if default_flag
    
    label = '';
    
else
    
    label = ['_', stem];
    
    for v = 1:length(values)
        
        label = [label, '_', num2str(values(v))];
        
    end
    
end

end