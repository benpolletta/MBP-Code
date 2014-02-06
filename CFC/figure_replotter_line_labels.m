function [X_all,Y_all]=figure_replotter_line_labels(datalength,numbers,rows,cols,labels)

no_figs=length(numbers);

X_all=nan(datalength,rows*cols);
Y_all=nan(datalength,rows*cols);

for i=1:no_figs
    
    figure(numbers(i))
    axxes=findall(gcf,'Type','axes');
    Chilluns=get(axxes(end),'Children');
    X=cell2mat(get(Chilluns,'XData'));
    Y=cell2mat(get(Chilluns,'YData'));
    
    X_all(1:length(X),i)=X(1,:)';
    Y_all(1:length(Y),i)=Y(1,:)';
    
end
    
max_X=max(max(X_all));
min_X=min(min(X_all));
max_Y=max(max(Y_all));
min_Y=min(min(Y_all));

figure()

for i=1:no_figs
    
    subplot(rows,cols,i)
    semilogy(X_all(:,i),Y_all(:,i))
    xlim([min_X max_X])
    ylim([min_Y max_Y])
    title(char(labels(i)))
    
    set(gca,'XTick',1:5:x_dim+1,'XTickLabel',x_ticks(1:5:end))
    set(gca,'YTick',1:2:y_dim+1,'YTickLabel',y_ticks(1:2:end))
        
    if row==1
        if iscell(titles{col})
            title(titles{col})
        else
            title(cellstr(titles{col}))
        end
    elseif row==rows
        if iscell(x_labels{col})
            xlabel(x_labels{col})
        else
            xlabel(cellstr(x_labels{col}))
        end
    end
    
    if col==1
        if iscell(y_labels{row})
            ylabel([y_labels{row};'Amp.-Giving Freq. (Hz)'])
        else
            ylabel([cellstr(y_labels{row});'Amp.-Giving Freq. (Hz)'])
        end
    elseif col==cols
        colorbar
    end
    
end
    
    