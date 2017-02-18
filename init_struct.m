function is = init_struct(keys, defaults, varargin)

% init_struct is a function that takes in key-value pairs, a list of keys,
% and a list of corresponding defaults, and returns a struct containing
% fields named by the keys.

if length(defaults) ~= length(keys)
    
    display(sprintf(['The first two arguments of init_struct must be matched 1-D cell arrays\n',...
        'containing keys and their corresponding default values.']))
    
end

is = struct();

for k = 1:length(keys)
    
    is.(keys{k}) = defaults{k};
    
end

if nargin > 2
    
    if mod(nargin, 2)
        
        display(sprintf(['The first two arguments of init_struct must be matched 1-D cell arrays\n',...
            'containing keys and their corresponding default values.',...
            'Following the first two arguments, the arguments of init_struct must be\n',...
            'key-value pairs giving non-default parameter values.']));
        
    end
    
    for a = 1:(floor(nargin/2) - 1)
        
        % is.(varargin{2*a - 1}) = varargin{2*a};
        
        if any(strcmp(varargin{2*a - 1}, keys))
            
            display(sprintf('Replacing default %s.', varargin{2*a - 1}))
        
            is.(keys{strcmp(varargin{2*a - 1}, keys)}) = varargin{2*a};
        
        else
        
            is.(varargin{2*a - 1}) = varargin{2*a};
        
        end
        
    end
    
end