function [max_amp, handle] = plot_mat_1axis(mat,t,label_struct,max_amp,hF,linecolor)

if nargin<2 || isempty(t)
    t = linspace(0,1,size(mat,2));
    label_struct = struct('title','Modes','ylabel','Number','xlabel','Time','yticklabel',1:size(mat,1));
elseif nargin<3 || isempty(label_struct)
    label_struct = struct('title','Modes','ylabel','Number','xlabel','Time','yticklabel',1:size(mat,1));
end
if nargin < 4
    max_amp = [];
end
if nargin < 5
    hF = [];
end
if nargin < 6
    linecolor = 'k';
end

M = size(mat,1);

if abs(t-1)<=eps
    t = 1:size(mat,2);
end

if isempty(max_amp)
    max_amp=max(max(mat')-min(mat'));
end

if isempty(hF)
    figure;
else
    hA = findobj(hF, 'Type', 'axes');
    set(hA,'NextPlot', 'add');
end
hold on;
title(label_struct.title);
xlabel(label_struct.xlabel)
ylabel(label_struct.ylabel)

for i=1:M
    handle = plot(t,mat(i,:)+(i-1/2)*max_amp, 'Color', linecolor);
    hold on;
end

set(gca,'YTick',([1:M]-1/2)*max_amp,'YTickLabel',label_struct.yticklabel)
xlim([min(t) max(t)])
ylim([-max_amp/2 (M+1/2)*max_amp])

end