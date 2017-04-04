function save_all_figs(name)

open_figures = findall(0, 'Type', 'figure');

if ~isempty(open_figures)
    
    if isstruct(open_figures)
        open_figures = [open_figures(:).Number];
    end
    
    for f = 1:length(open_figures)
        
        save_as_pdf(f, [name, '_', num2str(f)])
        
    end
    
end

end