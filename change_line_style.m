function change_line_style(handle, t, plot_data, logical, varargin)

% Adds stars to a boundedline type plot. Logical is whether or not to add
% a star. Side vec is 0 for below & 1 for above. c_order is color of stars.

plot_spec = init_struct({'linewidth', 'linestyle', 'marker'}, {1, '-', 'none'}, varargin{:});

logical = +logical;

no_cols = size(plot_data, 2);

if size(logical, 2) == 1
    
    logical = repmat(logical, 1, no_cols);
    
end

for c = 1:no_cols
    
    if any(logical(:, c))
        
        column_logical = logical(:, c);
        
        column_logical(column_logical == 0) = nan;
        
        hold on
        
        plot(t, plot_data(:, c).*column_logical, 'Color', get(handle(c), 'Color'),...
            'LineWidth', plot_spec.linewidth, 'LineStyle', plot_spec.linestyle,...
            'Marker', plot_spec.marker)
        
    end
    
end


