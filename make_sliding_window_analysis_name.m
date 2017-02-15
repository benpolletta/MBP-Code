function analysis_name = make_sliding_window_analysis_name(filename, fcn_name, window_time_cell, no_dims)

analysis_label = fcn_name;

for d = 1:no_dims

    analysis_label = [analysis_label, sprintf('_dim%d_window%g_step%g', d, window_time_cell{d})];
    
end

if ~isempty(filename), filename = [filename, '_']; end

analysis_name = [filename, analysis_label];

end