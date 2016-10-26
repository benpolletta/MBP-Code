y = linspace(0, 2*pi, 100)'; 
x = [sin(y) sin(y)*100]; % cos(y)+0.5 sin(y)*100]; 
e = permute(ones(100,1)* [1 2 3], [1 3 2]); 
iax = [1 2]; % 1 2]; % axis to use for each line

ax(1) = axes('box', 'off', 'xaxisloc', 'bottom'); 
ax(2) = axes('position', get(ax(1), 'position'), 'color', 'none', 'ytick', [], 'xaxisloc', 'top');
% , ... 
% 'color', 'none', ... 
% 'ytick', '', ... 
% 'xaxisloc', 'top'); 
linkaxes(ax, 'y');

color_order = [1 0 0; 0 .75 0; 0 0 1];

for ii = 1:size(x,2)
    [hl(ii), hp(ii)] = boundedline(x(:,ii), y, e(:,:,ii), ...
        ax(iax(ii)), 'cmap', color_order(ii, :),... % 'cmap', ax(1).ColorOrder(ii,:), ...
        'orientation', 'horiz'); % , 'alpha');
end

axis(ax(2), 'tight'), axis(ax(1), 'tight')
ylim(ax(1), [0 2*pi])
% ax(1).YLim = [0 2*pi];