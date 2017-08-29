function sync_axes(axis_list, axes_sunc)

if nargin < 2, axes_sunc = []; end

if isempty(axes_sunc), axes_sunc = ''; end

for a = 1:length(axis_list)
   
    axis_lims(a, :, 1) = get(axis_list(a), 'Xlim');
    
    axis_lims(a, :, 2) = get(axis_list(a), 'Ylim');
    
    axis_lims(a, :, 3) = get(axis_list(a), 'Clim');
    
end

for d = 1:3
    
    axis_extrema(d, 1) = min(axis_lims(:, 1, d));
    
    axis_extrema(d, 2) = max(axis_lims(:, 2, d));
    
end

for a = 1:length(axis_list)
    
    switch axes_sunc
        
        case 'x'
            
            set(axis_list(a), 'Xlim', axis_extrema(1, :))
            
        case 'y'
            
            set(axis_list(a), 'Ylim', axis_extrema(2, :))
            
        case 'z'
            
            set(axis_list(a), 'Clim', axis_extrema(3, :))
            
        case ''
            
            set(axis_list(a), 'Xlim', axis_extrema(1, :), 'Ylim', axis_extrema(2, :), 'Clim', axis_extrema(3, :))
    
    end
    
end