function ls = log_space(first, last, base, no_divisions)

if isempty(base)
    
    base = exp(1);
    
end

powers = linspace(log(first)/log(base), log(last)/log(base), no_divisions);

ls = base.^powers;