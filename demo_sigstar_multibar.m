figure

barvalues=rand(3,5); 
errorsL=zeros(3,5); 
errorsU=ones(3,5)*0.05; 

handles.bars=bar(barvalues); 

hold on 
numgroups=size(barvalues, 1); 
numbars=size(barvalues, 2);

for i=1:numbars
    x=get(get(handles.bars(i), 'children'), 'xdata');
    x=mean(x([1 3],:));
    pos_bars(i,:)=x;
    handles.errors(i)=errorbar(x,barvalues(:,i), errorsL(:,i), errorsU(:,i), 'k', 'linestyle', 'none', 'linewidth', 1);
end

handles.pos_bars=pos_bars; 
comp_wgroups={ [handles.pos_bars(1),handles.pos_bars(2)], ... 
[handles.pos_bars(1),handles.pos_bars(3)], ... 
[handles.pos_bars(1),handles.pos_bars(4)], ... 
[handles.pos_bars(2),handles.pos_bars(3)], ... 
[handles.pos_bars(2),handles.pos_bars(4)], ... 
[handles.pos_bars(3),handles.pos_bars(4)]}; 
sigstar(comp_wgroups)

comp_bgroups={ [handles.pos_bars(5),handles.pos_bars(6)], ... 
[handles.pos_bars(5),handles.pos_bars(7)], ... 
[handles.pos_bars(5),handles.pos_bars(8)]}; 
sigstar(comp_bgroups)