function analysis_name = make_sliding_window_analysis_name(filename, fcn_name, window_time_cell, no_dims, varargin)

analysis_label = fcn_name;

for d = 1:no_dims

    analysis_label = [analysis_label, sprintf('_dim%d_window%g_step%g', d, window_time_cell{d})];
    
end

if ~isempty(filename), filename = [filename, '_']; end

if nargin > 4

    varargin_label = make_varargin_label(varargin{:});
    
else
    
    varargin_label = '';
    
end

analysis_name = [filename, analysis_label, varargin_label];

end

function varargin_label = make_varargin_label(varargin)

number_argin = length(varargin);

varargin_label = sprintf('_nargin_%d', number_argin);

for a = 1:number_argin
    
    argstring = sprintf('_arg%d', a);
   
    if isempty(varargin{a})
        
        argstring = '';
        
    elseif isscalar(varargin{a})
        
        argstring = [argstring, '_', num2str(varargin{a})];
        
    elseif isvector(varargin{a})
        
        argstring = [argstring, '_', sprintf('%gto%g', min(varargin{a}), max(varargin{a}))];
        
    elseif ismatrix(varargin{a})
        
        arg_size = size(varargin{a});
        
        argstring = [argstring, '_', sprintf('mat%dx%d', arg_size)];
        
    elseif iscell(varargin{a})
        
        arg_size = size(varargin{a});
        
        argstring = [argstring, '_', sprintf('cell%dx%d', arg_size)];
        
    end
    
    varargin_label = [varargin_label, argstring];
    
end

end