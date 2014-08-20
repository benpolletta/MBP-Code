function [max_data_all,data_all]=figure_replotter_labels_subregion(numbers,rows,cols,clims,x_tick_no,y_tick_no,x_tick_labels,y_tick_labels,x_subregion,y_subregion,titles,x_labels,y_labels)

% 'labels' can contain either a title for each figure to be replotted, in
% which case it has length rows*cols, or it can contain cols labels for the
% columns, followed by rows labels for the rows.

x_sub_indices=find(x_subregion(1)<=x_tick_labels & x_tick_labels <= x_subregion(2));
x_tick_sub=x_tick_labels(x_sub_indices);
x_dim=length(x_tick_sub);
x_tick_labels_selected = linspace(x_subregion(1),x_subregion(2),x_tick_no);
for xt=1:x_tick_no
   [~,x_tick_selected(xt)] = min(abs(x_tick_sub-x_tick_labels_selected(xt))); 
end

y_sub_indices=find(y_subregion(1)<=y_tick_labels & y_tick_labels <= y_subregion(2));
y_tick_sub=y_tick_labels(y_sub_indices);
y_dim=length(y_tick_sub);
y_tick_labels_selected = linspace(y_subregion(1),y_subregion(2),y_tick_no);
for yt=1:y_tick_no
   [~,y_tick_selected(yt)] = min(abs(y_tick_sub-y_tick_labels_selected(yt))); 
end

data_all=nan(y_dim,x_dim,rows,cols);
max_data_all = nan(rows,cols);
min_data_all = nan(rows,cols);

for i=1:length(numbers)
    
    figure(numbers(i))
    axxes=findall(gcf,'Type','axes');
    Chilluns=get(axxes(end),'Children');
    MI = get(Chilluns(end),'CData');
    
    row = ceil(i/cols);
    col = mod(i,cols)+1;
    if col==0
        col=cols;
    end
    
    % if numbers(i)~=4 & numbers(i)~=7 & numbers(i)~=8
    % MI=MI(1:end-1,1:end-1);
    % end
    
    [na,np]=size(MI);
    ny=y_sub_indices(y_sub_indices<=na);
    nx=x_sub_indices(x_sub_indices<=np);
    MI_sub=MI(ny,nx);
    [na,np]=size(MI_sub);
    
    data_all(1:na,1:np,i) = MI_sub;%sqrt(MI_sub);
    max_data_all(row,col) = max(max(MI_sub));
    min_data_all(row,col) = min(min(MI_sub));
    
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
        
    set(gca,'XTick',x_tick_selected,'XTickLabel',x_tick_labels_selected)%,'FontSize',16)
    set(gca,'YTick',y_tick_selected,'YTickLabel',y_tick_labels_selected)%,'FontSize',16)
        
    if length(titles)==cols 
        
        if row==1
            
            if iscell(titles{col})
                title(titles{col})%,'FontSize',16)
            else
                title(cellstr(titles{col}))%,'FontSize',16)
            end
            
        end
        
    elseif length(titles)==rows
        
        if iscell(titles{row})
            title(titles{row})%,'FontSize',16)
        else
            title(cellstr(titles{row}))%,'FontSize',16)
        end
        
    end
        
    if row==rows
        
        if ~isempty(x_labels)
            xlabel(x_labels{col})%,'FontSize',16)
        else
            xlabel('Phase-Giving Freq. (Hz)')
        end
        
    end
    
    if col==1
        if ~isempty(y_labels)
            ylabel(y_labels{row})%,'FontSize',16)%;'Amp.-Giving Freq. (Hz)'})
        else
            ylabel('Amp.-Giving Freq. (Hz)')%,'FontSize',16)
        end
    end
    
end