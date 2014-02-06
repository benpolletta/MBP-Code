function [maxMI]=getmaxMI

[FILENAME, PATHNAME] = uigetfile({'*.fig'}, 'Select the Matlab figure.');

open([PATHNAME,FILENAME]);

D = get(gca, 'Children');
MI = get(D, 'CData');

maxMI=max(max(MI));

colorbar('YTick',[0 maxMI],'YTickLabel',[0 maxMI])