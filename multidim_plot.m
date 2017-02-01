function multidim_plot(plot_fcn_handles, preprocessing_fcn_handles, data, dims_plotted, dims_not_plotted, filename)

data_size = size(data);

no_x_ticks = 5;

x_ticks = 1:floor(no_windows/no_x_ticks):no_windows;

no_plots = prod(data_size(dims_not_plotted));

data_plot = reshape(sw, [data_size(dims_plotted), no_plots]);

[figure_indices, subplot_indices, no_rows, no_cols] = linear_figure_indices(data_size(2:(end - 1)), [], []);

for d = 1:length(dims_plotted)
    
    plot_indices{d} = {':'};
    
end

for p = 1:no_plots
    
    figure(figure_indices(p))
    
    subplot(no_rows, no_cols, subplot_indices(p))
    
    imagesc(abs(data_plot(plot_indices{:}, p)))
    
    axis xy
    
    set(gca, 'XTick', x_ticks - .5, 'XTickLabel', round(window_time(x_ticks)))
    
    figure(max(figure_indices) + figure_indices(p))
    
    subplot(no_rows, no_cols, subplot_indices(p))
    
    imagesc(nanzscore(data_plot(plot_indices{:}, p)')')
    
    axis xy
    
    set(gca, 'XTick', x_ticks - .5, 'XTickLabel', round(window_time(x_ticks)))
    
end

for f = 1:max(figure_indices)
    
    save_as_pdf(f, [filename, '_', num2str(f)])
    
end

end


function [fig_indices, subplot_indices, no_rows, no_cols] = linear_figure_indices(size_vec, max_row_index, max_col_index)

if isempty(max_row_index), max_row_index = 10; end

if isempty(max_col_index), max_col_index = 10; end

if length(size_vec) > 1
    
    if size_vec(1) <= max_row_index && size_vec(2) <= max_col_index
        
        no_rows = size_vec(1);
        
        no_cols = size_vec(2);
        
        fig_start_index = 3;
        
    elseif size_vec(1) <= max_row_index*max_col_index
        
        [no_rows, no_cols] = subplot_size(size_vec(1));
        
        fig_start_index = 2;
        
    else
        
        no_rows = max_row_index;
        
        no_cols = max_col_index;
        
        size_vec(1) = ceil(size_vec(1)/(max_row_index*max_col_index));
        
        fig_start_index = 1;
        
    end
    
elseif size_vec(1) <= max_row_index*max_col_index
    
    [no_rows, no_cols] = subplot_size(size_vec(1));
    
    fig_start_index = 2;
    
else
    
    no_rows = max_row_index;
    
    no_cols = max_col_index;
    
    size_vec(1) = ceil(size_vec(1)/(max_row_index*max_col_index));
    
    fig_start_index = 1;
    
end

% fig_start_index = min(fig_start_index, length(size));

no_figures = prod(size_vec(fig_start_index:end));

figure_subplot_indices = linear_subplot_indices(no_rows, no_cols);

subplot_indices = repmat(figure_subplot_indices, 1, no_figures);

subplot_indices = reshape(subplot_indices, no_rows*no_cols*no_figures, 1);

fig_indices = cumsum(ones(no_rows*no_cols, no_figures), 2);

fig_indices = reshape(fig_indices, no_rows*no_cols*no_figures, 1);

end


function subplot_indices = linear_subplot_indices(no_rows, no_cols)

subplot_indices = reshape(1:(no_rows*no_cols), no_cols, no_rows)';

subplot_indices = reshape(subplot_indices, no_rows*no_cols, 1);

end