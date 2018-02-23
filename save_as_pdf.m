function save_as_pdf(handle, title, varargin)

orientation_flag = 'landscape';

if length(varargin) > 0
   
    if strcmp(varargin{1}, 'orientation')
       
        orientation_flag = varargin{2};
        
    end
    
end

% try
    
% saveas(handle, [title,'.fig'])
    
% catch

% textobj = findobj('Type', 'text');
% set(textobj, 'FontSize', 8)

set(handle, 'PaperOrientation', orientation_flag, 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1])

print(handle, '-painters', '-dpdf', '-r600', [title,'.pdf'])