function label = make_label(stem, values, defaults, location_option)

if nargin < 4, location_option = []; end
if isempty(location_option), location_option = 'front'; end

if nargin < 3, defaults = []; end

if ndims(values) == ndims(defaults)

    if any(size(values) ~= size(defaults))

        default_flag = false;

    else

        if all_dimensions(@sum, values ~= defaults) == 0

            default_flag = true;

        else

            default_flag = false;

        end

    end

else

    default_flag = false;

end

label = '';

if ~default_flag

    for v = 1:length(values)

        label = [label, '_', num2str(values(v))];

    end

    if ~isempty(stem)

        if strcmp(location_option, 'front')

            label = ['_', stem, label];

        elseif strcmp(location_option, 'back')

            label = [label, '_', stem];

        end

    end

end

end
