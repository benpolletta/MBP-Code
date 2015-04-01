function [handle]=figure_replotter(numbers,rows,cols,x_tick_no,y_tick_no,x_tick_labels,y_tick_labels,labels)
% function [max_MI_all,MI_all]=figure_replotter(numbers,rows,cols,x_tick_labels,y_tick_labels,labels)

% 'labels' can contain either a title for each figure to be replotted, in
% which case it has length rows*cols, or it can contain cols labels for the
% columns, followed by rows labels for the rows.

% x_tick_labels_selected = linspace(x_tick_labels(1),x_tick_labels(2),x_tick_no);
% for xt=1:x_tick_no
%    [~,x_tick_selected(xt)] = min(abs(x_tick_labels-x_tick_labels_selected(xt))); 
% end
% 
% y_tick_labels_selected = linspace(y_tick_labels(1),y_tick_labels(2),y_tick_no);
% for yt=1:y_tick_no
%    [~,y_tick_selected(yt)] = min(abs(y_tick_labels-y_tick_labels_selected(yt))); 
% end


nophases=length(x_tick_labels);
noamps=length(y_tick_labels);

MI_all=nan(noamps,nophases,rows*cols);

colorplot_flag=0;

for i=1:length(numbers)
    
%     figure(numbers(i))
    axxes=findall(numbers(i),'Type','axes');
    Chilluns=get(axxes(end),'Children');
    if ~isstruct(Chilluns)
        Chilluns=get(Chilluns(end));
        MI=Chilluns.CData;
    else
        MI=get(Chilluns,'CData');
    end
    [r,c]=size(MI);
    
    if sum(MI(end,:)==0)==c && sum(MI(:,end)==0)==r
    
        MI=MI(1:end-1,1:end-1);
        colorplot_flag=1;
        
    end
    
    [na,np]=size(MI);
    
    MI_all(1:na,1:np,i)=MI;
    max_MI_all(i)=max(max(MI));
    
end
    
max_MI=max(max(max(MI_all(:,:,:))));
min_MI=min(min(min(MI_all(:,:,:))));
    
figure()

handle=gcf;

for i=1:length(numbers)
    
    subplot(rows,cols,i)
    row=ceil(i/cols);
    col=mod(i,cols);
    if col==0
        col=cols;
    end
    
    if colorplot_flag==1
        colorplot(MI_all(:,:,i))
    else
        imagesc(MI_all(:,:,i))
    end
    
    axis xy
    
    if ~any(isnan([min_MI max_MI])) && ~any(isinf([min_MI max_MI]))
        
%         if min_MI < max_MI
%             caxis([min_MI max_MI])
%         end
        
        if 0 < max_MI
            caxis([0 max_MI])
        end
        
    end
    
%     if length(numbers)==1
    
    if iscell(x_tick_labels)
        set(gca,'XTick',1:floor(nophases/x_tick_no):nophases,'XTickLabel',x_tick_labels(1:floor(nophases/x_tick_no):end))
    else
        set(gca,'XTick',1:floor(nophases/x_tick_no):nophases,'XTickLabel',round(x_tick_labels(1:floor(nophases/x_tick_no):end)))
    end
       
    if iscell(y_tick_labels)
        set(gca,'YTick',1:floor(noamps/y_tick_no):noamps,'YTickLabel',y_tick_labels(1:floor(noamps/y_tick_no):end))
    else
        set(gca,'YTick',1:floor(noamps/y_tick_no):noamps,'YTickLabel',round(y_tick_labels(1:floor(noamps/y_tick_no):end)))
    end
    
%     else
%         set(gca,'XTick',[],'XTickLabel',[])
%         set(gca,'YTick',[],'YTickLabel',[])
%     end
    
    if length(labels)==length(numbers)
    
        title(labels{i})
        
        if col==1
            ylabel('Amp.-Giving Freq. (Hz)')
%             set(gca,'YTick',1:4:noamps,'YTickLabel',y_tick_labels(1:4:end))
        elseif col==cols
            colorbar
        end
        
        if row==rows
            xlabel('Phase-Giving Freq. (Hz)')
%             set(gca,'XTick',1:4:nophases,'XTickLabel',x_tick_labels(1:4:end))
        end
        
    elseif length(labels)==rows+cols
        
        if row==1
            title(labels{col})
        elseif row==rows
            xlabel('Phase-Giving Freq. (Hz)')
%             set(gca,'XTick',1:4:nophases,'XTickLabel',x_tick_labels(1:4:end))
        end
        
        if col==1
            if iscell(labels{cols+row})
                ylabel([labels{cols+row};'Amp.-Giving Freq. (Hz)'])
%                 set(gca,'YTick',1:4:noamps,'YTickLabel',y_tick_labels(1:4:end))
            else
                ylabel([cellstr(labels{cols+row});'Amp.-Giving Freq. (Hz)'])
%                 set(gca,'YTick',1:4:noamps,'YTickLabel',y_tick_labels(1:4:end))
            end
        elseif col==cols
            colorbar
        end
                
    end
    
end
    
    