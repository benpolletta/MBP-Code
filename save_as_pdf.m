function save_as_pdf(handle,title)

saveas(handle, [title,'.fig'])

% textobj = findobj('Type', 'text');
% set(textobj, 'FontSize', 8)

set(handle, 'PaperOrientation', 'landscape', 'PaperUnits', 'normalized', 'PaperPosition', [0 0 1 1])
print(handle, '-dpdf', [title,'.pdf'])