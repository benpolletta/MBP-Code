function nochange_colorbar(axis_handle)

original_position = get(axis_handle, 'Position');

colorbar

set(axis_handle, 'Position', original_position)