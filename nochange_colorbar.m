function h = nochange_colorbar(axis_handle)

original_position = get(axis_handle, 'Position');

h = colorbar('peer', axis_handle);

set(axis_handle, 'Position', original_position)