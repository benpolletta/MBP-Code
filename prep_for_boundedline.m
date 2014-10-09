function bounds = prep_for_boundedline(varargin)

if nargin == 2
    
    bounds_low = cell2mat(varargin(1));
    bounds_high = cell2mat(varargin(2));
    
elseif nargin == 1
    
    bounds_low = cell2mat(varargin(1));
    bounds_high = bounds_low;
    
end

[rl, cl] = size(bounds_low);
[rh, ch] = size(bounds_high);

if rl ~= rh || cl ~= ch
    
    display('Lower and higher bounds must have same dimensions.')
    
end

bounds_low = reshape(bounds_low, [rl, 1, cl]);
bounds_high = reshape(bounds_high, [rh, 1, ch]);

bounds(:, 1, :) = bounds_low;
bounds(:, 2, :) = bounds_high;
    