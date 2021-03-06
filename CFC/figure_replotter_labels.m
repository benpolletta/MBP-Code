function [max_data_all,data_all]=figure_replotter_labels(numbers,rows,cols,clims,x_tick_no,y_tick_no,x_tick_labels,y_tick_labels,titles,x_labels,y_labels)

% 'labels' can contain either a title for each figure to be replotted, in
% which case it has length rows*cols, or it can contain cols labels for the
% columns, followed by rows labels for the rows.

x_dim=length(x_tick_labels);
x_tick_selected=1:floor(x_dim/x_tick_no):x_dim;
y_dim=length(y_tick_labels);
y_tick_selected=1:floor(y_dim/y_tick_no):y_dim;

data_all=nan(y_dim,x_dim,rows*cols);
max_data_all = nan(rows,cols);
min_data_all = nan(rows,cols);

for i=1:length(numbers)
    
    figure(numbers(i))
    axxes=findall(gcf,'Type','axes');
    Chilluns=get(axxes(end),'Children');
    MI=get(Chilluns,'CData');
    
    row = ceil(i/cols);
    col = mod(i,cols)+1;
    if col==0
        col=cols;
    end
    
    % if numbers(i)~=4 & numbers(i)~=7 & numbers(i)~=8
    % MI=MI(1:end-1,1:end-1);
    % end
    
    [na,np]=size(MI);
    
    data_all(1:na,1:np,i)=MI;
    max_data_all(row,col) = max(max(MI));
    min_data_all(row,col) = min(min(MI));
    
end

% max_data=max(max(max(data_all(:,:,1:end-1))));
% min_data=min(min(min(data_all(:,:,1:end-1))));

max_data=max(max(max(data_all(:,:,:))));
min_data=min(min(min(data_all(:,:,:))));

figure()

for i=1:length(numbers)
    
    subplot(rows,cols,i)
    row=ceil(i/cols);
    col=mod(i,cols);
    if col==0
        col=cols;
    end
    
    imagesc(data_all(:,:,i))
    axis xy
    
    if ~isempty(clims)
        
        if isfloat(clims)
            caxis(clims)
        elseif strcmp(clims,'all')
            if min_data<max_data
                caxis([min_data max_data])
            end
        elseif strcmp(clims,'all+')
            if min_data<max_data
                caxis([0 max_data])
            end
        elseif strcmp(clims,'rows')
            caxis([min(min_data_all(row,:)) max(max_data_all(row,:))])
        elseif strcmp(clims,'rows+')
            caxis([0 max(max_data_all(row,:))])
        elseif strcmp(clims,'columns')
            caxis([min(min_data_all(:,col)) max(max_data_all(:,col))])
            colorbar
        elseif strcmp(clims,'columns+')
            caxis([0 max(max_data_all(:,col))])
            colorbar
        end
        
        if col==cols
            colorbar
        end
        
    else
        
        colorbar
        
    end
        
    if iscell(x_tick_labels)
        set(gca,'XTick',x_tick_selected,'XTickLabel',x_tick_labels(x_tick_selected))
    else
        set(gca,'XTick',x_tick_selected,'XTickLabel',round(x_tick_labels(x_tick_selected)))
    end
    set(gca,'YTick',y_tick_selected,'YTickLabel',round(y_tick_labels(y_tick_selected)))
        
    if length(titles)==cols 
        
        if row==1
            
            if iscell(titles{col})
                title(titles{col})
            else
                title(cellstr(titles{col}))
            end
            
        end
        
    elseif length(titles)==rows
        
        if iscell(titles{row})
            title(titles{row})
        else
            title(cellstr(titles{row}))
        end
        
    end
        
    if row==rows
        
        if ~isempty(x_labels)
            xlabel(x_labels{col})
        else
            xlabel('Phase-Giving Freq. (Hz)')
        end
        
    end
    
    if col==1
        if ~isempty(y_labels)
            ylabel(y_labels{row})%;'Amp.-Giving Freq. (Hz)'})
        else
            ylabel('Amp.-Giving Freq. (Hz)')
        end
    elseif col==cols
        colorbar
    end
    
end